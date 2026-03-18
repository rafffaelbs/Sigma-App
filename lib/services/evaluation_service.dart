import 'package:sigma_app/models/plant_model.dart';

class EvaluationService {
  /// Evaluates a measurement and returns: 'aprovado', 'alerta', 'reprovado', or 'none'
  static String evaluate(
    String instrumentType,
    String valueStr,
    String unit,
    UFV ufv,
  ) {
    if (valueStr.isEmpty) return 'none';

    // Safely parse the text to a double
    double? rawValue = double.tryParse(valueStr.replaceAll(',', '.'));
    if (rawValue == null) return 'none';

    // ==========================================
    // 1. MEGÔHMETRO
    // ==========================================
    if (instrumentType == 'Megohmetro') {
      // Standardize everything to Megaohms (MΩ)
      double valueInMegaOhms = _normalizeToMegaOhms(rawValue, unit);

      // Dummy logic (Replace with real formulas later):
      // Example: Minimum 1000 MΩ (1 GΩ) is good, 500-999 MΩ is alert.
      if (valueInMegaOhms >= 1000) return 'aprovado';
      if (valueInMegaOhms >= 500) return 'alerta';
      return 'reprovado';
    }
    // ==========================================
    // 2. MICROOHMÍMETRO
    // ==========================================
    else if (instrumentType == 'Microohmimetro') {
      // Standardize everything to Microohms (µΩ)
      double valueInMicroOhms = _normalizeToMicroOhms(rawValue, unit);

      // Dummy logic: Example, must be less than 50,000 µΩ (50 mΩ)
      if (valueInMicroOhms < 50000) return 'aprovado';
      return 'reprovado';
    }

    // Default fallback if no formulas exist yet
    return 'none';
  }

  // ==========================================
  // NORMALIZATION HELPERS
  // ==========================================

  /// Converts any resistance unit to Megaohms (MΩ)
  static double _normalizeToMegaOhms(double value, String unit) {
    switch (unit) {
      case 'kΩ':
        return value / 1000;
      case 'MΩ':
        return value;
      case 'GΩ':
        return value * 1000;
      case 'TΩ':
        return value * 1000000;
      default:
        return value; // Fallback
    }
  }

  /// Converts any low resistance unit to Microohms (µΩ)
  static double _normalizeToMicroOhms(double value, String unit) {
    switch (unit) {
      case 'µΩ':
        return value;
      case 'mΩ':
        return value * 1000;
      case 'Ω':
        return value * 1000000;
      default:
        return value; // Fallback
    }
  }
}
