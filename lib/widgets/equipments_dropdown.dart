import 'package:flutter/material.dart';

class EquipmentDropdown extends StatelessWidget {
  final String measurementType; // 'Megohmetro' or 'Microohmimetro'
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  const EquipmentDropdown({
    super.key,
    required this.measurementType,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Define equipment lists per measurement type
    final Map<String, List<String>> equipmentMap = {
      'Megohmetro': ['MI-3102BT', 'MD-5060x', 'Metrel 5kV'],
      'Microohmimetro': ['MPK-254', 'RMO600G', 'Ductor DLRRO'],
    };

    // Fallback if measurement type isn't found
    final List<String> options =
        equipmentMap[measurementType] ?? ['General Equipment'];

    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: options.contains(selectedValue) ? selectedValue : null,
          decoration: InputDecoration(
            labelText: 'Equipment ($measurementType)',
            border: OutlineInputBorder(),
            prefixIcon: const Icon(Icons.settings_input_component),
          ),
          items: options.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: onChanged,
          validator: (value) =>
              value == null ? 'Please select equipment' : null,
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
