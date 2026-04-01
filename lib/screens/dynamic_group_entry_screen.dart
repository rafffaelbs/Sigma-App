import 'package:flutter/material.dart';
import 'package:sigma_app/models/measurements.dart';
import 'package:sigma_app/models/plant_model.dart';
import 'package:sigma_app/services/measurement_codes.dart';
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
  final UFV ufv;
  /// Subgroup path used for code lookup (e.g. "Transformador", "Continuidade Malha")
  final String subgroup;
  /// Equipment key (outer map key) for code lookup; empty for single-group slots
  final String equipmentKey;

  const DynamicGroupEntryScreen({
    super.key,
    required this.title,
    required this.dynamicGroup,
    required this.allowedUnits,
    required this.instrumentType,
    required this.plantId,
    required this.ufvId,
    required this.ufv,
    this.subgroup = '',
    this.equipmentKey = '',
  });

  @override
  State<DynamicGroupEntryScreen> createState() =>
      _DynamicGroupEntryScreenState();
}

class _DynamicGroupEntryScreenState extends State<DynamicGroupEntryScreen> {
  final Map<String, TextEditingController> _controllers = {};
  final bool _isUploading = false;

  String? _selectedEquipment;

  @override
  void initState() {
    super.initState();
    widget.dynamicGroup.readings.forEach((key, measurement) {
      _controllers[key] = TextEditingController(
        // --- FIXED: Reverted back to checking if the double is > 0 ---
        text: measurement.value > 0 ? measurement.value.toString() : '',
      );
    });
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
    if (_selectedEquipment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione o equipamento.')),
      );
      return;
    }

    _controllers.forEach((key, controller) {
      // --- FIXED: Safely convert the String back to a double ---
      // replaceAll makes sure that if they type "1,5" it converts to "1.5" so Dart can read it
      widget.dynamicGroup.readings[key]?.value =
          double.tryParse(controller.text.replaceAll(',', '.')) ?? 0.0;
          
      widget.dynamicGroup.readings[key]?.equipment = _selectedEquipment!;
    });
    
    widget.dynamicGroup.equipment = _selectedEquipment!; 

    bool hasMissingPhotos = widget.dynamicGroup.readings.values.any((reading) {
      // --- FIXED: Reverted back to checking if the double is > 0 ---
      return reading.value > 0 && reading.imageUrl.isEmpty;
    });

    if (hasMissingPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione fotos para todas as medições preenchidas.'),
        ),
      );
      return; 
    }

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
                      measurementValue: widget.dynamicGroup.readings[entry.key]!,
                      controller: entry.value,
                      allowedUnits: widget.allowedUnits,
                      instrumentType: widget.instrumentType,
                      ufv: widget.ufv,
                      measurementCode: MeasurementCodes.forDynamic(
                        widget.instrumentType,
                        widget.subgroup,
                        widget.equipmentKey,
                        entry.key,
                      ),
                    ),
                  ),
                  EquipmentDropdown(
                    measurementType: widget.instrumentType,
                    selectedValue: _selectedEquipment,
                    // --- FIXED: Explicitly declared the type as String? ---
                    onChanged: (String? val) {
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