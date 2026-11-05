import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:camera_macos/camera_macos.dart';

class CanliKamera extends StatefulWidget {
  const CanliKamera({super.key});

  @override
  State<CanliKamera> createState() => _CanliKameraState();
}

class _CanliKameraState extends State<CanliKamera> {
  CameraController? _controller;
  String? _hata;

  bool get _yerelMac =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

  @override
  void initState() {
    super.initState();
    if (!_yerelMac) {
      _kamerayiAc();
    }
  }

  Future<void> _kamerayiAc() async {
    CameraController? controller;

    try {
      final kameralar = await availableCameras();

      if (!mounted) return;

      if (kameralar.isEmpty) {
        setState(() => _hata = 'Kamera bulunamadı.');
        return;
      }

      final kamera = kameralar.firstWhere(
        (kamera) => kamera.lensDirection == CameraLensDirection.front,
        orElse: () => kameralar.first,
      );

      controller = CameraController(
        kamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() => _controller = controller);
    } catch (e) {
      await controller?.dispose();

      if (!mounted) return;
      setState(() => _hata = 'Kamera açılamadı: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_yerelMac) {
      return CameraMacOSView(
        fit: BoxFit.contain,
        cameraMode: CameraMacOSMode.photo,
        enableAudio: false,
        onCameraInizialized: (CameraMacOSController controller) {},
      );
    }

    if (_hata != null) {
      return Center(
        child: Text(
          _hata!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    final controller = _controller;

    if (controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
      ),
    );
  }
}
