import 'package:flutter/material.dart';
import 'package:sigma_app/models/plant_model.dart';

// Temporary Dataset
final List<Plant> plants = [
  Plant(id: '1', name: 'CAIAPÔNIA'),
  Plant(id: '2', name: 'PARANOÁ'),
  Plant(id: '3', name: 'RIO BONITO'),
  Plant(id: '4', name: 'RIO MONTE'),
];

class SelectPlant extends StatelessWidget {
  const SelectPlant({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 15),
            Container(
              color: Color(0xFFD9D9D9),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                  const SizedBox(width: 20),
                  const Text(
                    'Selecione a Usina',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: plants.length,
                itemBuilder: (context, index) {
                  final plant = plants[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildPlantButton(context, plant),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantButton(BuildContext context, Plant plant) {
    return Material(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {
          print("Clickedon ${plant.name}");
          // Nagita to other pages later
        },
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
