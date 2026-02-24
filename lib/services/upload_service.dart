import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sigma_app/models/measurements.dart';

class UploadService {
  /// Uploads a single file to Firebase Storage and returns the Download URL
  static Future<String> uploadFile(File imageFile, String plantId, String ufvId, String label) async {
    try {
      String fileName = '${label}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('plants')
          .child(plantId)
          .child(ufvId)
          .child(fileName);

      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Upload Error: $e");
      return "";
    }
  }

  /// Iterates through a Map of measurements and uploads any local images found
  static Future<void> uploadGroupImages({
    required Map<String, MeasurementValue> readings,
    required String plantId,
    required String ufvId,
  }) async {
    for (var entry in readings.entries) {
      MeasurementValue measurement = entry.value;

      // Upload Measurement Image
      if (measurement.imageUrl.isNotEmpty && !measurement.imageUrl.startsWith('http')) {
        measurement.imageUrl = await uploadFile(
          File(measurement.imageUrl),
          plantId,
          ufvId,
          entry.key,
        );
      }

      // Upload Environment Image
      if (measurement.environmentImageUrl.isNotEmpty && !measurement.environmentImageUrl.startsWith('http')) {
        measurement.environmentImageUrl = await uploadFile(
          File(measurement.environmentImageUrl),
          plantId,
          ufvId,
          '${entry.key}_env',
        );
      }
    }
  }
}