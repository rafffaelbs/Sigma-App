import 'package:sigma_app/models/plant_model.dart';

class EvaluationService {
  /// Evaluates a measurement and returns: 'aprovado', 'alerta', 'reprovado', or 'none'
  static String evaluate(String instrumentType, String valueStr, String unit, UFV ufv) {
    if (valueStr.isEmpty) return 'none';

    // Convert string with comma (e.g., "1,5") to double safely
    double? value = double.tryParse(valueStr.replaceAll(',', '.'));
    if (value == null) return 'none';

    // ==========================================
    // PLACEHOLDER: YOUR FORMULAS WILL GO HERE
    // You have access to the UFV object, so you can check:
    // ufv.potenciaKva, ufv.tensaoPrimaria, etc.
    // ==========================================

    if (instrumentType == 'Megohmetro') {
      // Dummy logic for testing:
      if (value >= 1000) return 'aprovado';
      if (value >= 500) return 'alerta';
      return 'reprovado';
    } 
    else if (instrumentType == 'Microohmimetro') {
      // Dummy logic for testing:
      if (value < 50) return 'aprovado';
      return 'reprovado';
    }

    // Default return if no formula is set for the instrument yet
    return 'none';
  }
}