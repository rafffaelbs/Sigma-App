import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sigma_app/models/plant_model.dart';
import 'package:sigma_app/models/measurements.dart';
import 'package:sigma_app/screens/dynamic_folder_screen.dart';
import 'package:sigma_app/screens/phase_group_entry_screen.dart';
import 'package:sigma_app/screens/dynamic_group_entry_screen.dart';
import 'package:sigma_app/services/local_sync_service.dart';
import 'package:sigma_app/services/pdf_service.dart';
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

    int totalItems =
        meg.total + mic.total + ttr.total + hip.total + ter.total + toq.total;
    int completedItems =
        meg.completed +
        mic.completed +
        ttr.completed +
        hip.completed +
        ter.completed +
        toq.completed;

    // Must have at least 1 item, and all items must be complete
    return totalItems > 0 && totalItems == completedItems;
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
    final megohmetroProgress = inspection.megohmetro.getProgress();
    final microohmimetroProgress = inspection.microohmimetro.getProgress();

    final bool isComplete = _isInspectionFullyComplete(inspection);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(title: 'Instrumentos: ${ufv.name}'),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // MEGOHMETRO BUTTON
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: InspectionButton(
                      title: 'Megôhmetro',
                      completedCount: megohmetroProgress.completed,
                      totalCount: megohmetroProgress.total,
                      onTap: () async {
                        await _openMegohmetroFolders(
                          context,
                          inspection.megohmetro,
                        );
                        (context as Element)
                            .markNeedsBuild(); // Refresh this root screen
                      },
                    ),
                  ),

                  // MICROOHMIMETRO BUTTON
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: InspectionButton(
                      title: 'Microohmímetro',
                      completedCount: microohmimetroProgress.completed,
                      totalCount: microohmimetroProgress.total,
                      onTap: () async {
                        await _openMicroohmimetroFolders(
                          context,
                          inspection.microohmimetro,
                        );
                        (context as Element)
                            .markNeedsBuild(); // Refresh this root screen
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isComplete
          ? FloatingActionButton.extended(
              onPressed: () async {
                // Show a loading indicator in case images are large
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Gerando PDF...')));
                await PdfService.generateAndSaveReport(ufv);
              },
              backgroundColor: Colors.black,
              icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
              label: const Text(
                'Criar Relatório',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null, // Shows nothing if not 100% complete
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

            if (meg.transformador.readings.isNotEmpty) {
              final prog = meg.transformador.getProgress();
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
                          dynamicGroup: meg.transformador,
                          allowedUnits: megUnits,
                          plantId: plant.id,
                          ufvId: ufv.id,
                        ),
                      ),
                    );

                    if (didSave == true) {
                      await LocalSyncService.saveUfvLocally(ufv);
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
                    );
                    setFolderState(
                      () {},
                    ); // Refresh Folder UI when returning from sub-folder
                  },
                ),
              );
            }

            // ADD MORE MEGOHMETRO FOLDERS HERE LATER (Para Raios, etc.)

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
  // LEVEL 3 ROUTING HELPERS
  // ==========================================

  Future<void> _openPhaseGroupMap(
    BuildContext context,
    String title,
    Map<String, PhaseGroup> phaseMap,
    List<String> allowedUnits,
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
                        plantId: plant.id,
                        ufvId: ufv.id,
                      ),
                    ),
                  );

                  if (didSave == true) {
                    await LocalSyncService.saveUfvLocally(ufv);
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
                        plantId: plant.id,
                        ufvId: ufv.id,
                      ),
                    ),
                  );

                  if (didSave == true) {
                    await LocalSyncService.saveUfvLocally(ufv);
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
