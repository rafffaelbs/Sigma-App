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

  const UfvButton({super.key, required this.ufv, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          child: Text(
            ufv.toUpperCase(),
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
