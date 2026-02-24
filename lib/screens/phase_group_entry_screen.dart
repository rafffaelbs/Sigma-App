import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sigma_app/models/measurements.dart';
import 'package:sigma_app/services/upload_service.dart';
import 'package:sigma_app/widgets/custom_header.dart';
import 'package:sigma_app/widgets/equipments_dropdown.dart';
import 'package:sigma_app/widgets/measurement_input_block.dart';

class PhaseGroupEntryScreen extends StatefulWidget {
  final String title;
  final PhaseGroup phaseGroup;
  final List<String> allowedUnits;

  const PhaseGroupEntryScreen({
    super.key,
    required this.title,
    required this.phaseGroup,
    required this.allowedUnits,
  });

  @override
  State<PhaseGroupEntryScreen> createState() => _PhaseGroupEntryScreenState();
}

class _PhaseGroupEntryScreenState extends State<PhaseGroupEntryScreen> {
  late TextEditingController _faseAController;
  late TextEditingController _faseBController;
  late TextEditingController _faseCController;
  String? _selectedEquip;

  @override
  void initState() {
    super.initState();
    _faseAController = TextEditingController(
      text: widget.phaseGroup.faseA.value > 0
          ? widget.phaseGroup.faseA.value.toString()
          : '',
    );
    _faseBController = TextEditingController(
      text: widget.phaseGroup.faseB.value > 0
          ? widget.phaseGroup.faseB.value.toString()
          : '',
    );
    _faseCController = TextEditingController(
      text: widget.phaseGroup.faseC.value > 0
          ? widget.phaseGroup.faseC.value.toString()
          : '',
    );
  }

  @override
  void dispose() {
    _faseAController.dispose();
    _faseBController.dispose();
    _faseCController.dispose();
    super.dispose();
  }

  bool _isUploading = false; // Add this to your State class

  Future<void> _saveData() async {
    setState(() => _isUploading = true);
    try {
      // 1. Update values
      widget.phaseGroup.faseA.value =
          double.tryParse(_faseAController.text) ?? 0.0;
      // ... same for B and C

      // 2. Wrap phases in a temporary map for the service
      final phaseMap = {
        'Fase_A': widget.phaseGroup.faseA,
        'Fase_B': widget.phaseGroup.faseB,
        'Fase_C': widget.phaseGroup.faseC,
      };

      // 3. Let the service handle the logic
      await UploadService.uploadGroupImages(
        readings: phaseMap,
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Use the new custom widget! Passes the specific measurement object directly.
                    MeasurementInputBlock(
                      label: 'Fase A',
                      measurementValue: widget.phaseGroup.faseA,
                      controller: _faseAController,
                      allowedUnits: widget.allowedUnits,
                    ),
                    MeasurementInputBlock(
                      label: 'Fase B',
                      measurementValue: widget.phaseGroup.faseB,
                      controller: _faseBController,
                      allowedUnits: widget.allowedUnits,
                    ),
                    MeasurementInputBlock(
                      label: 'Fase C',
                      measurementValue: widget.phaseGroup.faseC,
                      controller: _faseCController,
                      allowedUnits: widget.allowedUnits,
                    ),
                    EquipmentDropdown(
                      measurementType:
                          'Megohmetro', // Pass dynamically if needed
                      selectedValue: _selectedEquip,
                      onChanged: (val) {
                        setState(() {
                          _selectedEquip = val;
                        });
                      },
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                        ), // Optional color pop for the save button
                        onPressed: _saveData,
                        child: const Text(
                          'Salvar Medições',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
