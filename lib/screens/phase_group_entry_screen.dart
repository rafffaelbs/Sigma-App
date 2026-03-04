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

  final String plantId;
  final String ufvId;

  const PhaseGroupEntryScreen({
    super.key,
    required this.title,
    required this.phaseGroup,
    required this.allowedUnits,
    required this.plantId, // Require them in the constructor
    required this.ufvId, // Require them in the constructor
  });

  @override
  State<PhaseGroupEntryScreen> createState() => _PhaseGroupEntryScreenState();
}

class _PhaseGroupEntryScreenState extends State<PhaseGroupEntryScreen> {
  late TextEditingController _faseAController;
  late TextEditingController _faseBController;
  late TextEditingController _faseCController;
  String? _selectedEquip;
  bool _isUploading = false;

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
    _selectedEquip = widget.phaseGroup.equipamento;
  }

  @override
  void dispose() {
    _faseAController.dispose();
    _faseBController.dispose();
    _faseCController.dispose();
    super.dispose();
  }

  void _saveData() {
    // Notice we removed 'async' and 'Future'
    // Basic validation before saving
    if (_selectedEquip == null || _selectedEquip!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione o equipamento.')),
      );
      return;
    }

    // 1. Update values and equipment locally (this updates the main UFV object by reference)
    widget.phaseGroup.faseA.value =
        double.tryParse(_faseAController.text) ?? 0.0;
    widget.phaseGroup.faseB.value =
        double.tryParse(_faseBController.text) ?? 0.0;
    widget.phaseGroup.faseC.value =
        double.tryParse(_faseCController.text) ?? 0.0;
    widget.phaseGroup.equipamento = _selectedEquip!;

    // Note: The local image paths (/data/user/...) are ALREADY saved inside
    // widget.phaseGroup by your MeasurementInputBlock when you take the photo!

    // 2. Return to the previous screen and pass 'true' to signal a successful save
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      measurementType: 'Megohmetro',
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
                          backgroundColor: _isUploading
                              ? Colors.grey
                              : Colors.black,
                        ),
                        onPressed: _isUploading ? null : _saveData,
                        child: _isUploading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Salvar Medições',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
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
