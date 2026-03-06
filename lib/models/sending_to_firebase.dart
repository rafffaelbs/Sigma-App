import 'package:flutter/material.dart'; // Needed for WidgetsFlutterBinding
import 'package:firebase_core/firebase_core.dart'; // Needed for Firebase.initializeApp()
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sigma_app/models/measurements.dart';
import 'package:sigma_app/models/plant_model.dart';

// --- Move the function OUTSIDE of main() for cleaner code ---
Future<void> saveUfvToFirebase(UFV ufv) async {
  try {
    CollectionReference ufvCollection = FirebaseFirestore.instance.collection(
      'ufvs',
    );

    // .set() pushes it to the database using the UFV's ID as the document ID
    await ufvCollection.doc(ufv.id).set(ufv.toMap());

    print("Successfully saved ${ufv.name} to Firebase!");
  } catch (e) {
    print("Failed to save to Firebase: $e");
  }
}

// --- Make main() async ---
Future<void> uploadInitialDataToFirebase(BuildContext context) async {
  // 1. Show a loading message
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Enviando dados para o Firebase...')),
  );

  try {
    /// PARANOA ///
    var paranoaMegohmetro = Megohmetro(
      // Transformador
      transformador: DynamicGroup(
        readings: {
          "At Bt": MeasurementValue(),
          "At Massa": MeasurementValue(),
          "Bt Massa": MeasurementValue(),
        },
      ),
      // Mufla - Poste
      terminacaoMufla: {
        "Mufla Poste": PhaseGroup(
          faseA: MeasurementValue(),
          faseB: MeasurementValue(),
          faseC: MeasurementValue(),
          faseReserva: MeasurementValue(),
        ),
        "Mufla Entrada Cubículo": PhaseGroup(
          faseA: MeasurementValue(),
          faseB: MeasurementValue(),
          faseC: MeasurementValue(),
          faseReserva: MeasurementValue(),
        ),
        "Mufla Saída Cubículo": PhaseGroup(
          faseA: MeasurementValue(),
          faseB: MeasurementValue(),
          faseC: MeasurementValue(),
          faseReserva: MeasurementValue(),
        ),
        "Mufla Transformador": PhaseGroup(
          faseA: MeasurementValue(),
          faseB: MeasurementValue(),
          faseC: MeasurementValue(),
          faseReserva: MeasurementValue(),
        ),
      },
      paraRaios: {
        "Para Raios Poste": PhaseGroup(
          faseA: MeasurementValue(),
          faseB: MeasurementValue(),
          faseC: MeasurementValue(),
        ),
        "Para Raios Entrada Cubículo": PhaseGroup(
          faseA: MeasurementValue(),
          faseB: MeasurementValue(),
          faseC: MeasurementValue(),
        ),
        "Para Raios Saída Cubículo": PhaseGroup(
          faseA: MeasurementValue(),
          faseB: MeasurementValue(),
          faseC: MeasurementValue(),
        ),
        "Para Raios Transformador": PhaseGroup(
          faseA: MeasurementValue(),
          faseB: MeasurementValue(),
          faseC: MeasurementValue(),
        ),
      },
      seccionadora: {
        "Seccionadora 01": PhaseGroup(
          faseA: MeasurementValue(),
          faseB: MeasurementValue(),
          faseC: MeasurementValue(),
        ),
        "Seccionadora 02": PhaseGroup(
          faseA: MeasurementValue(),
          faseB: MeasurementValue(),
          faseC: MeasurementValue(),
        ),
      },
      disjuntorReligador: {
        "Disjuntor Religador Aberto": PhaseGroup(
          faseA: MeasurementValue(),
          faseB: MeasurementValue(),
          faseC: MeasurementValue(),
        ),
        "Disjuntor Religador Fechado": PhaseGroup(
          faseA: MeasurementValue(),
          faseB: MeasurementValue(),
          faseC: MeasurementValue(),
        ),
      },
      transformadorCorrente: PhaseGroup(
        faseA: MeasurementValue(),
        faseB: MeasurementValue(),
        faseC: MeasurementValue(),
      ),
    );

    var paranoaMicro = Microohmimetro(
      transformador: {
        "AT Delta-Estrela": DynamicGroup(
          readings: {
            "H1-H3": MeasurementValue(),
            "H2-H1": MeasurementValue(),
            "H3-H2": MeasurementValue(),
          },
        ),
        "BT Delta-Estrela": DynamicGroup(
          readings: {
            "X1-X0": MeasurementValue(),
            "X2-X0": MeasurementValue(),
            "X3-X0": MeasurementValue(),
          },
        ),
      },
      continuidadeMalha: {
        "Continuidade Subestação": DynamicGroup(
          readings: {
            "Cubículo/Malha": MeasurementValue(),
            "Poste/Malha": MeasurementValue(),
            "Cercamento/Malha": MeasurementValue(),
          },
        ),
        "Continuidade Skid": DynamicGroup(
          readings: {
            "Transformador/Malha": MeasurementValue(),
            "BEP/Malha": MeasurementValue(),
            "Inversor/Malha": MeasurementValue(),
          },
        ),
      },
      seccionadora: {
        "Seccionadora 01": PhaseGroup(
          faseA: MeasurementValue(),
          faseB: MeasurementValue(),
          faseC: MeasurementValue(),
        ),
        "Seccionadora 02": PhaseGroup(
          faseA: MeasurementValue(),
          faseB: MeasurementValue(),
          faseC: MeasurementValue(),
        ),
      },
      disjuntorReligador: {
        "Disjuntor Religador Fechado": PhaseGroup(
          faseA: MeasurementValue(),
          faseB: MeasurementValue(),
          faseC: MeasurementValue(),
        ),
      },
    );

    var paranoaTtr = Ttr(
      transformador: {
        "Delta-Estrela": DynamicGroup(
          readings: {
            "H1-H3 / X1-X0": MeasurementValue(),
            "H2-H1 / X2-X0": MeasurementValue(),
            "H3-H2 / X3-X0": MeasurementValue(),
          },
        ),
      },
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
    );

    var paranoaHipot = Hipot(
      caboMediaTensao: {
        "Poste Cubículo": PhaseGroup(
          faseA: MeasurementValue(),
          faseB: MeasurementValue(),
          faseC: MeasurementValue(),
          faseReserva: MeasurementValue(),
        ),
        "Cubículo Transformador": PhaseGroup(
          faseA: MeasurementValue(),
          faseB: MeasurementValue(),
          faseC: MeasurementValue(),
          faseReserva: MeasurementValue(),
        ),
      },
    );

    var paranoaTerrometro = Terrometro(
      subestacao: DynamicGroup(
        readings: {
          "Cubículo Malha D=18/40": MeasurementValue(),
          "Cubículo Malha D=19/40": MeasurementValue(),
          "Cubículo Malha D=20/40": MeasurementValue(),
        },
      ),
      transformadores: {
        "Transformador 01": DynamicGroup(
          readings: {
            "Transformador 01 - D=18/40": MeasurementValue(),
            "Transformador 01 - D=19/40": MeasurementValue(),
            "Transformador 01 - D=20/40": MeasurementValue(),
          },
        ),
      },
    );

    var paranoaToquePasso = ToquePasso(
      subestacao: {
        "Cubículo Proteção Geral": DynamicGroup(
          readings: {
            "Toque": MeasurementValue(),
            "Passo 1m": MeasurementValue(),
            "Passo 5m": MeasurementValue(),
          },
        ),
        "Cubículo Proteção Medição": DynamicGroup(
          readings: {
            "01 - Toque": MeasurementValue(),
            "02 - Toque": MeasurementValue(),
            "03 - Toque": MeasurementValue(),
          },
        ),
      },
      cercamento: {
        "Portão Acesso": DynamicGroup(
          readings: {
            "Toque": MeasurementValue(),
            "Passo 1m": MeasurementValue(),
            "Passo 5m": MeasurementValue(),
          },
        ),
        "Componentes": DynamicGroup(
          readings: {
            "Alambrado - Toque": MeasurementValue(),
            "Gradil Interno - Toque": MeasurementValue(),
            "Componentes Metálicos - Toque": MeasurementValue(),
          },
        ),
      },
      skid: {
        "Transformador/QGBT": DynamicGroup(
          readings: {
            "Toque": MeasurementValue(),
            "Passo 1m": MeasurementValue(),
            "Passo 5m": MeasurementValue(),
          },
        ),
        "Inversores": DynamicGroup(
          readings: {
            "Toque": MeasurementValue(),
            "Passo 1m": MeasurementValue(),
            "Passo 5m": MeasurementValue(),
          },
        ),
        "Componentes Metálicos": DynamicGroup(
          readings: {
            "QGBT - Toque": MeasurementValue(),
            "Quadro Bt - Toque": MeasurementValue(),
            "Container Metálico - Toque": MeasurementValue(),
            "Cercamento UFV - Toque": MeasurementValue(),
            "Estrutura Fixação - Toque": MeasurementValue(),
          },
        ),
        "Módulos": DynamicGroup(
          readings: {
            "Toque": MeasurementValue(),
            "Passo 1m": MeasurementValue(),
            "Passo 5m": MeasurementValue(),
          },
        ),
      },
    );

    var paranoaInspection = FullInspection(
      megohmetro: paranoaMegohmetro,
      microohmimetro: paranoaMicro,
      ttr: paranoaTtr,
      hipot: paranoaHipot,
      terrometro: paranoaTerrometro,
      toquePasso: paranoaToquePasso,
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

    var usinaParanoa = Plant(
      id: 'Paranoá',
      name: 'Usina Paranoá',
      local: 'Brasilia - DF',
      ufvs: [ufvParanoa], // Add the UFV to the plant's list
    );

    /// PANAMA ///
    var panamaMegohmetro = Megohmetro(
      transformador: DynamicGroup(
        readings: {
          "At Bt": MeasurementValue(),
          "At Massa": MeasurementValue(),
          "Bt Massa": MeasurementValue(),
        },
      ),
    );

    var panamaMicro = Microohmimetro(
      transformador: {
        "AT Delta-Estrela": DynamicGroup(
          readings: {
            "H1-H3": MeasurementValue(),
            "H2-H1": MeasurementValue(),
            "H3-H2": MeasurementValue(),
          },
        ),
        "BT Delta-Estrela": DynamicGroup(
          readings: {
            "X1-X0": MeasurementValue(),
            "X2-X0": MeasurementValue(),
            "X3-X0": MeasurementValue(),
          },
        ),
      },
    );

    var panamaTtr = Ttr(
      transformador: {
        "Delta-Estrela": DynamicGroup(
          readings: {
            "H1-H3 / X1-X0": MeasurementValue(),
            "H2-H1 / X2-X0": MeasurementValue(),
            "H3-H2 / X3-X0": MeasurementValue(),
          },
        ),
      },
    );

    var panamaFullInspection = FullInspection(
      megohmetro: panamaMegohmetro,
      microohmimetro: panamaMicro,
      ttr: panamaTtr,
      hipot: Hipot(),
      terrometro: Terrometro(),
      toquePasso: ToquePasso(),
    );

    var ufvPanama = UFV(
      id: 'UFV 1.1',
      name: 'Panamá UFV 1.1',
      fechamento: 'Delta',
      marca: 'Siemens',
      nSerie: 'SIEMENS-554433',
      fatorK: 5,
      tensaoPrimaria: 13800,
      relacaoNominal: 115,
      tensaoSecundaria: 1200,
      potenciaKva: 2500,
      impedancia: 25,
      frequencia: 60,
      peso: 500,
      ip: 1,
      dataFabricacao: '15/03/2021',
      volumeOleo: 100,
      measurements: panamaFullInspection,
    );

    var usinaPanama = Plant(
      id: 'Panamá',
      name: 'Usina Panamá',
      local: 'Brasilia - DF',
      ufvs: [ufvPanama],
    );

    CollectionReference plantCollection = FirebaseFirestore.instance.collection(
      'plants',
    );

    await plantCollection.doc(usinaPanama.id).set(usinaPanama.toMap());

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${usinaPanama.name} salva com sucesso!'),
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
