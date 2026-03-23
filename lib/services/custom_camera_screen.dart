import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class CustomCameraScreen extends StatefulWidget {
  final List<String> allowedUnits;

  const CustomCameraScreen({super.key, required this.allowedUnits});

  @override
  State<CustomCameraScreen> createState() => _CustomCameraScreenState();
}

class _CustomCameraScreenState extends State<CustomCameraScreen> {
  CameraController? _controller;
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStream;
  bool _isTakingPicture = false;

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndInitialize();
  }

  // Unified permission request method
  Future<void> _requestPermissionsAndInitialize() async {
    try {
      print("Starting permission request...");

      // Try unified permission request first
      Map<Permission, PermissionStatus> currentStatuses = await [
        Permission.camera,
        Permission.location,
        Permission.locationWhenInUse,
      ].request();

      print("Permission statuses: $currentStatuses");

      // Check if all permissions are granted
      bool cameraGranted =
          currentStatuses[Permission.camera]?.isGranted ?? false;
      bool locationGranted =
          (currentStatuses[Permission.location]?.isGranted ?? false) ||
          (currentStatuses[Permission.locationWhenInUse]?.isGranted ?? false);

      print(
        "Camera granted: $cameraGranted, Location granted: $locationGranted",
      );

      if (cameraGranted && locationGranted) {
        // Both permissions granted, proceed with initialization
        print("Permissions granted, initializing camera and location...");
        await _initializeCamera();
        _startLocationUpdates();
      } else {
        // Try fallback approach if unified approach didn't work
        print("Trying fallback approach...");
        await _fallbackPermissionRequest();
      }
    } catch (e) {
      print("Permission request error: $e");
      print("Stack trace: ${StackTrace.current}");

      // Try one more time with the fallback approach
      try {
        print("Last resort: trying fallback approach...");
        await _fallbackPermissionRequest();
      } catch (fallbackError) {
        print("All permission approaches failed: $fallbackError");

        // Show more detailed error message
        String errorMessage = "Erro ao solicitar permissões";
        if (e.toString().contains("PermissionHandler")) {
          errorMessage =
              "Erro no sistema de permissões. Tente reiniciar o app.";
        } else if (e.toString().contains("Camera") ||
            fallbackError.toString().contains("Camera")) {
          errorMessage =
              "Erro ao acessar a câmera. Verifique se o dispositivo tem câmera.";
        } else if (e.toString().contains("Location") ||
            fallbackError.toString().contains("Location")) {
          errorMessage =
              "Erro ao acessar localização. Verifique se o GPS está ativado.";
        } else if (fallbackError.toString().contains("negada")) {
          errorMessage =
              "Permissões foram negadas. Por favor, habilite nas configurações do app.";
        }

        _showErrorDialog(errorMessage);
      }
    }
  }

  void _showPermissionDeniedDialog(bool cameraGranted, bool locationGranted) {
    String message = "";
    if (!cameraGranted && !locationGranted) {
      message =
          "É necessário conceder permissões de câmera e localização para usar esta funcionalidade.";
    } else if (!cameraGranted) {
      message =
          "É necessário conceder permissão de câmera para usar esta funcionalidade.";
    } else {
      message =
          "É necessário conceder permissão de localização para usar esta funcionalidade.";
    }

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Permissões Necessárias"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                openAppSettings(); // Opens app settings
              },
              child: const Text("Configurações"),
            ),
          ],
        ),
      );
    }
  }

  void _showErrorDialog(String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Erro"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _initializeCamera() async {
    try {
      print("Initializing camera...");
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception("Nenhuma câmera encontrada no dispositivo");
      }

      _controller = CameraController(
        cameras.first,
        ResolutionPreset.high, // Balanced resolution for processing
        enableAudio: false,
      );

      await _controller!.initialize();
      print("Camera initialized successfully");
      if (mounted) setState(() {});
    } catch (e) {
      print("Camera initialization error: $e");
      throw e; // Re-throw to handle in the main permission method
    }
  }

  // Fallback method using the original approach
  Future<void> _fallbackPermissionRequest() async {
    try {
      print("Trying fallback permission request...");

      // Request location permission first
      LocationPermission locationPermission =
          await Geolocator.checkPermission();
      if (locationPermission == LocationPermission.denied) {
        locationPermission = await Geolocator.requestPermission();
        if (locationPermission == LocationPermission.denied) {
          throw Exception("Permissão de localização negada");
        }
      }

      // Then initialize camera (will request camera permission)
      await _initializeCamera();
      _startLocationUpdates();
    } catch (e) {
      print("Fallback permission request failed: $e");
      throw e;
    }
  }

  void _startLocationUpdates() async {
    // 1. Get last known position for instant display
    final lastPos = await Geolocator.getLastKnownPosition();
    if (lastPos != null && mounted) {
      setState(() => _currentPosition = lastPos);
    }

    // 2. Subscribe to live updates with Balanced accuracy
    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium, // Faster than .high indoors
            distanceFilter: 3, // Update every 3 meters
          ),
        ).listen((Position position) {
          if (mounted) setState(() => _currentPosition = position);
          // ignore: avoid_print
        }, onError: (error) => print("GPS Stream Error: $error"));
  }

  Future<void> _takePicture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isTakingPicture) {
      return;
    }

    setState(() => _isTakingPicture = true);

    // Fallback: If stream hasn't provided a position, try a quick pull
    Position? position = _currentPosition;
    if (position == null) {
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        ).timeout(const Duration(seconds: 3));
      } catch (_) {}
    }

    try {
      final XFile rawImage = await _controller!.takePicture();
      final File imageFile = File(rawImage.path);

      // 1. Decode image bytes
      final bytes = await imageFile.readAsBytes();
      img.Image? capturedImg = img.decodeImage(bytes);

      if (capturedImg != null) {
        // 2. CROP TO 1:1 RATIO
        int targetWidth = capturedImg.width;
        int targetHeight = capturedImg.width; // square

        if (targetHeight > capturedImg.height) {
          targetHeight = capturedImg.height;
          targetWidth = capturedImg.height; // square
        }

        int x = (capturedImg.width - targetWidth) ~/ 2;
        int y = (capturedImg.height - targetHeight) ~/ 2;

        img.Image croppedImg = img.copyCrop(
          capturedImg,
          x: x,
          y: y,
          width: targetWidth,
          height: targetHeight,
        );

        // 3. APPLY WATERMARK
        String ts = DateTime.now().toString().substring(0, 16);
        String lat = position?.latitude.toString() ?? "N/A";
        String lon = position?.longitude.toString() ?? "N/A";

        List<String> lines = ["Lat: $lat", "Long: $lon", "Date: $ts"];

        // Define text position and box padding
        int textX = 35;
        int textY = croppedImg.height - 110;
        int padding = 15;
        int fontSize = 24; // Approximate height of arial24
        int lineSpacing = 1;

        // Draw the semi-transparent black rectangle (80% opacity)
        // Note: In the image library, alpha 204 is roughly 80% (255 * 0.8)
        img.fillRect(
          croppedImg,
          x1: textX - padding,
          y1: textY - padding,
          x2: textX + 300, // Adjust width based on your longest string
          y2: textY + 90, // Adjust height based on number of lines
          color: img.ColorRgba8(0, 0, 0, 204), // Black with ~80% opacity
        );

        // Draw the text on top of the box
        for (var line in lines) {
          img.drawString(
            croppedImg,
            line,
            font: img.arial24,
            x: textX,
            y: textY,
            color: img.ColorRgb8(255, 255, 255),
          );
          // Increment Y for the next line
          textY += fontSize + lineSpacing;
        }

        // 4. SAVE FINAL PROCESSED FILE
        final finalBytes = img.encodeJpg(croppedImg);
        final directory = await getTemporaryDirectory();
        final finalFile = File(
          '${directory.path}/watermarked_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await finalFile.writeAsBytes(finalBytes);

        if (mounted) Navigator.pop(context, finalFile);
      }
    } catch (e) {
      print("Error processing picture: $e");
    } finally {
      if (mounted) setState(() => _isTakingPicture = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 4:5 Viewfinder
          Center(
            child: AspectRatio(
              aspectRatio: 1 / 1,
              child: CameraPreview(_controller!),
            ),
          ),

          // REAL-TIME OVERLAY
          Positioned(
            bottom: 250,
            left: 20,

            child: Container(
              // Update the Container in the REAL-TIME OVERLAY section of your build method
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8), // Matches the final file
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Lat: ${_currentPosition?.latitude ?? "Buscando satélites..."}\n'
                'Lon: ${_currentPosition?.longitude ?? "..."}\n'
                'Data: ${DateTime.now().toString().substring(0, 16)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ),

          // CAPTURE BUTTON
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _takePicture,
                child: CircleAvatar(
                  radius: 38,
                  backgroundColor: Colors.white,
                  child: _isTakingPicture
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Icon(
                          Icons.camera_alt,
                          size: 35,
                          color: Colors.black,
                        ),
                ),
              ),
            ),
          ),

          // BACK BUTTON
          Positioned(
            top: 40,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _positionStream?.cancel(); // Important to stop battery drain
    super.dispose();
  }
}
