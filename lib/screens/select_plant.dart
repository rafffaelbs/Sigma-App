import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Ensure Firestore is imported
import 'package:sigma_app/screens/select_ufv.dart';
import 'package:sigma_app/widgets/custom_header.dart';
import 'package:sigma_app/widgets/plant_button.dart';
// Ensure your Plant model is imported correctly
import '../models/plant_model.dart'; 

class SelectPlant extends StatelessWidget {
  const SelectPlant({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(title: 'Selecione a Usina'),
            
            // Replaced the simple ListView with a StreamBuilder
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                // 1. Point the stream to your 'plants' collection
                stream: FirebaseFirestore.instance.collection('plants').snapshots(),
                builder: (context, snapshot) {
                  
                  // 2. Handle connection errors
                  if (snapshot.hasError) {
                    return const Center(child: Text('Erro ao carregar as usinas.'));
                  }

                  // 3. Handle loading state
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // 4. Handle empty database state
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Nenhuma usina encontrada no banco de dados.'));
                  }

                  // 5. Convert Firestore documents into your Plant objects
                  final plants = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    // Assuming your Plant.fromMap handles the ID correctly inside the map
                    return Plant.fromMap(data); 
                  }).toList();

                  // 6. Render your UI exactly as before
                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: plants.length,
                    itemBuilder: (context, index) {
                      final plant = plants[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: PlantButton(
                          plant: plant,
                          onTap: () {
                            print('Clicou na planta ${plant.name}');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SelectUfv(plant: plant),
                              ),
                            );
                          },
                        ),
                      );
                    },
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