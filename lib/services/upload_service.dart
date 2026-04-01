import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sigma_app/models/measurements.dart';
import 'package:sigma_app/models/plant_model.dart';
import 'package:sigma_app/services/supabase_service.dart'; // --- CHANGED: Import Supabase

class UploadService {
  /// Uploads a single file to Supabase Storage and returns the Download URL
  static Future<String> uploadFile(
    File imageFile,
    String plantId,
    String ufvId,
    String measurementType, // --- NEW: Megohmetro, Microohmimetro, etc.
    String label,
    String? existingUrl, // --- NEW: Skip if already uploaded
  ) async {
    return await SupabaseStorageService.uploadImage(
      imageFile,
      plantId,
      ufvId,
      measurementType,
      label,
      existingUrl,
    );
  }

  /// Iterates through a Map of measurements and uploads any local images found
  static Future<void> uploadGroupImages({
    required Map<String, MeasurementValue> readings,
    required String plantId,
    required String ufvId,
    required String measurementType, // --- NEW: Folder name in Supabase
  }) async {
    for (var entry in readings.entries) {
      MeasurementValue measurement = entry.value;

      // Upload Measurement Image (skip if already uploaded - has http URL)
      if (measurement.imageUrl.isNotEmpty) {
        measurement.imageUrl = await uploadFile(
          File(measurement.imageUrl),
          plantId,
          ufvId,
          measurementType,
          entry.key,
          measurement.imageUrl, // Pass existing URL to check
        );
      }

      // Upload Environment Image
      if (measurement.environmentImageUrl.isNotEmpty) {
        measurement.environmentImageUrl = await uploadFile(
          File(measurement.environmentImageUrl),
          plantId,
          ufvId,
          measurementType,
          '${entry.key}_env',
          measurement.environmentImageUrl,
        );
      }
    }
  }

  /// Faz o upload de um PDF gerado em memória (Uint8List) diretamente para o Supabase
  static Future<String> uploadPdfBytes(
    Uint8List pdfBytes,
    String plantId,
    String ufvId,
    String plantName,
    String ufvName,
  ) async {
    // --- CHANGED: Delegate to SupabaseStorageService instead of Firebase
    return await SupabaseStorageService.uploadPdfBytes(
      pdfBytes,
      plantId,
      ufvId,
      plantName: plantName,
      ufvName: ufvName,
    );
  }
}

class FirebaseService {
  Future<void> uploadInitialDataToFirebase(BuildContext context) async {
    // 1. Show a loading message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Enviando dados para o Firebase...')),
    );

    try {
      /// PARANOA ///
      var paranoaMegohmetro = Megohmetro(
        // 1.0 Transformador
        transformador: DynamicGroup(
          readings: {
            "At Bt": MeasurementValue(code: '1.0.1'),
            "At Massa": MeasurementValue(code: '1.0.2'),
            "Bt Massa": MeasurementValue(code: '1.0.3'),
          },
        ),
        // 1.1 Terminação Mufla
        terminacaoMufla: {
          "Mufla Poste": PhaseGroup(
            faseA: MeasurementValue(code: '1.1.1A'),
            faseB: MeasurementValue(code: '1.1.1B'),
            faseC: MeasurementValue(code: '1.1.1C'),
            faseReserva: MeasurementValue(code: '1.1.1R'),
          ),
          "Mufla Entrada Cubículo": PhaseGroup(
            faseA: MeasurementValue(code: '1.1.2A'),
            faseB: MeasurementValue(code: '1.1.2B'),
            faseC: MeasurementValue(code: '1.1.2C'),
            faseReserva: MeasurementValue(code: '1.1.2R'),
          ),
          "Mufla Saída Cubículo": PhaseGroup(
            faseA: MeasurementValue(code: '1.1.3A'),
            faseB: MeasurementValue(code: '1.1.3B'),
            faseC: MeasurementValue(code: '1.1.3C'),
            faseReserva: MeasurementValue(code: '1.1.3R'),
          ),
          "Mufla Transformador": PhaseGroup(
            faseA: MeasurementValue(code: '1.1.4A'),
            faseB: MeasurementValue(code: '1.1.4B'),
            faseC: MeasurementValue(code: '1.1.4C'),
            faseReserva: MeasurementValue(code: '1.1.4R'),
          ),
        },
        // 1.2 Para Raios
        paraRaios: {
          "Para Raios Poste": PhaseGroup(
            faseA: MeasurementValue(code: '1.2.1A'),
            faseB: MeasurementValue(code: '1.2.1B'),
            faseC: MeasurementValue(code: '1.2.1C'),
          ),
          "Para Raios Entrada Cubículo": PhaseGroup(
            faseA: MeasurementValue(code: '1.2.2A'),
            faseB: MeasurementValue(code: '1.2.2B'),
            faseC: MeasurementValue(code: '1.2.2C'),
          ),
          "Para Raios Saída Cubículo": PhaseGroup(
            faseA: MeasurementValue(code: '1.2.3A'),
            faseB: MeasurementValue(code: '1.2.3B'),
            faseC: MeasurementValue(code: '1.2.3C'),
          ),
          "Para Raios Transformador": PhaseGroup(
            faseA: MeasurementValue(code: '1.2.4A'),
            faseB: MeasurementValue(code: '1.2.4B'),
            faseC: MeasurementValue(code: '1.2.4C'),
          ),
        },
        // 1.3 Seccionadora
        seccionadora: {
          "Seccionadora 01": PhaseGroup(
            faseA: MeasurementValue(code: '1.3.1A'),
            faseB: MeasurementValue(code: '1.3.1B'),
            faseC: MeasurementValue(code: '1.3.1C'),
          ),
          "Seccionadora 02": PhaseGroup(
            faseA: MeasurementValue(code: '1.3.2A'),
            faseB: MeasurementValue(code: '1.3.2B'),
            faseC: MeasurementValue(code: '1.3.2C'),
          ),
        },
        // 1.4 Disjuntor Religador
        disjuntorReligador: {
          "Disjuntor Religador Aberto": PhaseGroup(
            faseA: MeasurementValue(code: '1.4.1A'),
            faseB: MeasurementValue(code: '1.4.1B'),
            faseC: MeasurementValue(code: '1.4.1C'),
          ),
          "Disjuntor Religador Fechado": PhaseGroup(
            faseA: MeasurementValue(code: '1.4.2A'),
            faseB: MeasurementValue(code: '1.4.2B'),
            faseC: MeasurementValue(code: '1.4.2C'),
          ),
        },
        // 1.5 TC - Transformador de Corrente
        transformadorCorrente: PhaseGroup(
          faseA: MeasurementValue(code: '1.5A'),
          faseB: MeasurementValue(code: '1.5B'),
          faseC: MeasurementValue(code: '1.5C'),
        ),
      );

      var paranoaMicro = Microohmimetro(
        // 2.0 Transformador
        transformador: {
          "AT Delta-Estrela": DynamicGroup(
            readings: {
              "H1-H3": MeasurementValue(code: '2.0.1'),
              "H2-H1": MeasurementValue(code: '2.0.2'),
              "H3-H2": MeasurementValue(code: '2.0.3'),
            },
          ),
          "BT Delta-Estrela": DynamicGroup(
            readings: {
              "X1-X0": MeasurementValue(code: '2.0.4'),
              "X2-X0": MeasurementValue(code: '2.0.5'),
              "X3-X0": MeasurementValue(code: '2.0.6'),
            },
          ),
        },
        // 2.1 Continuidade Malha
        continuidadeMalha: {
          "Continuidade Subestação": DynamicGroup(
            readings: {
              "Cubículo/Malha": MeasurementValue(code: '2.1.1'),
              "Poste/Malha": MeasurementValue(code: '2.1.2'),
              "Cercamento/Malha": MeasurementValue(code: '2.1.3'),
            },
          ),
          "Continuidade Skid": DynamicGroup(
            readings: {
              "Transformador/Malha": MeasurementValue(code: '2.1.4'),
              "BEP/Malha": MeasurementValue(code: '2.1.5'),
              "Inversor/Malha": MeasurementValue(code: '2.1.6'),
            },
          ),
        },
        // 2.2 Seccionadora
        seccionadora: {
          "Seccionadora 01": PhaseGroup(
            faseA: MeasurementValue(code: '2.2.1A'),
            faseB: MeasurementValue(code: '2.2.1B'),
            faseC: MeasurementValue(code: '2.2.1C'),
          ),
          "Seccionadora 02": PhaseGroup(
            faseA: MeasurementValue(code: '2.2.2A'),
            faseB: MeasurementValue(code: '2.2.2B'),
            faseC: MeasurementValue(code: '2.2.2C'),
          ),
        },
        // 2.3 Disjuntor Religador
        disjuntorReligador: {
          "Disjuntor Religador Fechado": PhaseGroup(
            faseA: MeasurementValue(code: '2.3.1A'),
            faseB: MeasurementValue(code: '2.3.1B'),
            faseC: MeasurementValue(code: '2.3.1C'),
          ),
        },
      );

      var paranoaTtr = Ttr(
        // 3.0 Transformador
        transformador: {
          "Delta-Estrela": DynamicGroup(
            readings: {
              "H1-H3 / X1-X0": MeasurementValue(code: '3.0.1'),
              "H2-H1 / X2-X0": MeasurementValue(code: '3.0.2'),
              "H3-H2 / X3-X0": MeasurementValue(code: '3.0.3'),
            },
          ),
        },
        // 3.1 TP - Transformador de Potencial
        transformadorPotencial: PhaseGroup(
          faseA: MeasurementValue(code: '3.1A'),
          faseB: MeasurementValue(code: '3.1B'),
          faseC: MeasurementValue(code: '3.1C'),
        ),
        // 3.2 TC - Transformador de Corrente
        transformadorCorrente: PhaseGroup(
          faseA: MeasurementValue(code: '3.2A'),
          faseB: MeasurementValue(code: '3.2B'),
          faseC: MeasurementValue(code: '3.2C'),
        ),
      );

      var paranoaHipot = Hipot(
        // 4.1 Cabo Média Tensão
        caboMediaTensao: {
          "Poste Cubículo": PhaseGroup(
            faseA: MeasurementValue(code: '4.1.1A'),
            faseB: MeasurementValue(code: '4.1.1B'),
            faseC: MeasurementValue(code: '4.1.1C'),
            faseReserva: MeasurementValue(code: '4.1.1R'),
          ),
          "Cubículo Transformador": PhaseGroup(
            faseA: MeasurementValue(code: '4.1.2A'),
            faseB: MeasurementValue(code: '4.1.2B'),
            faseC: MeasurementValue(code: '4.1.2C'),
            faseReserva: MeasurementValue(code: '4.1.2R'),
          ),
        },
      );

      var paranoaTerrometro = Terrometro(
        // 5.0 Subestação
        subestacao: DynamicGroup(
          readings: {
            "Cubículo Malha D=18/40": MeasurementValue(code: '5.0A'),
            "Cubículo Malha D=19/40": MeasurementValue(code: '5.0B'),
            "Cubículo Malha D=20/40": MeasurementValue(code: '5.0C'),
          },
        ),
        // 5.1 Transformador 01
        transformadores: {
          "Transformador 01": DynamicGroup(
            readings: {
              "Transformador 01 - D=18/40": MeasurementValue(code: '5.1A'),
              "Transformador 01 - D=19/40": MeasurementValue(code: '5.1B'),
              "Transformador 01 - D=20/40": MeasurementValue(code: '5.1C'),
            },
          ),
        },
      );

      var paranoaToquePasso = ToquePasso(
        // 6.0 Subestação
        subestacao: {
          "Cubículo Proteção Geral": DynamicGroup(
            readings: {
              "Toque": MeasurementValue(code: '6.0.0'),
              "Passo 1m": MeasurementValue(code: '6.0.0.A'),
              "Passo 5m": MeasurementValue(code: '6.0.0.B'),
            },
          ),
          "Cubículo Proteção Medição": DynamicGroup(
            readings: {
              "01 - Toque": MeasurementValue(code: '6.0.1'),
              "02 - Toque": MeasurementValue(code: '6.0.2'),
              "03 - Toque": MeasurementValue(code: '6.0.3'),
            },
          ),
        },
        // 6.1 Cercamento / Abrigo
        cercamento: {
          "Portão Acesso": DynamicGroup(
            readings: {
              "Toque": MeasurementValue(code: '6.1.0'),
              "Passo 1m": MeasurementValue(code: '6.1.0.A'),
              "Passo 5m": MeasurementValue(code: '6.1.0.B'),
            },
          ),
          "Componentes": DynamicGroup(
            readings: {
              "Alambrado - Toque": MeasurementValue(code: '6.1.1'),
              "Gradil Interno - Toque": MeasurementValue(code: '6.1.2'),
              "Componentes Metálicos - Toque": MeasurementValue(code: '6.1.3'),
            },
          ),
        },
        // 6.2 SKID
        skid: {
          "Transformador/QGBT": DynamicGroup(
            readings: {
              "Toque": MeasurementValue(code: '6.2.0'),
              "Passo 1m": MeasurementValue(code: '6.2.0.A'),
              "Passo 5m": MeasurementValue(code: '6.2.0.B'),
            },
          ),
          "Inversores": DynamicGroup(
            readings: {
              "Toque": MeasurementValue(code: '6.2.1'),
              "Passo 1m": MeasurementValue(code: '6.2.1.A'),
              "Passo 5m": MeasurementValue(code: '6.2.1.B'),
            },
          ),
          "Componentes Metálicos": DynamicGroup(
            readings: {
              "QGBT - Toque": MeasurementValue(code: '6.2.2'),
              "Quadro Bt - Toque": MeasurementValue(code: '6.2.3'),
              "Container Metálico - Toque": MeasurementValue(code: '6.2.4'),
              "Cercamento UFV - Toque": MeasurementValue(code: '6.2.5'),
              "Estrutura Fixação - Toque": MeasurementValue(code: '6.2.6'),
            },
          ),
          "Módulos": DynamicGroup(
            readings: {
              "Toque": MeasurementValue(code: '6.2.7'),
              "Passo 1m": MeasurementValue(code: '6.2.7.A'),
              "Passo 5m": MeasurementValue(code: '6.2.7.B'),
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
        identificacaoUrl: '',
      );

      var ufvParanoa = UFV(
        id: 'UFV 1.1',
        name: 'Paranoa UFV 1.1',
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
        id: 'Paranoa',
        name: 'Usina Paranoa',
        local: 'Brasilia - DF',
        ufvs: [ufvParanoa], // Add the UFV to the plant's list
      );

      /// PANAMA ///
      var panamaMegohmetro = Megohmetro(
        // 1.0 Transformador
        transformador: DynamicGroup(
          readings: {
            "At Bt": MeasurementValue(code: '1.0.1'),
            "At Massa": MeasurementValue(code: '1.0.2'),
            "Bt Massa": MeasurementValue(code: '1.0.3'),
          },
        ),
      );

      var panamaMicro = Microohmimetro(
        // 2.0 Transformador
        transformador: {
          "AT Delta-Estrela": DynamicGroup(
            readings: {
              "H1-H3": MeasurementValue(code: '2.0.1'),
              "H2-H1": MeasurementValue(code: '2.0.2'),
              "H3-H2": MeasurementValue(code: '2.0.3'),
            },
          ),
          "BT Delta-Estrela": DynamicGroup(
            readings: {
              "X1-X0": MeasurementValue(code: '2.0.4'),
              "X2-X0": MeasurementValue(code: '2.0.5'),
              "X3-X0": MeasurementValue(code: '2.0.6'),
            },
          ),
        },
      );

      var panamaTtr = Ttr(
        // 3.0 Transformador
        transformador: {
          "Delta-Estrela": DynamicGroup(
            readings: {
              "H1-H3 / X1-X0": MeasurementValue(code: '3.0.1'),
              "H2-H1 / X2-X0": MeasurementValue(code: '3.0.2'),
              "H3-H2 / X3-X0": MeasurementValue(code: '3.0.3'),
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
        identificacaoUrl: '',
      );

      var ufvPanama = UFV(
        id: 'UFV 1.1',
        name: 'Panama UFV 1.1',
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
        id: 'Panama',
        name: 'Usina Panama',
        local: 'Brasilia - DF',
        ufvs: [ufvPanama],
      );

      CollectionReference plantCollection = FirebaseFirestore.instance
          .collection('plants');

      // Save Paranoa
      await plantCollection.doc(usinaParanoa.id).set(usinaParanoa.toMap());

      // Save Panama
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
}
