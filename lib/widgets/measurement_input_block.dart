import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart'; // NEW
import 'package:sigma_app/models/measurements.dart';
import 'package:image/image.dart' as img;
import 'package:sigma_app/services/custom_camera_screen.dart'; // The image processing library

Future<File> _applyWatermark(
  File imageFile,
  String timestamp,
  double lat,
  double lon,
) async {
  // 1. Read the image file
  final bytes = await imageFile.readAsBytes();
  img.Image? originalImage = img.decodeImage(bytes);

  if (originalImage == null) return imageFile;

  // 2. Prepare the text
  String watermarkText =
      'Data: ${timestamp.substring(0, 16).replaceAll('T', ' ')}\nLat: $lat\nLon: $lon';

  // 3. Draw the text on the image
  // We use a built-in font. For high-res photos, you might need a larger font.
  img.drawString(
    font: img.arial24,
    originalImage,
    x: 20, // Margin from left
    y: originalImage.height - 120, // Margin from bottom
    watermarkText,
    color: img.ColorRgb8(255, 255, 255), // White text
  );

  // 4. Save the watermarked image back to the file
  final watermarkedBytes = img.encodeJpg(originalImage);
  return await imageFile.writeAsBytes(watermarkedBytes);
}

class MeasurementInputBlock extends StatefulWidget {
  final String label;
  final MeasurementValue measurementValue;
  final TextEditingController controller;
  final List<String> allowedUnits; // NEW: Dynamic Units!

  const MeasurementInputBlock({
    super.key,
    required this.label,
    required this.measurementValue,
    required this.controller,
    required this.allowedUnits,
  });

  @override
  State<MeasurementInputBlock> createState() => _MeasurementInputBlockState();
}

class _MeasurementInputBlockState extends State<MeasurementInputBlock> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePhoto(bool isEnvironment) async {
    // Push the custom camera screen
    final File? result = await Navigator.push<File>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CustomCameraScreen(allowedUnits: widget.allowedUnits),
      ),
    );

    if (result != null) {
      // The result is already cropped and watermarked!
      setState(() {
        if (isEnvironment) {
          widget.measurementValue.environmentImageUrl = result.path;
        } else {
          widget.measurementValue.imageUrl = result.path;
        }
      });

      // Save to gallery if needed
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

  @override
  Widget build(BuildContext context) {
    // Ensure the current unit is valid for this specific instrument
    String currentUnit =
        widget.allowedUnits.contains(widget.measurementValue.measurementUnit)
        ? widget.measurementValue.measurementUnit
        : widget.allowedUnits.first;

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
            // Title (e.g., "TRAFO: AT - BT")
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

            // 1. Image Block (Medição)
            _buildImageSection(
              title: 'Adicionar Imagem Medição',
              imagePath: widget.measurementValue.imageUrl,
              isEnvironment: false,
            ),
            const SizedBox(height: 16),

            // 2. Image Block (Ambiente)
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
                        value: currentUnit,
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
                            setState(
                              () => widget.measurementValue.measurementUnit =
                                  newValue,
                            );
                          }
                        },
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

  // Handles showing EITHER the "Add Photo" button OR the Image Preview + Timestamp
  Widget _buildImageSection({
    required String title,
    required String imagePath,
    required bool isEnvironment,
  }) {
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

    // IMAGE PREVIEW WITH DELETE AND GPS OVERLAY
    return Stack(
      children: [
        // The Photo
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imagePath.startsWith('http')
              ? Image.network(
                  imagePath, // Uses the Firebase URL
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
                  File(imagePath), // Uses the local phone file
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
        ),
        // Delete Button (Top Right)
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

        // GPS & Timestamp Overlay (Bottom Left)
        if (!isEnvironment && widget.measurementValue.latitude != null)
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.all(6),
              color: Colors.black.withOpacity(0.6),
              child: Text(
                'Data: ${widget.measurementValue.timestamp.substring(0, 16).replaceAll('T', ' ')}\n'
                'Lat: ${widget.measurementValue.latitude}\n'
                'Lon: ${widget.measurementValue.longitude}',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
      ],
    );
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Os serviços de localização estão desativados. Por favor, ative-os.',
          ),
        ),
      );
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissão de localização negada.')),
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'As permissões de localização estão permanentemente negadas.',
          ),
        ),
      );
      return false;
    }

    return true;
  }
}
