import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sigma_app/models/measurements.dart';

class UploadService {
  /// Uploads a single file to Firebase Storage and returns the Download URL
  static Future<String> uploadFile(
    File imageFile,
    String plantId,
    String ufvId,
    String label,
  ) async {
    // 1. Verifica se a foto realmente existe no celular
    if (!imageFile.existsSync()) {
      print(
        "ERRO UPLOAD: A foto local sumiu ou não existe neste caminho: ${imageFile.path}",
      );
      return "";
    }

    try {
      String fileName = '${label}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      Reference ref = FirebaseStorage.instance
          .ref()
          .child('plants')
          .child(plantId)
          .child(ufvId)
          .child(fileName);

      print("Iniciando upload para: plants/$plantId/$ufvId/$fileName");

      // 2. Faz o upload
      UploadTask uploadTask = ref.putFile(imageFile);

      // 3. Espera terminar
      TaskSnapshot snapshot = await uploadTask;

      print("Upload concluído! Pegando a URL...");
      // 4. Pega o link da imagem
      return await snapshot.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      // 5. Captura erros ESPECÍFICOS do Firebase (como regras bloqueadas)
      print("ERRO FIREBASE STORAGE: [${e.code}] ${e.message}");
      return "";
    } catch (e) {
      print("ERRO GERAL DE UPLOAD: $e");
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
      if (measurement.imageUrl.isNotEmpty &&
          !measurement.imageUrl.startsWith('http')) {
        measurement.imageUrl = await uploadFile(
          File(measurement.imageUrl),
          plantId,
          ufvId,
          entry.key,
        );
      }

      // Upload Environment Image
      if (measurement.environmentImageUrl.isNotEmpty &&
          !measurement.environmentImageUrl.startsWith('http')) {
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
