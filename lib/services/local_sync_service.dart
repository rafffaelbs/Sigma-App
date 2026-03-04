import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigma_app/models/plant_model.dart'; // Make sure this path is correct

class LocalSyncService {
  static const String _queueKey = 'pending_ufv_sync_queue';

  // 1. Save an entire UFV to the local "Waiting Room"
  static Future<void> saveUfvLocally(UFV ufv) async {
    final prefs = await SharedPreferences.getInstance();

    // Get the current queue
    List<String> queueString = prefs.getStringList(_queueKey) ?? [];

    // Convert our UFV object into a raw JSON string
    String ufvJsonString = jsonEncode(ufv.toMap());

    // Check if we are updating an existing UFV in the queue, or adding a new one
    int existingIndex = queueString.indexWhere((item) {
      var decoded = jsonDecode(item);
      return decoded['id'] == ufv.id;
    });

    if (existingIndex >= 0) {
      queueString[existingIndex] = ufvJsonString; // Update existing
    } else {
      queueString.add(ufvJsonString); // Add new
    }

    // Save the list back to the phone's memory
    await prefs.setStringList(_queueKey, queueString);
    print(
      "Saved ${ufv.name} to Local Storage! (${queueString.length} items in queue)",
    );
  }

  // 2. Read all pending UFVs from the "Waiting Room"
  static Future<List<UFV>> getPendingUfvs() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> queueString = prefs.getStringList(_queueKey) ?? [];

    return queueString.map((jsonStr) {
      Map<String, dynamic> map = jsonDecode(jsonStr);
      return UFV.fromMap(map);
    }).toList();
  }

  // 3. Clear the "Waiting Room" after a successful Cloud Sync
  static Future<void> clearQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_queueKey);
    print("Local Sync Queue cleared.");
  }
}
