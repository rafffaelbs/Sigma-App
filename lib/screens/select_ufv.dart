import 'package:flutter/material.dart';
import 'package:sigma_app/models/plant_model.dart';
import 'package:sigma_app/widgets/custom_header.dart';
import 'package:sigma_app/widgets/plant_button.dart';

class SelectUfv extends StatelessWidget {
  final Plant plant;

  const SelectUfv({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 15),
            CustomHeader(title: 'Selecione a UFV'),
            SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFF),
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: Text(
                plant.name.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: plant.ufvs.length,
                itemBuilder: (context, index) {
                  final ufv = plant.ufvs[index];

                  return Padding(
                    padding: const EdgeInsetsGeometry.only(bottom: 16),
                    child: UfvButton(
                      ufv: ufv,
                      onTap: () => {print('Clicou na UFV ${ufv}')},
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
