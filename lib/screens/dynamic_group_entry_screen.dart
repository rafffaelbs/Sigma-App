import 'package:flutter/material.dart';
import 'package:sigma_app/models/measurements.dart';
import 'package:sigma_app/widgets/custom_header.dart';

class DynamicGroupEntryScreen extends StatefulWidget {
  final String title;
  final DynamicGroup dynamicGroup;

  const DynamicGroupEntryScreen({
    super.key,
    required this.title,
    required this.dynamicGroup,
  });

  @override
  State<DynamicGroupEntryScreen> createState() =>
      _DynamicGroupEntryScreenState();
}

class _DynamicGroupEntryScreenState extends State<DynamicGroupEntryScreen> {
  // A map to hold controllers dynamically based on whatever keys Firebase provides
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    // Create a text controller for every reading found in the Firebase data
    widget.dynamicGroup.readings.forEach((key, measurement) {
      _controllers[key] = TextEditingController(
        text: measurement.value.toString(),
      );
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _saveData() {
    // Save all values back to the memory object
    _controllers.forEach((key, controller) {
      widget.dynamicGroup.readings[key]?.value =
          double.tryParse(controller.text) ?? 0.0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Valores salvos localmente!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
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
                  // Dynamically build text fields for each reading (e.g., "At Bt", "H1-H3")
                  ..._controllers.entries.map(
                    (entry) => _buildInputRow(entry.key, entry.value),
                  ),

                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      onPressed: _saveData,
                      child: const Text(
                        'Salvar Medição',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
}
