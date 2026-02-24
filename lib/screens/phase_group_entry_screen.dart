import 'package:flutter/material.dart';
import 'package:sigma_app/models/measurements.dart'; // Adjust path
import 'package:sigma_app/widgets/custom_header.dart';

class PhaseGroupEntryScreen extends StatefulWidget {
  final String title;
  final PhaseGroup phaseGroup;

  const PhaseGroupEntryScreen({
    super.key,
    required this.title,
    required this.phaseGroup,
  });

  @override
  State<PhaseGroupEntryScreen> createState() => _PhaseGroupEntryScreenState();
}

class _PhaseGroupEntryScreenState extends State<PhaseGroupEntryScreen> {
  // Controllers to handle text input
  late TextEditingController _faseAController;
  late TextEditingController _faseBController;
  late TextEditingController _faseCController;

  @override
  void initState() {
    super.initState();
    // Initialize with existing data if it exists
    _faseAController = TextEditingController(
      text: widget.phaseGroup.faseA.value.toString(),
    );
    _faseBController = TextEditingController(
      text: widget.phaseGroup.faseB.value.toString(),
    );
    _faseCController = TextEditingController(
      text: widget.phaseGroup.faseC.value.toString(),
    );
  }

  @override
  void dispose() {
    _faseAController.dispose();
    _faseBController.dispose();
    _faseCController.dispose();
    super.dispose();
  }

  void _saveData() {
    // Update the actual object in memory
    widget.phaseGroup.faseA.value =
        double.tryParse(_faseAController.text) ?? 0.0;
    widget.phaseGroup.faseB.value =
        double.tryParse(_faseBController.text) ?? 0.0;
    widget.phaseGroup.faseC.value =
        double.tryParse(_faseCController.text) ?? 0.0;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Valores salvos localmente!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context); // Go back to the folder
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(title: widget.title),
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),

                  _buildInputRow('Fase A', _faseAController),
                  _buildInputRow('Fase B', _faseBController),
                  _buildInputRow('Fase C', _faseCController),

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
            onPressed: () {
              // TODO: Implement camera logic to save imageUrl to phaseGroup.faseX.imageUrl
              print('Open camera for $label');
            },
          ),
        ),
      ),
    );
  }
}
