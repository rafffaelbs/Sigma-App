import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(home: MainPage(), debugShowCheckedModeBanner: false),
  );
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

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
              _buildMenuButton(
                icon: Icons.factory,
                label: 'Usinas',
                onTap: () => print('Usinas clicked'),
              ),
              const SizedBox(height: 20),
              _buildMenuButton(
                icon: Icons.settings,
                label: 'Configurações',
                onTap: () => print('Settings clicked'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.hardEdge,

      child: InkWell(
        onTap: onTap,
        splashColor: Colors.grey[500],

        child: Container(
          width: 250,
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(icon, size: 60, color: Colors.black),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
