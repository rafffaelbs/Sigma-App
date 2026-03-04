import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sigma_app/screens/select_plant.dart';
import '../widgets/menu_button.dart';
// Make sure these paths match your actual project structure
import '../models/measurements.dart';
import '../models/plant_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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

              MenuButton(
                icon: Icons.factory,
                label: 'Usinas',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SelectPlant()),
                ),
              ),

              const SizedBox(height: 20),

              MenuButton(
                icon: Icons.settings,
                label: 'Configurações',
                onTap: () => print('Settings clicked'),
              ),

              const SizedBox(height: 40),
              const Divider(indent: 50, endIndent: 50),
              const SizedBox(height: 20),

              // DEV BUTTON: Upload Initial Data
              MenuButton(
                icon: Icons.cloud_upload,
                label: 'Upload UFV Paranoá',
                onTap: () => _uploadInitialDataToFirebase(context),
              ),
            ],
          ),
        ),
      ),
    );
  }



  // Extracted function to handle the data creation and upload
  Future<void> _uploadInitialDataToFirebase(BuildContext context) async {
    // 1. Show a loading message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Enviando dados para o Firebase...')),
    );

    try {
      // 2. Create the UFV data (Same as before)
      var paranoaMegohmetro = Megohmetro(
        transformador: DynamicGroup(
          readings: {
            "At Bt": MeasurementValue(),
            "At Massa": MeasurementValue(),
            "Bt Massa": MeasurementValue(),
          },
        ),
        terminacaoMufla: {
          "Mufla Poste": PhaseGroup(
            faseA: MeasurementValue(),
            faseB: MeasurementValue(),
            faseC: MeasurementValue(),
          ),
          "Mufla Entrada Cubiculo": PhaseGroup(
            faseA: MeasurementValue(),
            faseB: MeasurementValue(),
            faseC: MeasurementValue(),
          ),
        },
        paraRaios: {},
        seccionadora: {},
        disjuntorReligador: {},
        transformadorCorrente: PhaseGroup(
          faseA: MeasurementValue(),
          faseB: MeasurementValue(),
          faseC: MeasurementValue(),
        ),
      );

      var paranoaMicro = Microohmimetro(
        transformador: {
          "AT Delta Estrela": DynamicGroup(
            readings: {
              "H1-H3": MeasurementValue(),
            },
          ),
          "BT Delta Estrela": DynamicGroup(
            readings: {
              "X1-X0": MeasurementValue(),
            },
          ),
        },
        continuidadeMalha: {},
        seccionadora: {},
        disjuntorReligador: {},
      );

      var paranoaInspection = FullInspection(
        megohmetro: paranoaMegohmetro,
        microohmimetro: paranoaMicro,
        ttr: Ttr(
          transformador: {},
          transformadorPotencial: PhaseGroup(
            faseA: MeasurementValue(),
            faseB: MeasurementValue(),
            faseC: MeasurementValue(),
          ),
          transformadorCorrente: PhaseGroup(
            faseA: MeasurementValue(),
            faseB: MeasurementValue(),
            faseC: MeasurementValue(),
          ),
        ),
        hipot: Hipot(tests: {}),
        terrometro: Terrometro(
          subestacao: DynamicGroup(readings: {}),
          transformadores: {},
        ),
        toquePasso: ToquePasso(subestacao: {}, cercamento: {}, skid: {}),
      );

      var ufvParanoa = UFV(
        id: 'UFV 1.1',
        name: 'Paranoá UFV 1.1',
        fechamento: 'Estrela',
        marca: 'WEG',
        nSerie: 'WEG-998877',
        fatorK: 4,
        tensaoPrimaria: 3800,
        relacaoNominal: 24,
        tensaoSecundaria: 1200,
        potenciaKva: 1200,
        impedancia: 20,
        frequencia: 60,
        peso: 200,
        ip: 1,
        dataFabricacao: '20/01/2020',
        volumeOleo: 40,
        measurements: paranoaInspection,
      );

      // --- NEW: Wrap the UFV inside a Plant object ---
      var usinaParanoa = Plant(
        id: 'Paranoa',
        name: 'Usina Paranoá',
        local: 'Brasilia - DF',
        ufvs: [ufvParanoa], // Add the UFV to the plant's list
      );

      // 3. Save the PLANT to Firebase (which includes the UFVs inside it)
      CollectionReference plantCollection = FirebaseFirestore.instance
          .collection('plants');

      // We use usinaParanoa.toMap() instead of ufvParanoa.toMap()
      await plantCollection.doc(usinaParanoa.id).set(usinaParanoa.toMap());

      // 4. Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${usinaParanoa.name} salva com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // 5. Show error message if it fails
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print("Failed to save to Firebase: $e");
    }
  }
}
