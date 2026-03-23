import 'package:flutter/material.dart';
import 'package:sigma_app/screens/select_plant.dart';
import 'package:sigma_app/widgets/sync_button.dart';
import '../widgets/menu_button.dart';

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

              MenuButton(
                icon: Icons.settings,
                label: 'Configurações',
                onTap: () => print('Settings clicked'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [const SendToFirebase(), const SyncButtonWidget()],
        ),
      ),
    );
  }
}
