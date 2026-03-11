import 'package:flutter/material.dart';
import 'package:sigma_app/models/measurements.dart';
import 'package:sigma_app/widgets/custom_header.dart';
import 'package:sigma_app/widgets/equipments_dropdown.dart';
import 'package:sigma_app/widgets/measurement_input_block.dart';

class DynamicGroupEntryScreen extends StatefulWidget {
  final String title;
  final DynamicGroup dynamicGroup;
  final List<String> allowedUnits;
  final String instrumentType;
  final String plantId;
  final String ufvId;

  const DynamicGroupEntryScreen({
    super.key,
    required this.title,
    required this.dynamicGroup,
    required this.allowedUnits,
    required this.instrumentType,
    required this.plantId,
    required this.ufvId,
  });

  @override
  State<DynamicGroupEntryScreen> createState() =>
      _DynamicGroupEntryScreenState();
}

class _DynamicGroupEntryScreenState extends State<DynamicGroupEntryScreen> {
  final Map<String, TextEditingController> _controllers = {};
  final bool _isUploading = false;

  // Track the selected equipment in the local state
  String? _selectedEquipment;

  @override
  void initState() {
    super.initState();
    widget.dynamicGroup.readings.forEach((key, measurement) {
      _controllers[key] = TextEditingController(
        text: measurement.value > 0 ? measurement.value.toString() : '',
      );
    });
    // Initialize if model already has a value
    _selectedEquipment = widget.dynamicGroup.equipment;
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _saveData() {
    // Removed 'async' and 'Future'
    if (_selectedEquipment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione o equipamento.')),
      );
      return;
    }

    // 1. Assign all the typed values and equipment to the local model
    _controllers.forEach((key, controller) {
      widget.dynamicGroup.readings[key]?.value =
          double.tryParse(controller.text) ?? 0.0;
      widget.dynamicGroup.readings[key]?.equipment = _selectedEquipment!;
    });
    widget.dynamicGroup.equipment =
        _selectedEquipment!; // Save selected equipment to the model
    // 2. VALIDATION: Check if any entered value is missing photos
    bool hasMissingPhotos = widget.dynamicGroup.readings.values.any((reading) {
      return reading.value > 0.0 && reading.imageUrl.isEmpty;
    });

    if (hasMissingPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione fotos para todas as medições preenchidas.'),
        ),
      );
      return; // Stop the save process
    }

    // 3. Return to the previous screen and pass 'true'
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(title: widget.title),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  ..._controllers.entries.toList().reversed.map(
                    (entry) => MeasurementInputBlock(
                      label: entry.key,
                      measurementValue:
                          widget.dynamicGroup.readings[entry.key]!,
                      controller: entry.value,
                      allowedUnits: widget.allowedUnits,
                    ),
                  ),
                  EquipmentDropdown(
                    measurementType: widget.instrumentType,
                    selectedValue: _selectedEquipment,
                    onChanged: (val) {
                      setState(() {
                        _selectedEquipment = val;
                      });
                    },
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isUploading
                            ? Colors.grey
                            : Colors.black,
                      ),
                      onPressed: _isUploading ? null : _saveData,
                      child: _isUploading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Salvar Medição',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
