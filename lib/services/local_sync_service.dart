import 'dart:convert';
import 'dart:io'; // --- ADD: Import for File class
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigma_app/models/plant_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sigma_app/services/upload_service.dart';
import 'package:sigma_app/models/measurements.dart';

class LocalSyncService {
  static const String _queueKey = 'pending_ufv_sync_queue';

  // 1. Save an entire UFV to the local "Waiting Room"
  static Future<void> savePlantLocally(Plant plant) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> queueString = prefs.getStringList(_queueKey) ?? [];

    String ufvJsonString = jsonEncode(plant.toMap());

    int existingIndex = queueString.indexWhere((item) {
      var decoded = jsonDecode(item);
      return decoded['id'] == plant.id;
    });

    if (existingIndex >= 0) {
      queueString[existingIndex] = ufvJsonString;
    } else {
      queueString.add(ufvJsonString);
    }

    await prefs.setStringList(_queueKey, queueString);
    print(
      "Saved ${plant.name} to Local Storage! (${queueString.length} items in queue)",
    );
  }

  // 2. Read all pending UFVs from the "Waiting Room"
  static Future<List<Plant>> getPendingPlants() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> queueString = prefs.getStringList(_queueKey) ?? [];

    return queueString.map((jsonStr) {
      Map<String, dynamic> map = jsonDecode(jsonStr);
      return Plant.fromMap(map);
    }).toList();
  }

  // 3. Clear the "Waiting Room" after a successful Cloud Sync
  static Future<void> clearQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_queueKey);
    print("Local Sync Queue cleared.");
  }

  // --- ADD: Helper to upload all images in a FullInspection ---
  static Future<void> _uploadAllImagesForUfv(UFV ufv, String plantId) async {
    if (ufv.measurements == null) return;

    final meg = ufv.measurements!.megohmetro;
    if (meg.transformador != null) {
      await UploadService.uploadGroupImages(
        readings: meg.transformador!.readings,
        plantId: plantId,
        ufvId: ufv.id,
        measurementType: 'Megohmetro',
      );
    }
    await _uploadPhaseGroups(
      meg.terminacaoMufla,
      plantId,
      ufv.id,
      'Megohmetro',
    );
    await _uploadPhaseGroups(meg.paraRaios, plantId, ufv.id, 'Megohmetro');
    await _uploadPhaseGroups(meg.seccionadora, plantId, ufv.id, 'Megohmetro');
    await _uploadPhaseGroups(
      meg.disjuntorReligador,
      plantId,
      ufv.id,
      'Megohmetro',
    );
    if (meg.transformadorCorrente != null) {
      await _uploadPhaseGroup(
        meg.transformadorCorrente!,
        plantId,
        ufv.id,
        'Megohmetro',
        'TC',
      );
    }

    final micro = ufv.measurements!.microohmimetro;
    await _uploadDynamicGroups(
      micro.transformador,
      plantId,
      ufv.id,
      'Microohmimetro',
    );
    await _uploadDynamicGroups(
      micro.continuidadeMalha,
      plantId,
      ufv.id,
      'Microohmimetro',
    );
    await _uploadPhaseGroups(
      micro.seccionadora,
      plantId,
      ufv.id,
      'Microohmimetro',
    );
    await _uploadPhaseGroups(
      micro.disjuntorReligador,
      plantId,
      ufv.id,
      'Microohmimetro',
    );

    final ttr = ufv.measurements!.ttr;
    await _uploadDynamicGroups(ttr.transformador, plantId, ufv.id, 'TTR');
    if (ttr.transformadorPotencial != null) {
      await _uploadPhaseGroup(
        ttr.transformadorPotencial!,
        plantId,
        ufv.id,
        'TTR',
        'TP',
      );
    }
    if (ttr.transformadorCorrente != null) {
      await _uploadPhaseGroup(
        ttr.transformadorCorrente!,
        plantId,
        ufv.id,
        'TTR',
        'TC_TTR',
      );
    }

    final hipot = ufv.measurements!.hipot;
    await _uploadPhaseGroups(hipot.caboMediaTensao, plantId, ufv.id, 'Hipot');

    final ter = ufv.measurements!.terrometro;
    if (ter.subestacao != null) {
      await UploadService.uploadGroupImages(
        readings: ter.subestacao!.readings,
        plantId: plantId,
        ufvId: ufv.id,
        measurementType: 'Terrometro',
      );
    }
    await _uploadDynamicGroups(
      ter.transformadores,
      plantId,
      ufv.id,
      'Terrometro',
    );

    final toq = ufv.measurements!.toquePasso;
    await _uploadDynamicGroups(toq.subestacao, plantId, ufv.id, 'ToquePasso');
    await _uploadDynamicGroups(toq.cercamento, plantId, ufv.id, 'ToquePasso');
    await _uploadDynamicGroups(toq.skid, plantId, ufv.id, 'ToquePasso');

    // Upload identificacao image if exists and is local
    if (ufv.measurements!.identificacaoUrl.isNotEmpty &&
        !ufv.measurements!.identificacaoUrl.startsWith('http')) {
      final url = await UploadService.uploadFile(
        File(ufv.measurements!.identificacaoUrl),
        plantId,
        ufv.id,
        'Identificacao',
        'identificacao',
        ufv.measurements!.identificacaoUrl,
      );
      ufv.measurements!.identificacaoUrl = url;
    }
  }

  static Future<void> _uploadPhaseGroups(
    Map<String, PhaseGroup> groups,
    String plantId,
    String ufvId,
    String measurementType,
  ) async {
    for (var entry in groups.entries) {
      await _uploadPhaseGroup(
        entry.value,
        plantId,
        ufvId,
        measurementType,
        entry.key,
      );
    }
  }

  static Future<void> _uploadPhaseGroup(
    PhaseGroup pg,
    String plantId,
    String ufvId,
    String measurementType,
    String label,
  ) async {
    final readings = {
      '${label}_FaseA': pg.faseA,
      '${label}_FaseB': pg.faseB,
      '${label}_FaseC': pg.faseC,
    };
    if (pg.faseReserva != null) readings['${label}_Reserva'] = pg.faseReserva!;
    if (pg.auxiliar != null) readings['${label}_Aux'] = pg.auxiliar!;

    await UploadService.uploadGroupImages(
      readings: readings,
      plantId: plantId,
      ufvId: ufvId,
      measurementType: measurementType,
    );
  }

  static Future<void> _uploadDynamicGroups(
    Map<String, DynamicGroup> groups,
    String plantId,
    String ufvId,
    String measurementType,
  ) async {
    for (var entry in groups.entries) {
      await UploadService.uploadGroupImages(
        readings: entry.value.readings,
        plantId: plantId,
        ufvId: ufvId,
        measurementType: measurementType,
      );
    }
  }

  // ==========================================
  // CLOUD SYNC METHOD
  // ==========================================
  static Future<void> syncAllToFirebase() async {
    try {
      List<Plant> localPlants = await getPendingPlants();

      if (localPlants.isEmpty) {
        throw Exception('Nenhum dado local para sincronizar.');
      }

      // --- ADD: Upload all images to Supabase first ---
      print("Iniciando upload de imagens para Supabase...");
      for (var plant in localPlants) {
        for (var ufv in plant.ufvs) {
          await _uploadAllImagesForUfv(ufv, plant.id);
        }
      }
      print("Upload de imagens concluído!");

      // Now sync to Firestore with updated image URLs
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final WriteBatch batch = firestore.batch();
      final CollectionReference plantCollection = firestore.collection(
        'plants',
      );

      for (var plant in localPlants) {
        DocumentReference docRef = plantCollection.doc(plant.id);
        batch.set(docRef, plant.toMap(), SetOptions(merge: true));
      }

      await batch.commit();
    } catch (e) {
      print("Erro na sincronização: $e");
      rethrow;
    }
  }
}
