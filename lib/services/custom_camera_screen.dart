import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

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
    _initializeCamera();
    _startLocationUpdates(); // Starts the stream immediately
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.high, // Balanced resolution for processing
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      print("Camera initialization error: $e");
    }
  }

  void _startLocationUpdates() async {
    // 1. Request/Check Permissions to wake up hardware
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    // 2. Get last known position for instant display
    final lastPos = await Geolocator.getLastKnownPosition();
    if (lastPos != null && mounted) {
      setState(() => _currentPosition = lastPos);
    }

    // 3. Subscribe to live updates with Balanced accuracy
    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium, // Faster than .high indoors
            distanceFilter: 3, // Update every 3 meters
          ),
        ).listen((Position position) {
          if (mounted) setState(() => _currentPosition = position);
        }, onError: (error) => print("GPS Stream Error: $error"));
  }

  Future<void> _takePicture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isTakingPicture)
      return;

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
        // 2. CROP TO 4:5 RATIO
        int targetWidth = capturedImg.width;
        int targetHeight = (targetWidth * 5) ~/ 4;

        if (targetHeight > capturedImg.height) {
          targetHeight = capturedImg.height;
          targetWidth = (targetHeight * 4) ~/ 5;
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
        String watermarkText = "Data: $ts\nLat: $lat\nLon: $lon";

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
              aspectRatio: 4 / 5,
              child: CameraPreview(_controller!),
            ),
          ),

          // REAL-TIME OVERLAY
          Positioned(
            bottom: 200,
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
