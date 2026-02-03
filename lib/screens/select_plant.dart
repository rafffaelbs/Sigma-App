import 'package:flutter/material.dart';
import 'package:sigma_app/models/plant_model.dart';
import 'package:sigma_app/screens/select_ufv.dart';
import 'package:sigma_app/widgets/custom_header.dart';
import 'package:sigma_app/widgets/plant_button.dart';

// Temporary Dataset
final List<Plant> plants = [
  Plant(id: '1', name: 'CAIAPÔNIA', ufvs: ['UFV 1.1', 'UFV 1.2', 'UFV 1.3', 'UFV 1.4']),
  Plant(id: '2', name: 'PARANOÁ', ufvs: ['UFV 2.1', 'UFV 2.2', 'UFV 2.3', 'UFV 2.4']),
  Plant(id: '3', name: 'RIO BONITO', ufvs: ['UFV 3.1', 'UFV 3.2', 'UFV 3.3', 'UFV 3.4']),
  Plant(id: '4', name: 'RIO MONTE', ufvs: ['UFV 4.1', 'UFV 4.2', 'UFV 4.3', 'UFV 4.4']),
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
            CustomHeader(title: 'Selecione a Usina'),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: plants.length,
                itemBuilder: (context, index) {
                  final plant = plants[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: PlantButton(
                      plant: plant,
                      onTap: () => {
                        print('Clicou na planta ${plant.name}'),
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectUfv(plant: plant),
                          ),
                        ),
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
