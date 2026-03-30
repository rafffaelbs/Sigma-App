// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:sigma_app/models/measurements.dart';
import 'package:sigma_app/services/custom_camera_screen.dart'; // The image processing library
import 'package:sigma_app/services/evaluation_service.dart'; // --- NEW: Import the evaluation service ---
import 'package:sigma_app/models/plant_model.dart'; // --- NEW: Needed for UFV ---

class MeasurementInputBlock extends StatefulWidget {
  final String label;
  final MeasurementValue measurementValue;
  final TextEditingController controller;
  final List<String> allowedUnits;
  final String
  instrumentType; // --- NEW: Pass the instrument name (e.g., 'Megohmetro') ---
  final UFV ufv; // --- NEW: Pass the UFV for future formula calculations ---

  const MeasurementInputBlock({
    super.key,
    required this.label,
    required this.measurementValue,
    required this.controller,
    required this.allowedUnits,
    required this.instrumentType,
    required this.ufv,
  });

  @override
  State<MeasurementInputBlock> createState() => _MeasurementInputBlockState();
}

class _MeasurementInputBlockState extends State<MeasurementInputBlock> {
  Future<void> _takePhoto(bool isEnvironment) async {
    final File? result = await Navigator.push<File>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CustomCameraScreen(allowedUnits: widget.allowedUnits),
      ),
    );

    if (result != null) {
      setState(() {
        if (isEnvironment) {
          widget.measurementValue.environmentImageUrl = result.path;
        } else {
          widget.measurementValue.imageUrl = result.path;
        }
      });
      await Gal.putImage(result.path);
    }
  }

  void _removePhoto(bool isEnvironment) {
    setState(() {
      if (isEnvironment) {
        widget.measurementValue.environmentImageUrl = "";
      } else {
        widget.measurementValue.imageUrl = "";
      }
    });
  }

  // --- NEW: Helper method to run the evaluation ---
  void _runEvaluation() {
    setState(() {
      widget.measurementValue.evaluation = EvaluationService.evaluate(
        widget.instrumentType,
        widget.controller.text,
        widget.measurementValue.measurementUnit,
        widget.ufv,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use the stored unit value (even if empty), don't default to first option
    String currentUnit = widget.measurementValue.measurementUnit;

    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                widget.label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 24, thickness: 1),

            _buildImageSection(
              title: 'Adicionar Imagem Medição',
              imagePath: widget.measurementValue.imageUrl,
              isEnvironment: false,
            ),
            const SizedBox(height: 16),

            _buildImageSection(
              title: 'Adicionar Imagem Ambiente',
              imagePath: widget.measurementValue.environmentImageUrl,
              isEnvironment: true,
            ),
            const SizedBox(height: 16),

            // 3. Value Input & Dropdown
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      // --- NEW: Trigger evaluation when typing ---
                      onChanged: (value) {
                        widget.measurementValue.value =
                            double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
                        _runEvaluation();
                      },
                      decoration: const InputDecoration(
                        hintText: 'Insira o Valor...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: currentUnit.isNotEmpty ? currentUnit : null,
                        hint: const Text(
                          'Unidade',
                          style: TextStyle(color: Colors.grey),
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.black,
                        ),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        items: widget.allowedUnits.map((String unit) {
                          return DropdownMenuItem<String>(
                            value: unit,
                            child: Text(unit),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              widget.measurementValue.measurementUnit =
                                  newValue;
                            });
                            // --- NEW: Trigger evaluation when unit changes ---
                            _runEvaluation();
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- NEW: Display the evaluation badge only when value AND unit are filled ---
            if (widget.measurementValue.evaluation != 'none' &&
                widget.measurementValue.value > 0.0 &&
                widget.measurementValue.measurementUnit.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: _buildEvaluationBadge(
                    widget.measurementValue.evaluation,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- NEW: Visual Badge builder ---
  Widget _buildEvaluationBadge(String status) {
    Color bgColor;
    Color textColor;
    String text;
    IconData icon;

    switch (status) {
      case 'aprovado':
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        text = 'APROVADO';
        icon = Icons.check_circle;
        break;
      case 'alerta':
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade800;
        text = 'ALERTA';
        icon = Icons.warning_rounded;
        break;
      case 'reprovado':
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        text = 'REPROVADO';
        icon = Icons.cancel;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection({
    required String title,
    required String imagePath,
    required bool isEnvironment,
  }) {
    // ... (Keep your existing _buildImageSection exactly as it is) ...
    if (imagePath.isEmpty) {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.centerLeft,
          ),
          icon: const Icon(Icons.camera_alt_outlined),
          label: Text(title, style: const TextStyle(fontSize: 16)),
          onPressed: () => _takePhoto(isEnvironment),
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imagePath.startsWith('http')
              ? Image.network(
                  imagePath,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const SizedBox(
                      height: 250,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => const SizedBox(
                    height: 250,
                    child: Center(child: Icon(Icons.broken_image, size: 50)),
                  ),
                )
              : Image.file(
                  File(imagePath),
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: CircleAvatar(
            backgroundColor: Colors.redAccent,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () => _removePhoto(isEnvironment),
            ),
          ),
        ),
      ],
    );
  }
}
