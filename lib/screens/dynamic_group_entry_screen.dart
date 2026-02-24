import 'package:flutter/material.dart';
import 'package:sigma_app/models/measurements.dart';
import 'package:sigma_app/services/upload_service.dart';
import 'package:sigma_app/widgets/custom_header.dart';
import 'package:sigma_app/widgets/equipments_dropdown.dart';
import 'package:sigma_app/widgets/measurement_input_block.dart';

class DynamicGroupEntryScreen extends StatefulWidget {
  final String title;
  final DynamicGroup dynamicGroup;
  final List<String> allowedUnits;

  const DynamicGroupEntryScreen({
    super.key,
    required this.title,
    required this.dynamicGroup,
    required this.allowedUnits,
  });

  @override
  State<DynamicGroupEntryScreen> createState() =>
      _DynamicGroupEntryScreenState();
}

class _DynamicGroupEntryScreenState extends State<DynamicGroupEntryScreen> {
  final Map<String, TextEditingController> _controllers = {};
  bool _isUploading = false;

  // Track the selected equipment in the local state
  String? _selectedEquipment;

  @override
  void initState() {
    super.initState();
    widget.dynamicGroup.readings.forEach((key, measurement) {
      _controllers[key] = TextEditingController(
        text: measurement.value.toString(),
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

  Future<void> _saveData() async {
    if (_selectedEquipment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione o equipamento.')),
      );
      return;
    }

    setState(() => _isUploading = true);
    try {
      _controllers.forEach((key, controller) {
        widget.dynamicGroup.readings[key]?.value =
            double.tryParse(controller.text) ?? 0.0;
        // Pass the equipment down to each reading for the watermark
        widget.dynamicGroup.readings[key]?.equipment = _selectedEquipment!;
      });

      await UploadService.uploadGroupImages(
        readings: widget.dynamicGroup.readings,
        plantId: 'plant-001',
        ufvId: 'ufv-001',
      );

      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
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
                  ..._controllers.entries.map(
                    (entry) => MeasurementInputBlock(
                      label: entry.key,
                      measurementValue:
                          widget.dynamicGroup.readings[entry.key]!,
                      controller: entry.value,
                      allowedUnits: widget.allowedUnits,
                    ),
                  ),
                  // FIXED DROPBOX INTEGRATION
                  EquipmentDropdown(
                    // Using widget.title or a specific type property to filter
                    measurementType: widget.title.contains('Megômetro')
                        ? 'Megohmetro'
                        : 'Microohmimetro',
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

Widget _buildInputRow(String label, TextEditingController controller) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: const Icon(Icons.camera_alt),
          onPressed: () => print('Open camera for $label'),
        ),
      ),
    ),
  );
}
