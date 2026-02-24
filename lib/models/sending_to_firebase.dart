import 'package:flutter/material.dart'; // Needed for WidgetsFlutterBinding
import 'package:firebase_core/firebase_core.dart'; // Needed for Firebase.initializeApp()
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sigma_app/models/measurements.dart';
import 'package:sigma_app/models/plant_model.dart';

// --- Move the function OUTSIDE of main() for cleaner code ---
Future<void> saveUfvToFirebase(UFV ufv) async {
  try {
    CollectionReference ufvCollection = FirebaseFirestore.instance.collection('ufvs');
    
    // .set() pushes it to the database using the UFV's ID as the document ID
    await ufvCollection.doc(ufv.id).set(ufv.toMap());

    print("Successfully saved ${ufv.name} to Firebase!");
  } catch (e) {
    print("Failed to save to Firebase: $e");
  }
}

// --- Make main() async ---
Future<void> main() async {
  // 1. Initialize Flutter and Firebase FIRST!
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); 

  // 2. Create the specific measurements for Paranoá
  var paranoaMegohmetro = Megohmetro(
    transformador: DynamicGroup(readings: {
      "At Bt": MeasurementValue(value: 5000, measurementUnit: "MOhm"),
      "At Massa": MeasurementValue(value: 10000, measurementUnit: "MOhm"),
    }),
    terminacaoMufla: {
      "Mufla Poste": PhaseGroup(
         faseA: MeasurementValue(value: 2000), 
         faseB: MeasurementValue(value: 2000), 
         faseC: MeasurementValue(value: 2000)
      ),
      "Mufla Entrada Cubiculo": PhaseGroup(
         faseA: MeasurementValue(value: 3000), 
         faseB: MeasurementValue(value: 3000), 
         faseC: MeasurementValue(value: 3000)
      ),
    },
    paraRaios: {}, 
    seccionadora: {},
    disjuntorReligador: {},
    transformadorCorrente: PhaseGroup(faseA: MeasurementValue(), faseB: MeasurementValue(), faseC: MeasurementValue()),
  );

  var paranoaMicro = Microohmimetro(
    transformador: {
      "AT Delta Estrela": DynamicGroup(readings: {
        "H1-H3": MeasurementValue(value: 0.05, measurementUnit: "mOhm")
      }),
      "BT Delta Estrela": DynamicGroup(readings: {
        "X1-X0": MeasurementValue(value: 0.02, measurementUnit: "mOhm")
      })
    },
    continuidadeMalha: {},
    seccionadora: {},
    disjuntorReligador: {},
  );

  var paranoaInspection = FullInspection(
    megohmetro: paranoaMegohmetro,
    microohmimetro: paranoaMicro,
    ttr: Ttr(transformador: {}, transformadorPotencial: PhaseGroup(faseA: MeasurementValue(), faseB: MeasurementValue(), faseC: MeasurementValue()), transformadorCorrente: PhaseGroup(faseA: MeasurementValue(), faseB: MeasurementValue(), faseC: MeasurementValue())),
    hipot: Hipot(tests: {}),
    terrometro: Terrometro(subestacao: DynamicGroup(readings: {}), transformadores: {}),
    toquePasso: ToquePasso(subestacao: {}, cercamento: {}, skid: {}),
  );

  var ufvParanoa = UFV(
    id: "ufv-001",
    name: "UFV Paranoá",
    nSerie: "WEG-998877",
    potenciaKva: 2500,
    measurements: paranoaInspection, 
  );

  print("Created ${ufvParanoa.name}");
  // 3. ACTUALLY CALL THE FUNCTION to send it to Firebase
  print("Sending to Firebase...");
  await saveUfvToFirebase(ufvParanoa); 
}