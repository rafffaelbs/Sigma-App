import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:sigma_app/models/plant_model.dart';
import 'package:sigma_app/models/measurements.dart';

class PdfService {
  static Future<void> generateAndSaveReport(UFV ufv) async {
    final pdf = pw.Document();

    // 1. Title Page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'Relatório de Inspeção',
                  style: pw.TextStyle(
                    fontSize: 32,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'UFV: ${ufv.name}',
                  style: const pw.TextStyle(fontSize: 24),
                ),
                pw.Text(
                  'Data: ${DateTime.now().toString().substring(0, 10)}',
                  style: const pw.TextStyle(fontSize: 18),
                ),
              ],
            ),
          );
        },
      ),
    );

    // 2. Add Content Pages
    if (ufv.measurements != null) {
      _addMegohmetroPages(pdf, ufv.measurements!.megohmetro);
      _addMicroohmimetroPages(pdf, ufv.measurements!.microohmimetro);
    }

    // 3. Trigger the Native Save/Share Dialog
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Relatorio_${ufv.name.replaceAll(' ', '_')}.pdf',
    );
  }

  // ==========================================
  // UNIVERSAL HELPER: SIDE-BY-SIDE IMAGES
  // ==========================================
  static pw.Widget _buildImageRow(MeasurementValue measurement) {
    pw.Widget? measImage;
    pw.Widget? envImage;

    // Local function to safely load a File into a PDF Image Widget
    pw.Widget? loadLocalImage(String path) {
      if (path.isNotEmpty && !path.startsWith('http')) {
        try {
          final file = File(path);
          if (file.existsSync()) {
            final imageBytes = file.readAsBytesSync();
            return pw.Image(
              pw.MemoryImage(imageBytes),
              height: 150,
              fit: pw.BoxFit.contain,
            );
          }
        } catch (e) {
          return pw.Text(
            '[Erro na imagem]',
            style: const pw.TextStyle(color: PdfColors.red),
          );
        }
      }
      return null;
    }

    measImage = loadLocalImage(measurement.imageUrl);
    envImage = loadLocalImage(measurement.environmentImageUrl);

    // If there are no images at all, return empty space
    if (measImage == null && envImage == null) return pw.SizedBox();

    // Return the images in a Row
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Measurement Image (Left)
          if (measImage != null)
            pw.Expanded(
              child: pw.Column(
                children: [
                  pw.Text(
                    'Medição',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  measImage,
                ],
              ),
            ),

          // Spacing between images
          if (measImage != null && envImage != null) pw.SizedBox(width: 15),

          // Environment Image (Right)
          if (envImage != null)
            pw.Expanded(
              child: pw.Column(
                children: [
                  pw.Text(
                    'Ambiente',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  envImage,
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // MEGOHMETRO PAGES
  // ==========================================
  static void _addMegohmetroPages(pw.Document pdf, Megohmetro meg) {
    // 1. The Transformador (Dynamic Group)
    if (meg.transformador.readings.isNotEmpty) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            List<pw.Widget> content = [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Instrumento: Megôhmetro',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Header(level: 1, child: pw.Text('Equipamento: Transformador')),
            ];

            meg.transformador.readings.forEach((key, measurement) {
              content.add(pw.SizedBox(height: 10));
              content.add(
                pw.Text(
                  'Medição: $key',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              );
              content.add(
                pw.Text(
                  'Valor: ${measurement.value} ${measurement.measurementUnit}',
                ),
              );
              content.add(
                pw.Text('Equipamento Utilizado: ${measurement.equipment}'),
              );

              // USE THE NEW HELPER HERE
              content.add(_buildImageRow(measurement));

              content.add(pw.SizedBox(height: 10));
              content.add(pw.Divider());
            });

            return content;
          },
        ),
      );
    }

    // 2. Add the Phase Groups
    _addPhaseGroupSection(pdf, 'Terminação Mufla', meg.terminacaoMufla);
    _addPhaseGroupSection(pdf, 'Para Raios', meg.paraRaios);
    _addPhaseGroupSection(pdf, 'Seccionadora', meg.seccionadora);
    _addPhaseGroupSection(pdf, 'Disjuntor Religador', meg.disjuntorReligador);
  }

  // ==========================================
  // PHASE GROUP HELPER
  // ==========================================
  static void _addPhaseGroupSection(
    pw.Document pdf,
    String title,
    Map<String, PhaseGroup> groupMap,
  ) {
    if (groupMap.isEmpty) return;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          List<pw.Widget> content = [
            pw.Header(
              level: 1,
              child: pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ];

          pw.Widget buildPhaseInfo(
            String phaseName,
            MeasurementValue measurement,
          ) {
            if (!measurement.isFilled) return pw.SizedBox();

            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 12),
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    phaseName,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  pw.Text(
                    'Valor: ${measurement.value} ${measurement.measurementUnit}',
                  ),

                  // USE THE NEW HELPER HERE TOO
                  _buildImageRow(measurement),
                ],
              ),
            );
          }

          groupMap.forEach((key, phaseGroup) {
            content.add(pw.SizedBox(height: 15));
            content.add(
              pw.Text(
                key,
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            );
            content.add(
              pw.Text('Equipamento Utilizado: ${phaseGroup.equipamento}'),
            );
            content.add(pw.SizedBox(height: 10));

            content.add(buildPhaseInfo('Fase A', phaseGroup.faseA));
            content.add(buildPhaseInfo('Fase B', phaseGroup.faseB));
            content.add(buildPhaseInfo('Fase C', phaseGroup.faseC));

            if (phaseGroup.faseReserva != null) {
              content.add(
                buildPhaseInfo('Fase Reserva', phaseGroup.faseReserva!),
              );
            }
            if (phaseGroup.auxiliar != null) {
              content.add(buildPhaseInfo('Auxiliar', phaseGroup.auxiliar!));
            }

            content.add(pw.Divider(thickness: 2));
          });

          return content;
        },
      ),
    );
  }

  // ==========================================
  // DYNAMIC GROUP MAP HELPER
  // ==========================================
  static void _addDynamicGroupMapSection(
    pw.Document pdf,
    String instrumentName,
    String equipmentName,
    Map<String, DynamicGroup> groupMap,
  ) {
    if (groupMap.isEmpty) return;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          List<pw.Widget> content = [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Instrumento: $instrumentName',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Header(level: 1, child: pw.Text('Equipamento: $equipmentName')),
          ];

          // Loop through the subgroups (e.g., "AT Delta Estrela", "BT Delta Estrela")
          groupMap.forEach((groupName, dynamicGroup) {
            if (dynamicGroup.readings.isEmpty) return;

            content.add(pw.SizedBox(height: 15));
            content.add(
              pw.Text(
                groupName,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey800,
                ),
              ),
            );
            content.add(pw.Divider());

            // Loop through the actual readings (e.g., "H1-H3")
            dynamicGroup.readings.forEach((measKey, measurement) {
              if (!measurement.isFilled) return; // Skip empty ones

              content.add(pw.SizedBox(height: 10));
              content.add(
                pw.Text(
                  'Medição: $measKey',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              );
              content.add(
                pw.Text(
                  'Valor: ${measurement.value} ${measurement.measurementUnit}',
                ),
              );
              content.add(
                pw.Text('Equipamento Utilizado: ${measurement.equipment}'),
              );

              // USE OUR SIDE-BY-SIDE IMAGE HELPER!
              content.add(_buildImageRow(measurement));

              content.add(pw.SizedBox(height: 10));
              content.add(pw.Divider(borderStyle: pw.BorderStyle.dashed));
            });
          });

          return content;
        },
      ),
    );
  }

  // ==========================================
  // MICROOHMIMETRO PAGES
  // ==========================================
  static void _addMicroohmimetroPages(pw.Document pdf, Microohmimetro micro) {
    // 1. Transformador (Uses the new DynamicGroupMap helper)
    _addDynamicGroupMapSection(
      pdf,
      'Microohmímetro',
      'Transformador',
      micro.transformador,
    );

    // 2. Continuidade Malha (Uses the new DynamicGroupMap helper)
    _addDynamicGroupMapSection(
      pdf,
      'Microohmímetro',
      'Continuidade Malha',
      micro.continuidadeMalha,
    );

    // 3. Seccionadora (Uses the PhaseGroup helper we built earlier!)
    // We add "Microohmímetro" to the title so it's clear which instrument this is for
    _addPhaseGroupSection(
      pdf,
      'Microohmímetro - Seccionadora',
      micro.seccionadora,
    );

    // 4. Disjuntor Religador (Uses the PhaseGroup helper)
    _addPhaseGroupSection(
      pdf,
      'Microohmímetro - Disjuntor Religador',
      micro.disjuntorReligador,
    );
  }
}
