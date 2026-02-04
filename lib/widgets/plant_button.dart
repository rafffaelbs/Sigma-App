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
