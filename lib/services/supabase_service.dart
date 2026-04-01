import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  /// Faz upload de uma imagem (File) para o Supabase Storage
  /// Se a imagem já foi uploadada (URL começa com http), retorna a URL existente
  static Future<String> uploadImage(
    File imageFile,
    String plantId,
    String ufvId,
    String measurementType, // --- NEW: Megohmetro, Microohmimetro, TTR, etc.
    String label,
    String? existingUrl, // --- NEW: Para verificar se já foi uploadado
  ) async {
    try {
      // --- NEW: Se já tem URL do Supabase, não faz upload novamente
      if (existingUrl != null &&
          existingUrl.isNotEmpty &&
          existingUrl.startsWith('http')) {
        print("Imagem já existe no Supabase: $existingUrl");
        return existingUrl;
      }

      // Verifica se o arquivo local existe
      if (!imageFile.existsSync()) {
        print("ERRO: Arquivo de imagem não existe: ${imageFile.path}");
        return "";
      }

      // 1. Higiene de IDs
      String safePlantId = plantId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      String safeUfvId = ufvId
          .replaceAll('.', '_')
          .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');

      // 2. Nome simples sem timestamp (ex: FaseA.jpg) - permite sobrescrita
      String fileName = '$label.jpg';
      // 3. Organizado em pastas por tipo de medição
      String filePath = '$safePlantId/$safeUfvId/$measurementType/$fileName';

      final supabase = Supabase.instance.client;
      print("Iniciando upload de imagem: $filePath");

      // 4. Lê o arquivo como bytes
      Uint8List fileBytes = await imageFile.readAsBytes();

      // 5. Faz o upload com upsert (sobrescreve se existir)
      await supabase.storage
          .from('images')
          .uploadBinary(
            filePath,
            fileBytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true, // --- Permite sobrescrever imagens existentes
            ),
          );

      // 6. Retorna URL pública
      String publicUrl = supabase.storage.from('images').getPublicUrl(filePath);
      print("Upload de imagem concluído! URL: $publicUrl");

      return publicUrl;
    } catch (e) {
      print("ERRO SUPABASE IMAGE UPLOAD: $e");
      return "";
    }
  }

  static Future<String> uploadPdfBytes(
    Uint8List pdfBytes,
    String plantId,
    String ufvId, {
    String? ufvName,
    required String plantName,
  }) async {
    try {
      if (pdfBytes.isEmpty) {
        print("ERRO: O PDF gerado está vazio!");
        return "";
      }

      // 1. Hygiene: Replace dots and non-alphanumerics with underscores
      String safePlantId = plantId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      String safeUfvId = ufvId
          .replaceAll('.', '_')
          .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');

      final now = DateTime.now();
      final monthNames = [
        'Jan',
        'Fev',
        'Mar',
        'Abr',
        'Mai',
        'Jun',
        'Jul',
        'Ago',
        'Set',
        'Out',
        'Nov',
        'Dez',
      ];
      final monthAbbr = monthNames[now.month - 1];
      final year = now.year.toString();

      // The "Something": Last 5 digits of timestamp to prevent name collisions
      final uniqueSuffix = now.millisecondsSinceEpoch.toString().substring(8);

      // 2. New Naming Logic: UFV_MonthYear_UniqueSuffix.pdf
      String baseName;
      if (ufvName != null) {
        // Replace dots with underscores in the display name too
        String cleanUfv = ufvName
            .replaceAll('.', '_')
            .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
        baseName = '${cleanUfv}_$monthAbbr${year}_$uniqueSuffix';
      } else {
        baseName = '${safeUfvId}_$monthAbbr${year}_$uniqueSuffix';
      }

      String filePath = '$safePlantId/$safeUfvId/$baseName.pdf';

      final supabase = Supabase.instance.client;
      print("Iniciando upload: $filePath");

      await supabase.storage
          .from('reports')
          .uploadBinary(
            filePath,
            pdfBytes,
            fileOptions: const FileOptions(
              contentType: 'application/pdf',
              upsert: true,
            ),
          );

      return supabase.storage.from('reports').getPublicUrl(filePath);
    } catch (e) {
      print("ERRO SUPABASE UPLOAD: $e");
      return "";
    }
  }

  /// Note: Update the Regex in listPdfs to match the new UFV_Date_Suffix pattern
  static Future<List<Map<String, dynamic>>> listPdfs(
    String plantId,
    String ufvId,
  ) async {
    try {
      String safePlantId = plantId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      // Ensure we look in the folder where dots were replaced by underscores
      String safeUfvId = ufvId
          .replaceAll('.', '_')
          .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');

      final supabase = Supabase.instance.client;
      final List<FileObject> files = await supabase.storage
          .from('reports')
          .list(path: '$safePlantId/$safeUfvId');

      final List<Map<String, dynamic>> pdfs = files
          .where((file) => file.name.endsWith('.pdf'))
          .map((file) {
            final filePath = '$safePlantId/$safeUfvId/${file.name}';
            final publicUrl = supabase.storage
                .from('reports')
                .getPublicUrl(filePath);

            DateTime createdAt = DateTime.now();
            try {
              // Updated Regex: Matches UFVName_MonthYear_Suffix.pdf
              // We look for the 3-letter month and 4-digit year near the end
              final match = RegExp(
                r'_(\w{3})(\d{4})_\d+\.pdf',
              ).firstMatch(file.name);
              if (match != null) {
                final monthNames = [
                  'Jan',
                  'Fev',
                  'Mar',
                  'Abr',
                  'Mai',
                  'Jun',
                  'Jul',
                  'Ago',
                  'Set',
                  'Out',
                  'Nov',
                  'Dez',
                ];
                final monthIndex = monthNames.indexOf(match.group(1)!) + 1;
                final year = int.parse(match.group(2)!);
                if (monthIndex > 0) createdAt = DateTime(year, monthIndex);
              }
            } catch (e) {
              print('Erro parsing: $e');
            }

            return {
              'id': file.id ?? file.name,
              'fileName': file.name,
              'downloadUrl': publicUrl,
              'createdAt': createdAt,
              'fileSize': file.metadata?['size'] ?? 0,
            };
          })
          .toList();

      pdfs.sort(
        (a, b) =>
            (b['createdAt'] as DateTime).compareTo(a['createdAt'] as DateTime),
      );
      return pdfs;
    } catch (e) {
      print("ERRO SUPABASE LIST: $e");
      return [];
    }
  }
}
