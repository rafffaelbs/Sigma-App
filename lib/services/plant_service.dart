import 'package:sigma_app/models/plant_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlantService {
  // Simulating a Database
  static final List<Plant> _mockDatabase = [
    Plant(
      id: '1',
      name: 'CAIAPÔNIA',
      local: 'CAIAPÔNIA-GO',
      ufvs: [
        UFV(
          name: 'UFV 1.1',
          id: '101',
          fechamento: 'Delta',
          marca: 'WEG',
          nSerie: 'SN001',
          fatorK: 1.0,
          tensaoPrimaria: 13.8,
          relacaoNominal: 60.0,
          tensaoSecundaria: 0.38,
          potenciaKva: 500.0,
          impedancia: 4.5,
          frequencia: 60.0,
          peso: 1200.0,
          ip: 54,
          dataFabricacao: '2023-01-10',
        ),
        UFV(
          name: 'UFV 1.2',
          id: '102',
          fechamento: 'Estrela',
          marca: 'ABB',
          nSerie: 'SN002',
          fatorK: 1.0,
          tensaoPrimaria: 13.8,
          relacaoNominal: 60.0,
          tensaoSecundaria: 0.38,
          potenciaKva: 500.0,
          impedancia: 4.5,
          frequencia: 60.0,
          peso: 1250.0,
          ip: 54,
          dataFabricacao: '2023-01-15',
        ),
        UFV(
          name: 'UFV 1.3',
          id: '103',
          fechamento: 'Delta',
          marca: 'Siemens',
          nSerie: 'SN003',
          fatorK: 1.0,
          tensaoPrimaria: 13.8,
          relacaoNominal: 60.0,
          tensaoSecundaria: 0.38,
          potenciaKva: 750.0,
          impedancia: 5.0,
          frequencia: 60.0,
          peso: 1500.0,
          ip: 65,
          dataFabricacao: '2023-02-01',
        ),
      ],
    ),
    Plant(
      id: '2',
      local: 'PARANOÁ-GO',
      name: 'PARANOÁ',
      ufvs: [
        UFV(
          name: 'UFV 1.1',
          id: '201',
          fechamento: 'Estrela',
          marca: 'WEG',
          nSerie: 'SN004',
          fatorK: 1.0,
          tensaoPrimaria: 13.8,
          relacaoNominal: 60.0,
          tensaoSecundaria: 0.22,
          potenciaKva: 300.0,
          impedancia: 4.0,
          frequencia: 60.0,
          peso: 900.0,
          ip: 54,
          dataFabricacao: '2022-11-20',
        ),
        UFV(
          name: 'UFV 1.2',
          id: '202',
          fechamento: 'Estrela',
          marca: 'WEG',
          nSerie: 'SN005',
          fatorK: 1.0,
          tensaoPrimaria: 13.8,
          relacaoNominal: 60.0,
          tensaoSecundaria: 0.22,
          potenciaKva: 300.0,
          impedancia: 4.0,
          frequencia: 60.0,
          peso: 900.0,
          ip: 54,
          dataFabricacao: '2022-11-22',
        ),
        UFV(
          name: 'UFV 1.3',
          id: '203',
          fechamento: 'Estrela',
          marca: 'WEG',
          nSerie: 'SN006',
          fatorK: 1.0,
          tensaoPrimaria: 13.8,
          relacaoNominal: 60.0,
          tensaoSecundaria: 0.22,
          potenciaKva: 300.0,
          impedancia: 4.0,
          frequencia: 60.0,
          peso: 900.0,
          ip: 54,
          dataFabricacao: '2022-11-25',
        ),
      ],
    ),
  ];

  List<Plant> getPlants() {
    return _mockDatabase;
  }

  Plant getPlantById(String id) {
    return _mockDatabase.firstWhere((plant) => plant.id == id);
  }

  Future<void> uploadSeedData() async {
    final CollectionReference plantsRef = FirebaseFirestore.instance.collection(
      'plants',
    );

    for (final plant in _mockDatabase) {
      final plantData = plant.toMap();

      await plantsRef.doc(plant.id).set(plantData);

      print('Uploaded plant: ${plant.name}');
    }
    print('All data uploaded');
  }

  Future<void> updateUfv(String plantId, UFV updatedUfv) async {
    // Simulating Network Delay
    await Future.delayed(const Duration(seconds: 1));

    // Find the Plant
    final plantIndex = _mockDatabase.indexWhere((p) => p.id == plantId);
    if (plantIndex != -1) {
      // Find the UFV inside that plant
      final plant = _mockDatabase[plantIndex];
      final ufvIndex = plant.ufvs.indexWhere((u) => u.id == updatedUfv.id);

      if (ufvIndex != -1) {
        // Replace the old UFV with the new one
        plant.ufvs[ufvIndex] = updatedUfv;
        print('Saved to Fake Databse: ${updatedUfv.marca}');
      }
    }
  }
}
