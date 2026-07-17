import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import 'widgets/framing_overlay.dart';

/// A full-screen live viewfinder for capturing a lot photo in-app, with a
/// framing overlay to guide alignment. Pops with the captured [XFile], or
/// null if the user backs out.
class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool _initializing = true;
  bool _capturing = false;
  bool _torchOn = false;

  /// Error kind, resolved to localized text in [build] ('' fields cannot use
  /// Localizations from initState). One of: 'noCamera', a CameraException
  /// code, or 'generic'.
  String? _errorCode;

  String _errorText(AppLocalizations l10n) => switch (_errorCode) {
        'noCamera' => l10n.noCameraFound,
        'CameraAccessDenied' ||
        'CameraAccessDeniedWithoutPrompt' ||
        'CameraAccessRestricted' =>
          l10n.cameraAccessDenied,
        'generic' || null => l10n.cameraStartFailed,
        _ => l10n.cameraStartFailedCode(_errorCode!),
      };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setUp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _controller;
    if (state == AppLifecycleState.inactive) {
      if (c != null) {
        _controller = null;
        c.dispose();
        if (mounted) setState(() {}); // fall back to the loading state
      }
    } else if (state == AppLifecycleState.resumed && c == null && !_initializing) {
      _setUp();
    }
  }

  Future<void> _setUp() async {
    setState(() {
      _initializing = true;
      _errorCode = null;
    });
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw CameraException('noCamera', 'no camera');
      }
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        back,
        ResolutionPreset.high, // ample for OCR, keeps capture fast
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _initializing = false;
        _torchOn = false;
      });
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _errorCode = e.code; // resolved to localized text in build()
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _errorCode = 'generic';
      });
    }
  }

  Future<void> _toggleTorch() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    try {
      final next = _torchOn ? FlashMode.off : FlashMode.torch;
      await c.setFlashMode(next);
      setState(() => _torchOn = !_torchOn);
    } catch (_) {
      // Some devices lack a torch; fail quietly.
    }
  }

  Future<void> _capture() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized || _capturing) return;
    setState(() => _capturing = true);
    try {
      final file = await c.takePicture();
      if (!mounted) return;
      Navigator.of(context).pop(file);
    } catch (_) {
      if (!mounted) return;
      setState(() => _capturing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).captureFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _errorCode != null
            ? _ErrorView(message: _errorText(l10n), onRetry: _setUp)
            : _initializing || _controller == null
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.gold),
                  )
                : _Viewfinder(
                    controller: _controller!,
                    capturing: _capturing,
                    torchOn: _torchOn,
                    onCapture: _capture,
                    onToggleTorch: _toggleTorch,
                  ),
      ),
    );
  }
}

class _Viewfinder extends StatelessWidget {
  const _Viewfinder({
    required this.controller,
    required this.capturing,
    required this.torchOn,
    required this.onCapture,
    required this.onToggleTorch,
  });

  final CameraController controller;
  final bool capturing;
  final bool torchOn;
  final VoidCallback onCapture;
  final VoidCallback onToggleTorch;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        // Live preview, cover-cropped to fill the screen. previewSize is in
        // sensor (landscape) orientation, so width/height are swapped here.
        ClipRect(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: controller.value.previewSize?.height ?? 1080,
              height: controller.value.previewSize?.width ?? 1920,
              child: CameraPreview(controller),
            ),
          ),
        ),

        const FramingOverlay(),

        // Top bar: close + torch.
        Positioned(
          top: 8,
          left: 4,
          right: 4,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                tooltip: l10n.back,
                onPressed: () => Navigator.of(context).pop(),
              ),
              IconButton(
                icon: Icon(
                  torchOn ? Icons.flashlight_on : Icons.flashlight_off,
                  color: torchOn ? AppColors.gold : Colors.white,
                ),
                tooltip: l10n.torch,
                onPressed: onToggleTorch,
              ),
            ],
          ),
        ),

        // Shutter.
        Positioned(
          bottom: 36,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: capturing ? null : onCapture,
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.15),
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: capturing
                    ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Container(
                        margin: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.vermilion,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.no_photography_outlined,
              color: Colors.white54, size: 56),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, height: 1.7),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                ),
                child: Text(l10n.back),
              ),
              const SizedBox(width: 12),
              FilledButton(onPressed: onRetry, child: Text(l10n.retry)),
            ],
          ),
        ],
      ),
    );
  }
}
