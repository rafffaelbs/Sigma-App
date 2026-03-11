import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigma_app/models/plant_model.dart'; // Make sure this path is correct
import 'package:cloud_firestore/cloud_firestore.dart';

class LocalSyncService {
  static const String _queueKey = 'pending_ufv_sync_queue';

  // 1. Save an entire UFV to the local "Waiting Room"
  static Future<void> savePlantLocally(Plant plant) async {
    final prefs = await SharedPreferences.getInstance();

    // Get the current queue
    List<String> queueString = prefs.getStringList(_queueKey) ?? [];

    // Convert our UFV object into a raw JSON string
    String ufvJsonString = jsonEncode(plant.toMap());

    // Check if we are updating an existing plant in the queue, or adding a new one
    int existingIndex = queueString.indexWhere((item) {
      var decoded = jsonDecode(item);
      return decoded['id'] == plant.id;
    });

    if (existingIndex >= 0) {
      queueString[existingIndex] = ufvJsonString; // Update existing
    } else {
      queueString.add(ufvJsonString); // Add new
    }

    // Save the list back to the phone's memory
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

  // ==========================================
  // CLOUD SYNC METHOD
  // ==========================================
  static Future<void> syncAllToFirebase() async {
    try {
      // 1. Get all your locally saved Plants (Assuming you have a method for this)
      // If you save UFVs individually, you'll adapt this to fetch your local list.
      List<Plant> localPlants = await getPendingPlants();

      if (localPlants.isEmpty) {
        throw Exception('Nenhum dado local para sincronizar.');
      }

      // 2. Initialize a Firebase Batch
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final WriteBatch batch = firestore.batch();
      final CollectionReference plantCollection = firestore.collection(
        'plants',
      );

      // 3. Add every plant to the batch
      for (var plant in localPlants) {
        DocumentReference docRef = plantCollection.doc(plant.id);

        // This relies on the beautiful toJson() logic you built!
        batch.set(docRef, plant.toMap(), SetOptions(merge: true));
      }

      // 4. Commit the batch to the cloud (All or Nothing)
      await batch.commit();

      // 5. (Optional) Clear the local storage after a successful sync
      // await clearLocalStorage();
    } catch (e) {
      print("Erro na sincronização: $e");
      rethrow; // Pass the error to the UI so we can show a SnackBar
    }
  }
}
