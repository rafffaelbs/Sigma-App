import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  // Define the data this widget needs
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const MenuButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // This is the code extracted from your _buildMenuButton
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