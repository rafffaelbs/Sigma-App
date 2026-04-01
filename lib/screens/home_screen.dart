import 'package:flutter/material.dart';
import 'package:sigma_app/screens/select_plant.dart';
import 'package:sigma_app/services/local_sync_service.dart';
import 'package:sigma_app/widgets/sync_button.dart';
import '../widgets/menu_button.dart';

// --- DEV FLAG: Set to true to show "Send to Firebase" button ---
const bool kShowDevButtons = true;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Relatórios',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 40),

              MenuButton(
                icon: Icons.factory,
                label: 'Usinas',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SelectPlant()),
                ),
              ),

              const SizedBox(height: 20),

              // --- Sync button as MenuButton (was "Configurações") ---
              MenuButton(
                icon: Icons.cloud_upload,
                label: 'Sincronizar',
                onTap: () async {
                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) =>
                        const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    await LocalSyncService.syncAllToFirebase();
                    Navigator.pop(context); // Close loading
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sincronização concluída com sucesso'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    Navigator.pop(context); // Close loading
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: kShowDevButtons
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [SendToFirebase(), SyncButtonWidget()],
              ),
            )
          : null,
    );
  }
}
