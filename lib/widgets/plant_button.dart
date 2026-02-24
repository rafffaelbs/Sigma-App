import 'package:flutter/material.dart';
import 'package:sigma_app/models/plant_model.dart';

class PlantButton extends StatelessWidget {
  final Plant plant;
  final VoidCallback? onTap;

  const PlantButton({super.key, required this.plant, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          child: Text(
            plant.name.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

class UfvButton extends StatelessWidget {
  final String ufv;
  final VoidCallback? onTap;
  final VoidCallback? onConfigTap;
  final bool showConfigButton;

  const UfvButton({super.key, required this.ufv, this.onTap, this.onConfigTap, this.showConfigButton = true});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            children: [
              const SizedBox(width: 32),
              Expanded(
                child: Text(
                  ufv.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ),
              
              if (showConfigButton == true)
                Hero(
                  tag: 'config_hero_$ufv',
                  child: Material(
                    color: Colors.transparent,
                    child: IconButton(
                      icon: const Icon(Icons.settings),
                      color: Colors.black54,
                      onPressed: onConfigTap,
                      tooltip: 'Editar Dados UFV',
                      constraints: const BoxConstraints(),
                      splashRadius: 24,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class InspectionButton extends StatelessWidget {
  final String title;
  final int completedCount;
  final int totalCount;
  final VoidCallback? onTap;

  const InspectionButton({
    super.key,
    required this.title,
    required this.completedCount,
    required this.totalCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Determine the state
    // We make sure totalCount > 0 so a 0/0 list doesn't show as "Complete"
    final bool isComplete = completedCount == totalCount && totalCount > 0;

    // 2. Set colors based on the state
    final Color backgroundColor = isComplete ? const Color(0xFF222222) : Colors.grey[300]!;
    final Color textColor = isComplete ? Colors.white : Colors.black87;
    final Color progressColor = isComplete ? Colors.white70 : Colors.black54;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(30), // Increased radius for pill shape
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Pushes text to opposite edges
            children: [
              // Measurement Title
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.w500, // Slightly lighter than bold to match image
                  fontSize: 16,
                  color: textColor,
                  letterSpacing: 0.5,
                ),
              ),
              
              // Progress Fraction (e.g., "1/3")
              Text(
                '$completedCount/$totalCount',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: progressColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}