import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  /// Faz o upload de um PDF (Uint8List) para o Supabase e retorna a URL pública
  static Future<String> uploadPdfBytes(
    Uint8List pdfBytes,
    String plantId,
    String ufvId,
  ) async {
    try {
      if (pdfBytes.isEmpty) {
        print("ERRO: O PDF gerado está vazio!");
        return "";
      }

      // 1. Higiene de Nomes (Remove acentos/espaços)
      String safePlantId = plantId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      String safeUfvId = ufvId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      
      // Caminho do arquivo: plantId/ufvId/Relatorio_123456.pdf
      String filePath = '$safePlantId/$safeUfvId/Relatorio_${DateTime.now().millisecondsSinceEpoch}.pdf';

      final supabase = Supabase.instance.client;

      print("Iniciando upload para o Supabase: $filePath");

      // 2. Upload the raw bytes to the 'reports' bucket
      await supabase.storage.from('reports').uploadBinary(
        filePath,
        pdfBytes,
        fileOptions: const FileOptions(
          contentType: 'application/pdf',
          upsert: true, // Sobrescreve se existir um com o mesmo nome
        ),
      );

      // 3. Get the public URL to save in Firestore
      final String publicUrl = supabase.storage.from('reports').getPublicUrl(filePath);
      
      print("Upload Supabase concluído! URL: $publicUrl");
      return publicUrl;

    } catch (e) {
      print("ERRO SUPABASE UPLOAD: $e");
      return "";
    }
  }
}