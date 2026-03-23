import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:sigma_app/models/plant_model.dart';
import 'package:sigma_app/models/measurements.dart';
import 'package:flutter/services.dart' show rootBundle;

// ============================================================
//  DESIGN TOKENS
// ============================================================
class _DS {
  // Brand palette
  static const primary = PdfColor.fromInt(0xFF0D2B4E); // deep navy
  static const accent = PdfColor.fromInt(0xFF1E6FBF); // electric blue
  static const accentLight = PdfColor.fromInt(0xFFE8F1FB); // pale blue tint
  static const gold = PdfColor.fromInt(0xFFF0A500); // amber accent
  static const surface = PdfColor.fromInt(0xFFF7F9FC); // off-white
  static const border = PdfColor.fromInt(0xFFD0DAE8); // cool-grey border
  static const textPrimary = PdfColor.fromInt(0xFF0D1F35);
  static const textSecondary = PdfColor.fromInt(0xFF4A6580);
  static const textMuted = PdfColor.fromInt(0xFF7A93AD);
  static const white = PdfColors.white;
  static const red = PdfColor.fromInt(0xFFD93025);
  static const green = PdfColor.fromInt(0xFF1E8A44);

  // Spacing
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 40;

  // Radius
  static const pw.BorderRadius radiusSm = pw.BorderRadius.all(
    pw.Radius.circular(4),
  );
  static const pw.BorderRadius radiusMd = pw.BorderRadius.all(
    pw.Radius.circular(8),
  );
}

// ============================================================
//  PDF SERVICE
// ============================================================
class PdfService {
  static Future<void> generateAndSaveReport(UFV ufv) async {
    // IMPROVEMENT: Load both Regular and Bold fonts for crisp, professional rendering
    final ttf = await PdfGoogleFonts.robotoRegular();
    final ttfBold = await PdfGoogleFonts.robotoBold();
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(base: ttf, bold: ttfBold),
    );

    final ByteData imageBytes = await rootBundle.load('assets/logo.png');
    final pw.MemoryImage logoImage = pw.MemoryImage(
      imageBytes.buffer.asUint8List(),
    );

    _addCoverPage(pdf, ufv, logoImage);
    _addPlantInfoPage(pdf, ufv, logoImage);

    if (ufv.measurements != null) {
      _addMegohmetroPages(pdf, ufv.measurements!.megohmetro, logoImage);
      _addMicroohmimetroPages(pdf, ufv.measurements!.microohmimetro, logoImage);
      _addTtrPages(pdf, ufv.measurements!.ttr, logoImage);
      _addHipotPages(pdf, ufv.measurements!.hipot, logoImage);
      _addTerrometroPages(pdf, ufv.measurements!.terrometro, logoImage);
      _addToquePassoPages(pdf, ufv.measurements!.toquePasso, logoImage);
    }

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Relatorio_${ufv.name.replaceAll(' ', '_')}.pdf',
    );
  }

  // ============================================================
  //  COVER PAGE
  // ============================================================
  static void _addCoverPage(
    pw.Document pdf,
    UFV ufv,
    pw.MemoryImage logoImage,
  ) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              pw.Positioned.fill(child: pw.Container(color: _DS.primary)),
              pw.Positioned(
                top: 0,
                right: 0,
                child: pw.Container(
                  width: 220,
                  height: 220,
                  decoration: pw.BoxDecoration(
                    gradient: const pw.LinearGradient(
                      begin: pw.Alignment.topRight,
                      end: pw.Alignment.bottomLeft,
                      colors: [_DS.accent, _DS.primary],
                    ),
                  ),
                ),
              ),
              pw.Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: pw.Container(width: 6, color: _DS.gold),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.fromLTRB(50, 60, 50, 50),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      children: [
                        pw.Container(
                          width: 48,
                          height: 48,
                          decoration: pw.BoxDecoration(
                            borderRadius: _DS.radiusSm,
                          ),
                          child: pw.ClipRRect(
                            horizontalRadius: 4,
                            verticalRadius: 4,
                            child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                          ),
                        ),
                        pw.SizedBox(width: _DS.md),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'SIGMA POWERSYS LTDA',
                              style: pw.TextStyle(
                                fontSize: 13,
                                fontWeight: pw.FontWeight.bold,
                                color: _DS.white,
                                letterSpacing: 1.5,
                              ),
                            ),
                            pw.Text(
                              'CNPJ: 52.438.707/0001-88',
                              style: const pw.TextStyle(
                                fontSize: 9,
                                color: _DS.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.Spacer(),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: pw.BoxDecoration(
                        color: _DS.accent,
                        borderRadius: _DS.radiusSm,
                      ),
                      child: pw.Text(
                        'COMISSIONAMENTO · MÉDIA TENSÃO',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: _DS.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: _DS.md),
                    pw.Text(
                      'Relatório de\nInspeção',
                      style: pw.TextStyle(
                        fontSize: 48,
                        fontWeight: pw.FontWeight.bold,
                        color: _DS.white,
                        lineSpacing: 4,
                      ),
                    ),
                    pw.SizedBox(height: _DS.sm),
                    pw.Container(height: 3, width: 60, color: _DS.gold),
                    pw.SizedBox(height: _DS.lg),
                    pw.Text(
                      ufv.name.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: _DS.accentLight,
                        letterSpacing: 1,
                      ),
                    ),
                    pw.SizedBox(height: _DS.sm),
                    pw.Row(
                      children: [
                        _coverMeta(
                          'DATA',
                          DateTime.now().toString().substring(0, 10),
                        ),
                        pw.SizedBox(width: _DS.xl),
                        _coverMeta('REF.', 'RFP-5038'),
                        pw.SizedBox(width: _DS.xl),
                        _coverMeta('VERSÃO', 'v1.0'),
                      ],
                    ),
                    pw.Spacer(),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(_DS.md),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromInt(0xFF071829),
                        borderRadius: _DS.radiusMd,
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'DOCUMENTO CONFIDENCIAL · USO RESTRITO',
                            style: const pw.TextStyle(
                              fontSize: 8,
                              color: _DS.textMuted,
                            ),
                          ),
                          pw.Text(
                            'sigma-powersys.com.br',
                            style: const pw.TextStyle(
                              fontSize: 8,
                              color: _DS.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static pw.Widget _coverMeta(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 8, color: _DS.textMuted),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
            color: _DS.white,
          ),
        ),
      ],
    );
  }

  // ============================================================
  //  GLOBAL HEADER
  // ============================================================
  static pw.Widget Function(pw.Context) _buildGlobalHeader(
    pw.MemoryImage logoImage,
  ) {
    return (pw.Context context) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(bottom: _DS.md),
        child: pw.Column(
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Row(
                  children: [
                    pw.Container(
                      width: 32,
                      height: 32,
                      child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                    ),
                    pw.SizedBox(width: _DS.sm),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'SIGMA POWERSYS',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: _DS.primary,
                            letterSpacing: 0.8,
                          ),
                        ),
                        pw.Text(
                          'Relatório de Comissionamento',
                          style: const pw.TextStyle(
                            fontSize: 7,
                            color: _DS.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: pw.BoxDecoration(
                    color: _DS.accentLight,
                    borderRadius: _DS.radiusSm,
                  ),
                  child: pw.Text(
                    'Pág. ${context.pageNumber}',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: _DS.accent,
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 6),
            pw.Stack(
              children: [
                pw.Container(height: 3, color: _DS.primary),
                pw.Positioned(
                  right: 0,
                  top: 0,
                  child: pw.Container(width: 60, height: 3, color: _DS.gold),
                ),
              ],
            ),
            pw.SizedBox(height: 2),
            pw.Container(height: 0.5, color: _DS.border),
            pw.SizedBox(height: _DS.sm),
          ],
        ),
      );
    };
  }

  static pw.Widget _sectionTitle(String number, String title) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: _DS.lg, bottom: _DS.sm),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Container(
            width: 26,
            height: 26,
            decoration: pw.BoxDecoration(
              color: _DS.primary,
              borderRadius: _DS.radiusSm,
            ),
            child: pw.Center(
              child: pw.Text(
                number,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: _DS.gold,
                ),
              ),
            ),
          ),
          pw.SizedBox(width: _DS.sm),
          pw.Text(
            title.toUpperCase(),
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: _DS.primary,
              letterSpacing: 0.6,
            ),
          ),
          pw.SizedBox(width: _DS.sm),
          pw.Expanded(child: pw.Container(height: 1, color: _DS.border)),
        ],
      ),
    );
  }

  static pw.Widget _styledTable({
    List<String>? headers,
    required List<List<String>> data,
  }) {
    List<pw.TableRow> rows = [];

    if (headers != null) {
      rows.add(
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _DS.primary),
          children: headers
              .map(
                (h) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  child: pw.Text(
                    h,
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: _DS.white,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      );
    }

    for (int i = 0; i < data.length; i++) {
      final isEven = i.isEven;
      rows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(color: isEven ? _DS.surface : _DS.white),
          children: data[i]
              .map(
                (cell) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: pw.Text(
                    cell,
                    style: const pw.TextStyle(
                      fontSize: 8.5,
                      color: _DS.textPrimary,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      );
    }

    return pw.ClipRRect(
      horizontalRadius: 4,
      verticalRadius: 4,
      child: pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: _DS.border, width: 0.5),
          borderRadius: _DS.radiusSm,
        ),
        child: pw.Table(
          border: pw.TableBorder(
            horizontalInside: pw.BorderSide(color: _DS.border, width: 0.5),
            verticalInside: pw.BorderSide(color: _DS.border, width: 0.5),
          ),
          children: rows,
        ),
      ),
    );
  }

  static pw.Widget _statusBadge(String status) {
    final s = status.toUpperCase();
    PdfColor bg;
    PdfColor fg;
    if (s == 'OK' || s == 'BOM') {
      bg = PdfColor.fromInt(0xFFE6F4EC);
      fg = _DS.green;
    } else if (s == 'NA' || s == '-') {
      bg = PdfColor.fromInt(0xFFF0F0F0);
      fg = _DS.textMuted;
    } else {
      bg = PdfColor.fromInt(0xFFFDE8E8);
      fg = _DS.red;
    }
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: pw.BoxDecoration(color: bg, borderRadius: _DS.radiusSm),
      child: pw.Text(
        s,
        style: pw.TextStyle(
          fontSize: 7.5,
          fontWeight: pw.FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }

  // ============================================================
  //  EVALUATION BADGE FOR PDF
  // ============================================================
  static pw.Widget _pdfEvaluationBadge(String status) {
    if (status == 'none' || status.isEmpty) return pw.SizedBox();

    PdfColor bgColor;
    PdfColor textColor;
    String text;

    switch (status) {
      case 'aprovado':
        bgColor = PdfColor.fromInt(0xFFE6F4EC);
        textColor = _DS.green;
        text = 'APROVADO';
        break;
      case 'alerta':
        bgColor = PdfColor.fromInt(0xFFFEF3E1);
        textColor = _DS.gold;
        text = 'ALERTA';
        break;
      case 'reprovado':
        bgColor = PdfColor.fromInt(0xFFFDE8E8);
        textColor = _DS.red;
        text = 'REPROVADO';
        break;
      default:
        return pw.SizedBox();
    }

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: pw.BoxDecoration(
        color: bgColor,
        borderRadius: _DS.radiusSm,
        border: pw.Border.all(
          color: PdfColor(textColor.red, textColor.green, textColor.blue, 0.5),
          width: 0.5,
        ),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 7.5,
          fontWeight: pw.FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  static pw.Widget _instrumentHeader(String instrument, String equipment) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: _DS.md),
      padding: const pw.EdgeInsets.all(_DS.md),
      decoration: pw.BoxDecoration(
        gradient: const pw.LinearGradient(
          colors: [_DS.primary, _DS.accent],
          begin: pw.Alignment.centerLeft,
          end: pw.Alignment.centerRight,
        ),
        borderRadius: _DS.radiusMd,
      ),
      child: pw.Row(
        children: [
          pw.Container(
            width: 4,
            height: 36,
            decoration: pw.BoxDecoration(
              color: _DS.gold,
              borderRadius: _DS.radiusSm,
            ),
          ),
          pw.SizedBox(width: _DS.sm),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'INSTRUMENTO',
                style: const pw.TextStyle(
                  fontSize: 7,
                  color: _DS.textMuted,
                  letterSpacing: 1,
                ),
              ),
              pw.Text(
                instrument,
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: _DS.white,
                ),
              ),
            ],
          ),
          pw.Spacer(),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'EQUIPAMENTO',
                style: const pw.TextStyle(
                  fontSize: 7,
                  color: _DS.textMuted,
                  letterSpacing: 1,
                ),
              ),
              pw.Text(
                equipment,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: _DS.accentLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _infoChip(String label, String value) {
    return pw.Row(
      children: [
        pw.Text(
          '$label: ',
          style: const pw.TextStyle(fontSize: 8, color: _DS.textSecondary),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 8,
            fontWeight: pw.FontWeight.bold,
            color: _DS.textPrimary,
          ),
        ),
      ],
    );
  }

  static bool _hasImages(MeasurementValue measurement) {
    return (measurement.imageUrl.isNotEmpty &&
            !measurement.imageUrl.startsWith('http')) ||
        (measurement.environmentImageUrl.isNotEmpty &&
            !measurement.environmentImageUrl.startsWith('http'));
  }

  // ============================================================
  //  MEASUREMENT CARD - WITH EVALUATION IN HEADER
  // ============================================================
  static pw.Widget _measurementCard({
    required String label,
    required MeasurementValue measurement,
  }) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: _DS.sm),
      decoration: pw.BoxDecoration(
        color: _DS.white,
        border: pw.Border.all(color: _DS.border, width: 0.5),
        borderRadius: _DS.radiusMd,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Card header
          // Card body - OPTIMIZED LAYOUT
          pw.Padding(
            padding: const pw.EdgeInsets.all(_DS.md),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (_hasImages(measurement)) ...[
                  _buildOptimizedImageRow(label, measurement),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildOptimizedImageRow(
    String label,
    MeasurementValue measurement,
  ) {
    pw.Widget? measImage;
    pw.Widget? envImage;

    const double fixedImageSize = 130;

    pw.Widget? loadLocalImage(String path) {
      if (path.isNotEmpty && !path.startsWith('http')) {
        try {
          final file = File(path);
          if (file.existsSync()) {
            final imageBytes = file.readAsBytesSync();
            return pw.Container(
              height: fixedImageSize,
              width: fixedImageSize,
              child: pw.ClipRRect(
                horizontalRadius: 6,
                verticalRadius: 6,
                child: pw.Image(
                  pw.MemoryImage(imageBytes),
                  fit: pw.BoxFit.cover,
                ),
              ),
            );
          }
        } catch (_) {
          return pw.Container(
            height: fixedImageSize,
            width: fixedImageSize,
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFFDE8E8),
              borderRadius: _DS.radiusSm,
            ),
            child: pw.Center(
              child: pw.Text(
                '[Erro]',
                style: const pw.TextStyle(fontSize: 8, color: _DS.red),
              ),
            ),
          );
        }
      }
      return null;
    }

    measImage = loadLocalImage(measurement.imageUrl);
    envImage = loadLocalImage(measurement.environmentImageUrl);

    if (measImage == null && envImage == null) return pw.SizedBox();

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // ── IMAGES (Left Side) ──
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (measImage != null) measImage,
            if (measImage != null && envImage != null)
              pw.SizedBox(width: _DS.sm),
            if (envImage != null) envImage,
          ],
        ),

        pw.SizedBox(width: _DS.md),

        // ── DETAILS PANEL (Right Side) ──
        pw.Expanded(
          child: pw.Container(
            height: fixedImageSize + 10,
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              gradient: const pw.LinearGradient(
                colors: [_DS.accentLight, _DS.white],
                begin: pw.Alignment.topLeft,
                end: pw.Alignment.bottomRight,
              ),
              borderRadius: _DS.radiusMd,
              border: pw.Border.all(color: _DS.accent, width: 0.5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              mainAxisAlignment: pw
                  .MainAxisAlignment
                  .spaceBetween, // Distributes top, middle, and bottom evenly
              children: [
                // --- TOP: Title & Divider ---
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      label.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 7.5,
                        fontWeight: pw.FontWeight.bold,
                        color: _DS.primary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Container(height: 1, width: 40, color: _DS.accent),
                  ],
                ),

                // --- MIDDLE: Highlighted Value & Equipment ---
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    // Highlighted Value + Unit
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text(
                          '${measurement.value}',
                          style: pw.TextStyle(
                            fontSize: 22, // Large, highlighted number
                            fontWeight: pw.FontWeight.bold,
                            color: _DS.primary,
                          ),
                        ),
                        pw.SizedBox(width: 4),
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 3),
                          child: pw.Text(
                            measurement.measurementUnit,
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: _DS.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),

                    // Equipment Name
                    pw.Text(
                      'EQUIPAMENTO',
                      style: const pw.TextStyle(
                        fontSize: 6,
                        color: _DS.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      measurement.equipment,
                      maxLines: 2,
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 8.5,
                        fontWeight: pw.FontWeight.bold,
                        color: _DS.textPrimary,
                      ),
                    ),
                  ],
                ),

                // --- BOTTOM: Evaluation Badge ---
                pw.Align(
                  alignment: pw.Alignment.bottomCenter,
                  child: _pdfEvaluationBadge(
                    measurement.evaluation,
                  ), // Uses your existing badge logic
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  //  SECOND PAGE: PLANT & TRANSFORMER INFO
  // ============================================================
  static void _addPlantInfoPage(
    pw.Document pdf,
    UFV ufv,
    pw.MemoryImage logoImage,
  ) {
    pw.Widget? identificacaoImageWidget;
    if (ufv.measurements != null &&
        ufv.measurements!.identificacaoUrl.isNotEmpty) {
      try {
        final file = File(ufv.measurements!.identificacaoUrl);
        if (file.existsSync()) {
          identificacaoImageWidget = pw.Center(
            child: pw.Container(
              height: 600,
              width: double.infinity,
              margin: const pw.EdgeInsets.only(top: 10, bottom: 20),
              child: pw.ClipRRect(
                horizontalRadius: 6,
                verticalRadius: 6,
                child: pw.Image(
                  pw.MemoryImage(file.readAsBytesSync()),
                  fit: pw.BoxFit.contain,
                ),
              ),
            ),
          );
        }
      } catch (_) {}
    }

    if (identificacaoImageWidget != null) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 42, vertical: 36),
          header: _buildGlobalHeader(logoImage),
          build: (pw.Context context) {
            return [
              pw.SizedBox(height: 10),
              pw.Text(
                'FOTO DE IDENTIFICAÇÃO (PLACA)',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: _DS.primary,
                ),
              ),
              identificacaoImageWidget!,
              pw.SizedBox(height: 50),
            ];
          },
        ),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 42, vertical: 36),
        header: _buildGlobalHeader(logoImage),
        build: (pw.Context context) {
          return [
            _sectionTitle('1', 'Dados do Projeto e Ambiente'),
            _styledTable(
              data: [
                [
                  'Projeto',
                  ufv.name,
                  'Temp. Ambiente',
                  ufv.tempAmbiente.isNotEmpty ? ufv.tempAmbiente : 'N/A',
                ],
                [
                  'Local',
                  'UFV - ${ufv.name}',
                  'Umidade',
                  ufv.umidade.isNotEmpty ? ufv.umidade : 'N/A',
                ],
                [
                  'Identificação',
                  ufv.nSerie.isNotEmpty ? ufv.nSerie : 'N/A',
                  'Classe (kV)',
                  ufv.classeKv.isNotEmpty ? ufv.classeKv : 'N/A',
                ],
                ['Data', DateTime.now().toString().substring(0, 10), '', ''],
              ],
            ),

            _sectionTitle('2', 'Sistemas de Proteção'),
            _buildStatusTable(
              headers: ['Proteção Geral', 'Estado', 'Proteção Local', 'Estado'],
              data: [
                [
                  'Estado Geral',
                  ufv.estadoGeralProtecaoGeral.toUpperCase(),
                  'Estado Geral',
                  ufv.estadoGeralProtecaoLocal.toUpperCase(),
                ],
                [
                  'Relé Proteção',
                  ufv.releProtecaoGeral.toUpperCase(),
                  'Relé Proteção',
                  ufv.releProtecaoLocal.toUpperCase(),
                ],
                [
                  'Nobreak',
                  ufv.nobreakGeral.toUpperCase(),
                  'Nobreak',
                  ufv.nobreakLocal.toUpperCase(),
                ],
                [
                  'Seccionamento',
                  ufv.seccionamentoGeral.toUpperCase(),
                  'Seccionamento',
                  ufv.seccionamentoLocal.toUpperCase(),
                ],
              ],
              statusColumns: [1, 3],
            ),

            _sectionTitle('3', 'Dados do Transformador'),
            _styledTable(
              data: [
                [
                  'Dados',
                  'PLACA',
                  'Frequência (Hz)',
                  ufv.frequencia != 0 ? ufv.frequencia.toString() : '-',
                ],
                [
                  'Fechamento',
                  ufv.fechamento.isNotEmpty ? ufv.fechamento : '-',
                  'Peso (Kg)',
                  ufv.peso != 0 ? ufv.peso.toString() : '-',
                ],
                [
                  'Marca',
                  ufv.marca.isNotEmpty ? ufv.marca : '-',
                  'Volume Óleo',
                  ufv.volumeOleo != 0 ? ufv.volumeOleo.toString() : '-',
                ],
                ['Tipo', 'SECO', 'IP', ufv.ip != 0 ? ufv.ip.toString() : '0'],
                [
                  'N. Série',
                  ufv.nSerie.isNotEmpty ? ufv.nSerie : '-',
                  'Data Fabricação',
                  ufv.dataFabricacao.isNotEmpty ? ufv.dataFabricacao : '-',
                ],
                [
                  'Fator K',
                  ufv.fatorK != 0 ? ufv.fatorK.toString() : '-',
                  'Tap 1 (V)',
                  ufv.tensaoPrimaria != 0 ? ufv.tensaoPrimaria.toString() : '-',
                ],
                [
                  'Rel. Transformação',
                  ufv.relacaoNominal != 0 ? ufv.relacaoNominal.toString() : '-',
                  'Tap 2 (V)',
                  '-',
                ],
                [
                  'Potência kVA',
                  ufv.potenciaKva != 0 ? ufv.potenciaKva.toString() : '-',
                  'Impedância',
                  ufv.impedancia != 0 ? ufv.impedancia.toString() : '-',
                ],
              ],
            ),

            _sectionTitle('4', 'Inspeção Visual'),
            _buildStatusTable(
              headers: ['Item Inspecionado', 'Status'],
              data: [
                ['Estado Geral', ufv.estadoGeralInspecao.toUpperCase()],
                ['Bobina 1 (Trafo a Seco)', ufv.bobina1.toUpperCase()],
                ['Bobina 2 (Trafo a Seco)', ufv.bobina2.toUpperCase()],
                ['Bobina 3 (Trafo a Seco)', ufv.bobina3.toUpperCase()],
                ['H0 - Bucha MT', ufv.h0BuchaMt.toUpperCase()],
                ['H1 - Bucha MT', ufv.h1BuchaMt.toUpperCase()],
                ['H2 - Bucha MT', ufv.h2BuchaMt.toUpperCase()],
                ['H3 - Bucha MT', ufv.h3BuchaMt.toUpperCase()],
                ['X0 - Bucha BT', ufv.x0BuchaBt.toUpperCase()],
                ['X1 - Bucha BT', ufv.x1BuchaBt.toUpperCase()],
                ['X2 - Bucha BT', ufv.x2BuchaBt.toUpperCase()],
                ['X3 - Bucha BT', ufv.x3BuchaBt.toUpperCase()],
                [
                  'Vazamento Óleo Carcaça',
                  ufv.vazamentoOleoCarcaca.toUpperCase(),
                ],
              ],
              statusColumns: [1],
            ),

            _sectionTitle('5', 'Proteções Físicas'),
            _buildStatusTable(
              headers: ['Item Inspecionado', 'Status'],
              data: [
                [
                  'Relé Temperatura Digital',
                  ufv.releTemperaturaDigital.toUpperCase(),
                ],
                ['PT-100 Bobina 1 (Seco)', ufv.pt100Bobina1.toUpperCase()],
                ['PT-100 Bobina 2 (Seco)', ufv.pt100Bobina2.toUpperCase()],
                ['PT-100 Bobina 3 (Seco)', ufv.pt100Bobina3.toUpperCase()],
                ['Ventilação Forçada', ufv.ventilacaoForcada.toUpperCase()],
                [
                  'PT-100 / Termômetro (Óleo)',
                  ufv.pt100TermometroOleo.toUpperCase(),
                ],
                ['Pressostato (Óleo)', ufv.pressostatoOleo.toUpperCase()],
                ['Nível de Óleo (Óleo)', ufv.nivelOleo.toUpperCase()],
                ['Análise de Óleo', ufv.analiseOleo.toUpperCase()],
              ],
              statusColumns: [1],
            ),

            _sectionTitle('6', 'Trafo de Aterramento / Reator'),

            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(_DS.md),
              decoration: pw.BoxDecoration(
                color: _DS.surface,
                border: pw.Border.all(color: _DS.border),
                borderRadius: _DS.radiusMd,
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'OBSERVAÇÕES / RECOMENDAÇÕES FINAIS',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: _DS.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  pw.SizedBox(height: _DS.sm),
                  pw.Text(
                    ufv.observacoes.isNotEmpty
                        ? ufv.observacoes
                        : 'Nenhuma observação registrada.',
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: _DS.textPrimary,
                      height: 1.4,
                    ),
                  ),
                  pw.SizedBox(height: _DS.lg + 20),
                ],
              ),
            ),

            pw.SizedBox(height: _DS.lg),

            pw.Container(
              padding: const pw.EdgeInsets.all(_DS.md),
              decoration: pw.BoxDecoration(
                color: _DS.surface,
                border: pw.Border.all(color: _DS.border),
                borderRadius: _DS.radiusMd,
              ),
              child: pw.Row(
                children: [
                  _signatureBlock(
                    'EXECUTANTE',
                    ufv.executanteNome.isNotEmpty
                        ? ufv.executanteNome
                        : 'NOME DO EXECUTANTE',
                    ufv.executanteCft.isNotEmpty
                        ? 'CFT-BR: ${ufv.executanteCft}'
                        : 'CFT-BR: [INFORMAR]',
                  ),
                  pw.Container(width: 0.5, color: _DS.border),
                  _signatureBlock(
                    'ENGENHEIRO RESPONSÁVEL',
                    ufv.engenheiroNome.isNotEmpty
                        ? ufv.engenheiroNome
                        : 'NOME DO ENGENHEIRO',
                    ufv.engenheiroCrea.isNotEmpty
                        ? 'CREA: ${ufv.engenheiroCrea}'
                        : 'CREA: [INFORMAR]',
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );
  }

  static pw.Widget _buildStatusTable({
    List<String>? headers,
    required List<List<String>> data,
    List<int> statusColumns = const [],
  }) {
    List<pw.TableRow> rows = [];

    if (headers != null) {
      rows.add(
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _DS.primary),
          children: headers
              .map(
                (h) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  child: pw.Text(
                    h,
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: _DS.white,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      );
    }

    for (int i = 0; i < data.length; i++) {
      final isEven = i.isEven;
      rows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(color: isEven ? _DS.surface : _DS.white),
          children: data[i].asMap().entries.map((e) {
            final colIndex = e.key;
            final cell = e.value;
            final isStatus = statusColumns.contains(colIndex);
            return pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              child: isStatus && cell.isNotEmpty
                  ? _statusBadge(cell)
                  : pw.Text(
                      cell,
                      style: const pw.TextStyle(
                        fontSize: 8.5,
                        color: _DS.textPrimary,
                      ),
                    ),
            );
          }).toList(),
        ),
      );
    }

    return pw.ClipRRect(
      horizontalRadius: 4,
      verticalRadius: 4,
      child: pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: _DS.border, width: 0.5),
          borderRadius: _DS.radiusSm,
        ),
        child: pw.Table(
          border: pw.TableBorder(
            horizontalInside: pw.BorderSide(color: _DS.border, width: 0.5),
            verticalInside: pw.BorderSide(color: _DS.border, width: 0.5),
          ),
          children: rows,
        ),
      ),
    );
  }

  static pw.Widget _signatureBlock(
    String role,
    String name,
    String credential,
  ) {
    return pw.Expanded(
      child: pw.Padding(
        padding: const pw.EdgeInsets.all(_DS.md),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              role,
              style: const pw.TextStyle(
                fontSize: 7,
                color: _DS.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              name,
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: _DS.primary,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              credential,
              style: const pw.TextStyle(fontSize: 8, color: _DS.textSecondary),
            ),
            // pw.SizedBox(height: _DS.lg),
            // pw.Container(height: 0.5, color: _DS.border),
            // pw.SizedBox(height: 4),
            // pw.Text(
            //  'Assinatura',
            //  style: const pw.TextStyle(fontSize: 7, color: _DS.textMuted),
            // ),
          ],
        ),
      ),
    );
  }

  static void _addMegohmetroPages(
    pw.Document pdf,
    Megohmetro meg,
    pw.MemoryImage logoImage,
  ) {
    if (meg.transformador != null) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 42, vertical: 36),
          header: _buildGlobalHeader(logoImage),
          build: (pw.Context context) {
            List<pw.Widget> content = [
              _instrumentHeader('Megôhmetro', 'Transformador'),
            ];

            meg.transformador?.readings.forEach((key, measurement) {
              content.add(
                _measurementCard(label: key, measurement: measurement),
              );
            });

            return content;
          },
        ),
      );
    }

    _addPhaseGroupSection(
      pdf,
      'Megôhmetro',
      'Terminação Mufla',
      meg.terminacaoMufla,
      logoImage,
    );
    _addPhaseGroupSection(
      pdf,
      'Megôhmetro',
      'Para Raios',
      meg.paraRaios,
      logoImage,
    );
    _addPhaseGroupSection(
      pdf,
      'Megôhmetro',
      'Seccionadora',
      meg.seccionadora,
      logoImage,
    );
    _addPhaseGroupSection(
      pdf,
      'Megôhmetro',
      'Disjuntor Religador',
      meg.disjuntorReligador,
      logoImage,
    );
  }

  static void _addPhaseGroupSection(
    pw.Document pdf,
    String instrument,
    String title,
    Map<String, PhaseGroup> groupMap,
    pw.MemoryImage logoImage,
  ) {
    if (groupMap.isEmpty) return;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 42, vertical: 36),
        header: _buildGlobalHeader(logoImage),
        build: (pw.Context context) {
          List<pw.Widget> content = [_instrumentHeader(instrument, title)];

          groupMap.forEach((key, phaseGroup) {
            content.add(
              pw.Container(
                margin: const pw.EdgeInsets.only(top: _DS.md, bottom: _DS.sm),
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: _DS.md,
                  vertical: _DS.sm,
                ),
                decoration: pw.BoxDecoration(
                  color: _DS.accentLight,
                  border: pw.Border(
                    left: pw.BorderSide(color: _DS.accent, width: 3),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      key,
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: _DS.primary,
                      ),
                    ),
                    _infoChip('Equipamento', phaseGroup.equipamento),
                  ],
                ),
              ),
            );

            void addPhase(String name, MeasurementValue meas) {
              if (!meas.isFilled) return;
              content.add(_measurementCard(label: name, measurement: meas));
            }

            addPhase('Fase A', phaseGroup.faseA);
            addPhase('Fase B', phaseGroup.faseB);
            addPhase('Fase C', phaseGroup.faseC);
            if (phaseGroup.faseReserva != null) {
              addPhase('Fase Reserva', phaseGroup.faseReserva!);
            }
            if (phaseGroup.auxiliar != null) {
              addPhase('Auxiliar', phaseGroup.auxiliar!);
            }
          });

          return content;
        },
      ),
    );
  }

  static void _addDynamicGroupMapSection(
    pw.Document pdf,
    String instrumentName,
    String equipmentName,
    Map<String, DynamicGroup> groupMap,
    pw.MemoryImage logoImage,
  ) {
    if (groupMap.isEmpty) return;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 42, vertical: 36),
        header: _buildGlobalHeader(logoImage),
        build: (pw.Context context) {
          List<pw.Widget> content = [
            _instrumentHeader(instrumentName, equipmentName),
          ];

          groupMap.forEach((groupName, dynamicGroup) {
            if (dynamicGroup.readings.isEmpty) return;

            content.add(
              pw.Container(
                margin: const pw.EdgeInsets.only(top: _DS.md, bottom: _DS.sm),
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: _DS.md,
                  vertical: _DS.sm,
                ),
                decoration: pw.BoxDecoration(
                  color: _DS.accentLight,
                  border: pw.Border(
                    left: pw.BorderSide(color: _DS.gold, width: 3),
                  ),
                ),
                child: pw.Text(
                  groupName,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: _DS.primary,
                  ),
                ),
              ),
            );

            dynamicGroup.readings.forEach((measKey, measurement) {
              if (!measurement.isFilled) return;
              content.add(
                _measurementCard(label: measKey, measurement: measurement),
              );
            });
          });

          return content;
        },
      ),
    );
  }

  static void _addMicroohmimetroPages(
    pw.Document pdf,
    Microohmimetro micro,
    pw.MemoryImage logoImage,
  ) {
    _addDynamicGroupMapSection(
      pdf,
      'Microohmímetro',
      'Transformador',
      micro.transformador,
      logoImage,
    );
    _addDynamicGroupMapSection(
      pdf,
      'Microohmímetro',
      'Continuidade Malha',
      micro.continuidadeMalha,
      logoImage,
    );
    _addPhaseGroupSection(
      pdf,
      'Microohmímetro',
      'Seccionadora',
      micro.seccionadora,
      logoImage,
    );
    _addPhaseGroupSection(
      pdf,
      'Microohmímetro',
      'Disjuntor Religador',
      micro.disjuntorReligador,
      logoImage,
    );
  }

  static void _addTtrPages(pw.Document pdf, Ttr ttr, pw.MemoryImage logoImage) {
    _addDynamicGroupMapSection(
      pdf,
      'TTR (Relação de Transformação)',
      'Transformador',
      ttr.transformador,
      logoImage,
    );
    if (ttr.transformadorPotencial != null) {
      _addPhaseGroupSection(pdf, 'TTR', 'Transformador de Potencial', {
        'Transformador de Potencial': ttr.transformadorPotencial!,
      }, logoImage);
    }
    if (ttr.transformadorCorrente != null) {
      _addPhaseGroupSection(pdf, 'TTR', 'Transformador de Corrente', {
        'Transformador de Corrente': ttr.transformadorCorrente!,
      }, logoImage);
    }
  }

  static void _addHipotPages(
    pw.Document pdf,
    Hipot hipot,
    pw.MemoryImage logoImage,
  ) {
    _addPhaseGroupSection(
      pdf,
      'Hipot',
      'Cabos de Média Tensão',
      hipot.caboMediaTensao,
      logoImage,
    );
  }

  static void _addTerrometroPages(
    pw.Document pdf,
    Terrometro terro,
    pw.MemoryImage logoImage,
  ) {
    if (terro.subestacao != null) {
      _addDynamicGroupMapSection(
        pdf,
        'Terrômetro',
        'Subestação - Resistência de Aterramento',
        {'Subestação': terro.subestacao!},
        logoImage,
      );
    }
    _addDynamicGroupMapSection(
      pdf,
      'Terrômetro',
      'Transformadores - Resistência de Aterramento',
      terro.transformadores,
      logoImage,
    );
  }

  static void _addToquePassoPages(
    pw.Document pdf,
    ToquePasso toque,
    pw.MemoryImage logoImage,
  ) {
    _addDynamicGroupMapSection(
      pdf,
      'Toque e Passo',
      'Subestação',
      toque.subestacao,
      logoImage,
    );
    _addDynamicGroupMapSection(
      pdf,
      'Toque e Passo',
      'Cercamento e Abrigo',
      toque.cercamento,
      logoImage,
    );
    _addDynamicGroupMapSection(
      pdf,
      'Toque e Passo',
      'SKID',
      toque.skid,
      logoImage,
    );
  }
}
