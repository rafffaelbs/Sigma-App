import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sigma_app/models/plant_model.dart';
import 'package:sigma_app/models/measurements.dart';
import 'package:sigma_app/screens/dynamic_folder_screen.dart';
import 'package:sigma_app/screens/identificacao_entry_screen.dart';
import 'package:sigma_app/screens/phase_group_entry_screen.dart';
import 'package:sigma_app/screens/dynamic_group_entry_screen.dart';
import 'package:sigma_app/services/local_sync_service.dart';
import 'package:sigma_app/services/pdf_service.dart';
import 'package:sigma_app/services/supabase_service.dart';
import 'package:sigma_app/widgets/custom_header.dart';
import 'package:sigma_app/widgets/plant_button.dart';

class UfvInstrumentsScreen extends StatelessWidget {
  final UFV ufv;
  final Plant plant;

  const UfvInstrumentsScreen({
    super.key,
    required this.ufv,
    required this.plant,
  });

  bool _isInspectionFullyComplete(FullInspection inspection) {
    final meg = inspection.megohmetro.getProgress();
    final mic = inspection.microohmimetro.getProgress();
    final ttr = inspection.ttr.getProgress();
    final hip = inspection.hipot.getProgress();
    final ter = inspection.terrometro.getProgress();
    final toq = inspection.toquePasso.getProgress();

    // Add +1 to total items for the Identificação photo
    int totalItems =
        meg.total +
        mic.total +
        ttr.total +
        hip.total +
        ter.total +
        toq.total +
        1;

    // Check if identificacaoUrl is not empty
    int identCompleted = inspection.identificacaoUrl.isNotEmpty ? 1 : 0;

    int completedItems =
        meg.completed +
        mic.completed +
        ttr.completed +
        hip.completed +
        ter.completed +
        toq.completed +
        identCompleted;

    // Must have at least 1 item, and all items must be complete
    return totalItems > 0 && totalItems == completedItems;
  }

  // --- FIX: Added BuildContext as a parameter to use SnackBars safely in a StatelessWidget ---
  Future<void> _generateAndUploadReport(
    BuildContext context,
    Plant plant,
    UFV ufv,
  ) async {
    try {
      // 1. Gera o PDF na memória (como Uint8List)
      Uint8List pdfBytes = await PdfService.generatePdfBytes(ufv);

      // 2. Faz upload para o SUPABASE
      String pdfDownloadUrl = await SupabaseStorageService.uploadPdfBytes(
        pdfBytes,
        plant.id,
        ufv.id,
      );

      if (pdfDownloadUrl.isNotEmpty) {
        // 3. Salva a URL pública gerada no FIREBASE FIRESTORE
        await FirebaseFirestore.instance
            .collection('plants')
            .doc(plant.id)
            .update({'ufvs.${ufv.id}.reportUrl': pdfDownloadUrl});

        // --- FIX: Use context.mounted ---
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sucesso! Relatório salvo e linkado na nuvem.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception("Falha ao gerar URL pública do Supabase.");
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar relatório: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickIdentificacaoImage(
    BuildContext context,
    FullInspection inspection,
  ) async {
    final picker = ImagePicker();

    // Let the user choose between Camera or Gallery
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecionar Foto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Câmera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final XFile? photo = await picker.pickImage(source: source);
      if (photo != null) {
        // Save the path to the model
        inspection.identificacaoUrl = photo.path;

        // Save it to your local database
        await LocalSyncService.savePlantLocally(plant);

        // --- FIX: Use context.mounted ---
        if (context.mounted) {
          // Refresh the UI to update the progress counter
          (context as Element).markNeedsBuild();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto de identificação salva com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (ufv.measurements == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CustomHeader(title: 'Selecione a Inspeção'),
                const Expanded(
                  child: Center(child: Text('Nenhuma inspeção iniciada.')),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final FullInspection inspection = ufv.measurements!;
    // Calculate all progress
    final megProg = inspection.megohmetro.getProgress();
    final micProg = inspection.microohmimetro.getProgress();
    final ttrProg = inspection.ttr.getProgress();
    final hipProg = inspection.hipot.getProgress();
    final terProg = inspection.terrometro.getProgress();
    final toqProg = inspection.toquePasso.getProgress();

    final bool isComplete = _isInspectionFullyComplete(inspection);

    // HELPER FUNCTION: Only creates a button if the instrument has items to inspect
    List<Widget> buildInstrumentButtons() {
      List<Widget> buttons = [];

      buttons.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: InspectionButton(
            title: 'Identificação',
            completedCount: inspection.identificacaoUrl.isNotEmpty ? 1 : 0,
            totalCount: 1,
            onTap: () async {
              final didSave = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      IdentificacaoEntryScreen(plant: plant, ufv: ufv),
                ),
              );

              // If the user saved, refresh this screen to update the progress!
              if (didSave == true) {
                if (context.mounted) {
                  (context as Element).markNeedsBuild();
                }
              }
            },
          ),
        ),
      );

      void addButton(
        String title,
        InspectionProgress prog,
        Future<void> Function() onTap,
      ) {
        if (prog.total > 0) {
          buttons.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: InspectionButton(
                title: title,
                completedCount: prog.completed,
                totalCount: prog.total,
                onTap: () async {
                  await onTap();
                  if (context.mounted) {
                    (context as Element)
                        .markNeedsBuild(); // Refresh UI after returning
                  }
                },
              ),
            ),
          );
        }
      }

      addButton(
        'Megôhmetro',
        megProg,
        () => _openMegohmetroFolders(context, inspection.megohmetro),
      );
      addButton(
        'Microohmímetro',
        micProg,
        () => _openMicroohmimetroFolders(context, inspection.microohmimetro),
      );
      addButton('TTR', ttrProg, () => _openTtrFolders(context, inspection.ttr));
      addButton(
        'Hipot',
        hipProg,
        () => _openHipotFolders(context, inspection.hipot),
      );
      addButton(
        'Terrômetro',
        terProg,
        () => _openTerrometroFolders(context, inspection.terrometro),
      );
      addButton(
        'Toque-Passo',
        toqProg,
        () => _openToquePassoFolders(context, inspection.toquePasso),
      );

      return buttons;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(title: 'Instrumentos'),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: Text(
                ufv.name.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: buildInstrumentButtons(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isComplete
          ? FloatingActionButton.extended(
              onPressed: () async {
                // Show a loading indicator in case images are large
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gerando e Enviando PDF...')),
                );

                // --- FIX: Pass context, plant, and ufv to the function! ---
                await PdfService.generateAndSaveReport(ufv);
                await _generateAndUploadReport(context, plant, ufv);
              },
              backgroundColor: Colors.black,
              icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
              label: const Text(
                'Criar Relatório',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }

  // ==========================================
  // LEVEL 2 ROUTING: MEGOHMETRO
  // ==========================================
  Future<void> _openMegohmetroFolders(
    BuildContext context,
    Megohmetro meg,
  ) async {
    final List<String> megUnits = ['TΩ', 'GΩ', 'MΩ', 'kΩ'];

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (folderContext) => StatefulBuilder(
          builder: (context, setFolderState) {
            List<FolderOption> folders = [];

            if (meg.transformador != null) {
              final prog = meg.transformador!.getProgress();
              folders.add(
                FolderOption(
                  title: 'Transformador',
                  completedCount: prog.completed,
                  totalCount: prog.total,
                  onTap: () async {
                    final didSave = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DynamicGroupEntryScreen(
                          title: 'Transformador',
                          dynamicGroup: meg.transformador!,
                          allowedUnits: megUnits,
                          instrumentType: 'Megohmetro',
                          plantId: plant.id,
                          ufvId: ufv.id,
                          ufv: ufv,
                        ),
                      ),
                    );

                    if (didSave == true) {
                      await LocalSyncService.savePlantLocally(plant);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Salvo localmente com sucesso!'),
                          ),
                        );
                        setFolderState(() {}); // Refresh Folder UI
                      }
                    }
                  },
                ),
              );
            }

            if (meg.terminacaoMufla.isNotEmpty) {
              int completed = meg.terminacaoMufla.values
                  .where((e) => e.isFullyComplete)
                  .length;
              folders.add(
                FolderOption(
                  title: 'Terminação Mufla',
                  completedCount: completed,
                  totalCount: meg.terminacaoMufla.length,
                  onTap: () async {
                    await _openPhaseGroupMap(
                      context,
                      'Terminação Mufla',
                      meg.terminacaoMufla,
                      megUnits,
                      'Megohmetro',
                    );
                    setFolderState(() {});
                  },
                ),
              );
            }

            if (meg.paraRaios.isNotEmpty) {
              int completed = meg.paraRaios.values
                  .where((e) => e.isFullyComplete)
                  .length;
              folders.add(
                FolderOption(
                  title: 'Para-Raios',
                  completedCount: completed,
                  totalCount: meg.paraRaios.length,
                  onTap: () async {
                    await _openPhaseGroupMap(
                      context,
                      'Para-Raios',
                      meg.paraRaios,
                      megUnits,
                      'Megohmetro',
                    );
                    setFolderState(() {});
                  },
                ),
              );
            }

            if (meg.seccionadora.isNotEmpty) {
              int completed = meg.seccionadora.values
                  .where((e) => e.isFullyComplete)
                  .length;
              folders.add(
                FolderOption(
                  title: 'Seccionadora',
                  completedCount: completed,
                  totalCount: meg.seccionadora.length,
                  onTap: () async {
                    await _openPhaseGroupMap(
                      context,
                      'Seccionadora',
                      meg.seccionadora,
                      megUnits,
                      'Megohmetro',
                    );
                    setFolderState(() {});
                  },
                ),
              );
            }

            if (meg.disjuntorReligador.isNotEmpty) {
              int completed = meg.disjuntorReligador.values
                  .where((e) => e.isFullyComplete)
                  .length;
              folders.add(
                FolderOption(
                  title: 'Disjuntor Religador',
                  completedCount: completed,
                  totalCount: meg.disjuntorReligador.length,
                  onTap: () async {
                    await _openPhaseGroupMap(
                      context,
                      'Disjuntor Religador',
                      meg.disjuntorReligador,
                      megUnits,
                      'Megohmetro',
                    );
                    setFolderState(() {});
                  },
                ),
              );
            }

            void addSinglePhaseGroup(String title, PhaseGroup group) {
              final prog = group.getProgress();
              folders.add(
                FolderOption(
                  title: title,
                  completedCount: prog.completed,
                  totalCount: prog.total,
                  onTap: () async {
                    final didSave = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PhaseGroupEntryScreen(
                          title: title,
                          phaseGroup: group,
                          allowedUnits: megUnits,
                          plantId: plant.id,
                          ufvId: ufv.id,
                          instrumentType: 'Megohmetro',
                          ufv: ufv,
                        ),
                      ),
                    );
                    if (didSave == true) {
                      await LocalSyncService.savePlantLocally(plant);
                      if (context.mounted) setFolderState(() {});
                    }
                  },
                ),
              );
            }

            if (meg.transformadorCorrente != null) {
              addSinglePhaseGroup(
                'Transformador de Corrente',
                meg.transformadorCorrente!,
              );
            }

            return DynamicFolderScreen(title: 'Megôhmetro', options: folders);
          },
        ),
      ),
    );
  }

  // ==========================================
  // LEVEL 2 ROUTING: MICROOHMIMETRO
  // ==========================================
  Future<void> _openMicroohmimetroFolders(
    BuildContext context,
    Microohmimetro micro,
  ) async {
    final List<String> microUnits = ['mΩ', 'µΩ', 'Ω'];

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (folderContext) => StatefulBuilder(
          builder: (context, setFolderState) {
            List<FolderOption> folders = [];

            if (micro.transformador.isNotEmpty) {
              int completed = micro.transformador.values
                  .where((e) => e.isFullyComplete)
                  .length;
              folders.add(
                FolderOption(
                  title: 'Transformador',
                  completedCount: completed,
                  totalCount: micro.transformador.length,
                  onTap: () async {
                    await _openDynamicGroupMap(
                      context,
                      'Transformador',
                      micro.transformador,
                      microUnits,
                      'Microohmimetro',
                    );
                    setFolderState(() {});
                  },
                ),
              );
            }

            if (micro.continuidadeMalha.isNotEmpty) {
              int completed = micro.continuidadeMalha.values
                  .where((e) => e.isFullyComplete)
                  .length;
              folders.add(
                FolderOption(
                  title: 'Continuidade Malha',
                  completedCount: completed,
                  totalCount: micro.continuidadeMalha.length,
                  onTap: () async {
                    await _openDynamicGroupMap(
                      context,
                      'Continuidade Malha',
                      micro.continuidadeMalha,
                      microUnits,
                      'Microohmimetro',
                    );
                    setFolderState(() {});
                  },
                ),
              );
            }

            if (micro.seccionadora.isNotEmpty) {
              int completed = micro.seccionadora.values
                  .where((e) => e.isFullyComplete)
                  .length;
              folders.add(
                FolderOption(
                  title: 'Seccionadora',
                  completedCount: completed,
                  totalCount: micro.seccionadora.length,
                  onTap: () async {
                    await _openPhaseGroupMap(
                      context,
                      'Seccionadora',
                      micro.seccionadora,
                      microUnits,
                      'Microohmimetro',
                    );
                    setFolderState(() {});
                  },
                ),
              );
            }

            if (micro.disjuntorReligador.isNotEmpty) {
              int completed = micro.disjuntorReligador.values
                  .where((e) => e.isFullyComplete)
                  .length;
              folders.add(
                FolderOption(
                  title: 'Disjuntor Religador',
                  completedCount: completed,
                  totalCount: micro.disjuntorReligador.length,
                  onTap: () async {
                    await _openPhaseGroupMap(
                      context,
                      'Disjuntor Religador',
                      micro.disjuntorReligador,
                      microUnits,
                      'Microohmimetro',
                    );
                    setFolderState(() {});
                  },
                ),
              );
            }

            return DynamicFolderScreen(
              title: 'Microohmímetro',
              options: folders,
            );
          },
        ),
      ),
    );
  }

  // ==========================================
  // LEVEL 2 ROUTING: TTR
  // ==========================================
  Future<void> _openTtrFolders(BuildContext context, Ttr ttr) async {
    final List<String> ttrUnits = ['V/V', 'kV/V'];

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (folderContext) => StatefulBuilder(
          builder: (context, setFolderState) {
            List<FolderOption> folders = [];

            if (ttr.transformador.isNotEmpty) {
              int completed = ttr.transformador.values
                  .where((e) => e.isFullyComplete)
                  .length;
              folders.add(
                FolderOption(
                  title: 'Transformador',
                  completedCount: completed,
                  totalCount: ttr.transformador.length,
                  onTap: () async {
                    await _openDynamicGroupMap(
                      context,
                      'Transformador',
                      ttr.transformador,
                      ttrUnits,
                      'TTR',
                    );
                    setFolderState(() {});
                  },
                ),
              );
            }

            void addSinglePhaseGroup(String title, PhaseGroup group) {
              final prog = group.getProgress();
              folders.add(
                FolderOption(
                  title: title,
                  completedCount: prog.completed,
                  totalCount: prog.total,
                  onTap: () async {
                    final didSave = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PhaseGroupEntryScreen(
                          title: title,
                          phaseGroup: group,
                          allowedUnits: ttrUnits,
                          instrumentType: 'TTR',
                          plantId: plant.id,
                          ufvId: ufv.id,
                          ufv: ufv,
                        ),
                      ),
                    );
                    if (didSave == true) {
                      await LocalSyncService.savePlantLocally(plant);
                      if (context.mounted) setFolderState(() {});
                    }
                  },
                ),
              );
            }

            if (ttr.transformadorPotencial != null) {
              addSinglePhaseGroup(
                'Transformador de Potencial',
                ttr.transformadorPotencial!,
              );
            }
            if (ttr.transformadorCorrente != null) {
              addSinglePhaseGroup(
                'Transformador de Corrente',
                ttr.transformadorCorrente!,
              );
            }
            return DynamicFolderScreen(title: 'TTR', options: folders);
          },
        ),
      ),
    );
  }

  // ==========================================
  // LEVEL 2 ROUTING: HIPOT
  // ==========================================
  Future<void> _openHipotFolders(BuildContext context, Hipot hipot) async {
    final List<String> hipotUnits = ['kV', 'V', 'µA', 'mA'];

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (folderContext) => StatefulBuilder(
          builder: (context, setFolderState) {
            List<FolderOption> folders = [];

            if (hipot.caboMediaTensao.isNotEmpty) {
              int completed = hipot.caboMediaTensao.values
                  .where((e) => e.isFullyComplete)
                  .length;
              folders.add(
                FolderOption(
                  title: "Cabo Média Tensão",
                  completedCount: completed,
                  totalCount: hipot.caboMediaTensao.length,
                  onTap: () async {
                    await _openPhaseGroupMap(
                      context,
                      'Cabo Média Tensão',
                      hipot.caboMediaTensao,
                      hipotUnits,
                      'Hipot',
                    );
                    setFolderState(() {});
                  },
                ),
              );
            }

            return DynamicFolderScreen(title: 'Hipot', options: folders);
          },
        ),
      ),
    );
  }

  // ==========================================
  // LEVEL 2 ROUTING: TERROMETRO
  // ==========================================
  Future<void> _openTerrometroFolders(
    BuildContext context,
    Terrometro ter,
  ) async {
    final List<String> terUnits = ['Ω', 'kΩ'];

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (folderContext) => StatefulBuilder(
          builder: (context, setFolderState) {
            List<FolderOption> folders = [];

            if (ter.subestacao != null) {
              final prog = ter.subestacao!.getProgress();
              folders.add(
                FolderOption(
                  title: 'Subestação',
                  completedCount: prog.completed,
                  totalCount: prog.total,
                  onTap: () async {
                    final didSave = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DynamicGroupEntryScreen(
                          title: 'Subestação',
                          dynamicGroup: ter.subestacao!,
                          allowedUnits: terUnits,
                          instrumentType: 'Terrometro',
                          plantId: plant.id,
                          ufvId: ufv.id,
                          ufv: ufv,
                        ),
                      ),
                    );
                    if (didSave == true) {
                      await LocalSyncService.savePlantLocally(plant);
                      if (context.mounted) setFolderState(() {});
                    }
                  },
                ),
              );
            }

            if (ter.transformadores.isNotEmpty) {
              int completed = ter.transformadores.values
                  .where((e) => e.isFullyComplete)
                  .length;
              folders.add(
                FolderOption(
                  title: 'Transformadores',
                  completedCount: completed,
                  totalCount: ter.transformadores.length,
                  onTap: () async {
                    await _openDynamicGroupMap(
                      context,
                      'Transformadores',
                      ter.transformadores,
                      terUnits,
                      'Terrometro',
                    );
                    setFolderState(() {});
                  },
                ),
              );
            }

            return DynamicFolderScreen(title: 'Terrômetro', options: folders);
          },
        ),
      ),
    );
  }

  // ==========================================
  // LEVEL 2 ROUTING: TOQUE-PASSO
  // ==========================================
  Future<void> _openToquePassoFolders(
    BuildContext context,
    ToquePasso toq,
  ) async {
    final List<String> toqUnits = ['V', 'kV'];

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (folderContext) => StatefulBuilder(
          builder: (context, setFolderState) {
            List<FolderOption> folders = [];

            void addDynamicMapGroup(
              String title,
              Map<String, DynamicGroup> groupMap,
            ) {
              if (groupMap.isNotEmpty) {
                int completed = groupMap.values
                    .where((e) => e.isFullyComplete)
                    .length;
                folders.add(
                  FolderOption(
                    title: title,
                    completedCount: completed,
                    totalCount: groupMap.length,
                    onTap: () async {
                      await _openDynamicGroupMap(
                        context,
                        title,
                        groupMap,
                        toqUnits,
                        'Toque-Passo',
                      );
                      setFolderState(() {});
                    },
                  ),
                );
              }
            }

            addDynamicMapGroup('Subestação', toq.subestacao);
            addDynamicMapGroup('Cercamento / Abrigo', toq.cercamento);
            addDynamicMapGroup('SKID', toq.skid);

            return DynamicFolderScreen(title: 'Toque-Passo', options: folders);
          },
        ),
      ),
    );
  }

  // ==========================================
  // LEVEL 3 ROUTING HELPERS
  // ==========================================

  Future<void> _openPhaseGroupMap(
    BuildContext context,
    String title,
    Map<String, PhaseGroup> phaseMap,
    List<String> allowedUnits,
    String instrumentType,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (folderContext) => StatefulBuilder(
          builder: (context, setFolderState) {
            List<FolderOption> options = phaseMap.entries.map((entry) {
              final prog = entry.value.getProgress();
              return FolderOption(
                title: entry.key,
                completedCount: prog.completed,
                totalCount: prog.total,
                onTap: () async {
                  final didSave = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PhaseGroupEntryScreen(
                        title: entry.key,
                        phaseGroup: entry.value,
                        allowedUnits: allowedUnits,
                        instrumentType: instrumentType,
                        plantId: plant.id,
                        ufvId: ufv.id,
                        ufv: ufv,
                      ),
                    ),
                  );

                  if (didSave == true) {
                    await LocalSyncService.savePlantLocally(plant);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Salvo localmente com sucesso!'),
                        ),
                      );
                      setFolderState(() {});
                    }
                  }
                },
              );
            }).toList();

            return DynamicFolderScreen(title: title, options: options);
          },
        ),
      ),
    );
  }

  Future<void> _openDynamicGroupMap(
    BuildContext context,
    String title,
    Map<String, DynamicGroup> dynMap,
    List<String> allowedUnits,
    String instrumentType,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (folderContext) => StatefulBuilder(
          builder: (context, setFolderState) {
            List<FolderOption> options = dynMap.entries.map((entry) {
              final prog = entry.value.getProgress();
              return FolderOption(
                title: entry.key,
                completedCount: prog.completed,
                totalCount: prog.total,
                onTap: () async {
                  final didSave = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DynamicGroupEntryScreen(
                        title: entry.key,
                        dynamicGroup: entry.value,
                        allowedUnits: allowedUnits,
                        instrumentType: instrumentType,
                        plantId: plant.id,
                        ufvId: ufv.id,
                        ufv: ufv,
                      ),
                    ),
                  );

                  if (didSave == true) {
                    await LocalSyncService.savePlantLocally(plant);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Salvo localmente com sucesso!'),
                        ),
                      );
                      setFolderState(() {});
                    }
                  }
                },
              );
            }).toList();

            return DynamicFolderScreen(title: title, options: options);
          },
        ),
      ),
    );
  }
}
