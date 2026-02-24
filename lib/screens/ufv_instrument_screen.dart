import 'package:flutter/material.dart';
import 'package:sigma_app/models/plant_model.dart';
import 'package:sigma_app/models/measurements.dart';
import 'package:sigma_app/screens/dynamic_folder_screen.dart';
import 'package:sigma_app/screens/phase_group_entry_screen.dart';
import 'package:sigma_app/screens/dynamic_group_entry_screen.dart'; // IMPORTANT: Import the new screen
import 'package:sigma_app/widgets/custom_header.dart';
import 'package:sigma_app/widgets/plant_button.dart';

class UfvInstrumentsScreen extends StatelessWidget {
  final UFV ufv;

  const UfvInstrumentsScreen({super.key, required this.ufv});

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
                      onTap: () => _openMegohmetroFolders(
                        context,
                        inspection.megohmetro,
                      ),
                    ),
                  ),

                  // MICROOHMIMETRO BUTTON (Fixed!)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: InspectionButton(
                      title: 'Microohmímetro',
                      completedCount: microohmimetroProgress.completed,
                      totalCount: microohmimetroProgress.total,
                      onTap: () => _openMicroohmimetroFolders(
                        context,
                        inspection.microohmimetro,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // LEVEL 2 ROUTING: MEGOHMETRO
  // ==========================================
  void _openMegohmetroFolders(BuildContext context, Megohmetro meg) {
    List<FolderOption> folders = [];

    if (meg.transformador.readings.isNotEmpty) {
      final prog = meg.transformador.getProgress();
      folders.add(
        FolderOption(
          title: 'Transformador',
          completedCount: prog.completed,
          totalCount: prog.total,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DynamicGroupEntryScreen(
                title: 'Transformador',
                dynamicGroup: meg.transformador,
              ),
            ),
          ).then((_) => (context as Element).markNeedsBuild()),
        ),
      );
    }

    if (meg.terminacaoMufla.isNotEmpty) {
      // For groups of equipment, we count how many are fully complete
      int completed = meg.terminacaoMufla.values
          .where((e) => e.isFullyComplete)
          .length;
      folders.add(
        FolderOption(
          title: 'Terminação Mufla',
          completedCount: completed,
          totalCount: meg.terminacaoMufla.length,
          onTap: () => _openPhaseGroupMap(
            context,
            'Terminação Mufla',
            meg.terminacaoMufla,
          ),
        ),
      );
    }

    // Do the exact same thing for paraRaios, seccionadora, etc.

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            DynamicFolderScreen(title: 'Megôhmetro', options: folders),
      ),
    ).then((_) => (context as Element).markNeedsBuild());
  }

  // ==========================================
  // LEVEL 2 ROUTING: MICROOHMIMETRO
  // ==========================================
  void _openMicroohmimetroFolders(BuildContext context, Microohmimetro micro) {
    List<FolderOption> folders = [];

    // 1. Transformador (DynamicGroup Map)
    if (micro.transformador.isNotEmpty) {
      int completed = micro.transformador.values
          .where((e) => e.isFullyComplete)
          .length;
      folders.add(
        FolderOption(
          title: 'Transformador', // Fixed title
          completedCount: completed,
          totalCount: micro.transformador.length,
          // Using _openDynamicGroupMap instead of _openPhaseGroupMap
          onTap: () => _openDynamicGroupMap(
            context,
            'Transformador',
            micro.transformador,
          ),
        ),
      );
    }

    // 2. Continuidade Malha (DynamicGroup Map)
    if (micro.continuidadeMalha.isNotEmpty) {
      int completed = micro.continuidadeMalha.values
          .where((e) => e.isFullyComplete)
          .length;
      folders.add(
        FolderOption(
          title: 'Continuidade Malha', // Fixed title
          completedCount: completed,
          totalCount: micro.continuidadeMalha.length,
          // Using _openDynamicGroupMap instead of _openPhaseGroupMap
          onTap: () => _openDynamicGroupMap(
            context,
            'Continuidade Malha',
            micro.continuidadeMalha,
          ),
        ),
      );
    }

    // 3. Seccionadora (PhaseGroup Map)
    if (micro.seccionadora.isNotEmpty) {
      int completed = micro.seccionadora.values
          .where((e) => e.isFullyComplete)
          .length;
      folders.add(
        FolderOption(
          title: 'Seccionadora',
          completedCount: completed,
          totalCount: micro.seccionadora.length,
          // This one correctly uses _openPhaseGroupMap!
          onTap: () =>
              _openPhaseGroupMap(context, 'Seccionadora', micro.seccionadora),
        ),
      );
    }

    // 4. Disjuntor Religador (PhaseGroup Map)
    if (micro.disjuntorReligador.isNotEmpty) {
      int completed = micro.disjuntorReligador.values
          .where((e) => e.isFullyComplete)
          .length;
      folders.add(
        FolderOption(
          title: 'Disjuntor Religador',
          completedCount: completed,
          totalCount: micro.disjuntorReligador.length,
          // This one correctly uses _openPhaseGroupMap!
          onTap: () => _openPhaseGroupMap(
            context,
            'Disjuntor Religador',
            micro.disjuntorReligador,
          ),
        ),
      );
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DynamicFolderScreen(
          title: 'Microohmímetro',
          options: folders,
        ), // Fixed screen title
      ),
    ).then((_) => (context as Element).markNeedsBuild());
  }
  // ==========================================
  // LEVEL 3 ROUTING HELPERS
  // ==========================================

  // For navigating into standard A/B/C maps (Muflas, Seccionadoras)
  void _openPhaseGroupMap(
    BuildContext context,
    String title,
    Map<String, PhaseGroup> phaseMap,
  ) {
    List<FolderOption> options = phaseMap.entries.map((entry) {
      final prog = entry.value
          .getProgress(); // Get phase-level progress (e.g., 1/3)
      return FolderOption(
        title: entry.key,
        completedCount: prog.completed,
        totalCount: prog.total,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PhaseGroupEntryScreen(
                title: entry.key,
                phaseGroup: entry.value,
              ),
            ),
          ).then((_) => (context as Element).markNeedsBuild());
        },
      );
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DynamicFolderScreen(title: title, options: options),
      ),
    ).then((_) => (context as Element).markNeedsBuild());
  }

  // Level 3 Helper for Dynamic Maps (like H1-H3, X1-X0)
  void _openDynamicGroupMap(
    BuildContext context,
    String title,
    Map<String, DynamicGroup> dynMap,
  ) {
    List<FolderOption> options = dynMap.entries.map((entry) {
      final prog = entry.value
          .getProgress(); // Calculate completion (e.g., 1/3)

      return FolderOption(
        title: entry.key,
        completedCount: prog.completed,
        totalCount: prog.total,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DynamicGroupEntryScreen(
                title: entry.key,
                dynamicGroup: entry.value,
              ),
            ),
          ).then((_) => (context as Element).markNeedsBuild());
        },
      );
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DynamicFolderScreen(title: title, options: options),
      ),
    ).then((_) => (context as Element).markNeedsBuild());
  }
}
