import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sigma_app/models/plant_model.dart';
import 'package:sigma_app/services/custom_camera_screen.dart';
import 'package:sigma_app/services/local_sync_service.dart';
import 'package:sigma_app/widgets/custom_header.dart';

class IdentificacaoEntryScreen extends StatefulWidget {
  final Plant plant;
  final UFV ufv;

  const IdentificacaoEntryScreen({
    super.key,
    required this.plant,
    required this.ufv,
  });

  @override
  State<IdentificacaoEntryScreen> createState() => _IdentificacaoEntryScreenState();
}

class _IdentificacaoEntryScreenState extends State<IdentificacaoEntryScreen> {
  String _imageUrl = '';

  @override
  void initState() {
    super.initState();
    // Load existing image if there is one
    if (widget.ufv.measurements != null) {
      _imageUrl = widget.ufv.measurements!.identificacaoUrl;
    }
  }

  Future<void> _pickImage() async {
    // 1. Open Custom Camera Screen directly
    final File? imageFile = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CustomCameraScreen(allowedUnits: []), 
      ),
    );

    // 2. If the user took a photo, update the state
    if (imageFile != null) {
      setState(() {
        _imageUrl = imageFile.path;
      });
    }
  }

  Future<void> _save() async {
    if (widget.ufv.measurements != null) {
      widget.ufv.measurements!.identificacaoUrl = _imageUrl;
      await LocalSyncService.savePlantLocally(widget.plant);
    }
    
    if (mounted) {
      Navigator.pop(context, true); // Return true to indicate it was saved
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(title: 'Identificação'),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // TITLE
                      const Text(
                        'PLACA DO TRANSFORMADOR',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Divider(color: Colors.grey.shade300, height: 1),
                      const SizedBox(height: 24),

                      // IMAGE PREVIEW (If exists)
                      if (_imageUrl.isNotEmpty) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_imageUrl),
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // BLACK BUTTON
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: Text(
                          _imageUrl.isEmpty 
                              ? 'Adicionar Imagem Identificação' 
                              : 'Trocar Imagem Identificação',
                          style: const TextStyle(fontSize: 16),
                        ),
                        onPressed: _pickImage,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // PERSISTENT SAVE BUTTON
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'SALVAR',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}