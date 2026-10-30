import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/visitor_model.dart';
import '../../../logic/blocs/visitor/visitor_bloc.dart';
import '../../../logic/blocs/visitor/visitor_event.dart';
import '../../../logic/blocs/visitor/visitor_state.dart';
import 'scanned_visitor_info_screen.dart';

class QRScannerScreen extends StatefulWidget {
  final bool isStandalone;
  final bool isActive;

  const QRScannerScreen({
    super.key,
    this.isStandalone = false,
    this.isActive = true,
  });

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isProcessing = false;
  bool _isFlashOn = false;
  Timer? _processingTimeout;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        context.read<VisitorBloc>().add(const ClearSelectedVisitor());
      }
    });
  }

  @override
  void didUpdateWidget(QRScannerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      if (widget.isActive) {
        setState(() {
          _isProcessing = false;
        });
        context.read<VisitorBloc>().add(const ClearSelectedVisitor());
        if (!_controller.value.isRunning) {
          _controller.start();
        }
      } else {
        _processingTimeout?.cancel();
        if (_isProcessing) {
          setState(() {
            _isProcessing = false;
          });
        }
        if (_controller.value.isRunning) {
          _controller.stop();
        }
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _processingTimeout?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (widget.isActive && !_controller.value.isRunning) {
        _controller.start();
      }
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing || !widget.isActive) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.trim().isEmpty) return;

    _handleScannedValue(rawValue.trim());
  }

  void _handleScannedValue(String visitorId) {
    if (!mounted) return;
    setState(() {
      _isProcessing = true;
    });

    _processingTimeout?.cancel();
    _processingTimeout = Timer(const Duration(seconds: 8), () {
      if (mounted && _isProcessing) {
        setState(() {
          _isProcessing = false;
        });
        context.read<VisitorBloc>().add(const ClearSelectedVisitor());
      }
    });

    final bloc = context.read<VisitorBloc>();
    bloc.add(ScanVisitorRequested(visitorId));
  }

  void _showInvalidQrDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.surfaceColor(context),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.dangerBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: AppColors.danger,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppConstants.titleInvalidQR,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryColor(context),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondaryColor(context),
            height: 1.4,
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              if (mounted) {
                setState(() {
                  _isProcessing = false;
                });
                context.read<VisitorBloc>().add(const ClearSelectedVisitor());
              }
            },
            child: const Text(AppConstants.scanAgain),
          ),
        ],
      ),
    );
  }

  void _showManualInputDialog() {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppConstants.titleManualInput),
        content: TextField(
          controller: textController,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            hintText: AppConstants.hintVisitorId,
            labelText: AppConstants.labelVisitorId,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(AppConstants.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (textController.text.trim().isNotEmpty) {
                _handleScannedValue(textController.text.trim());
              }
            },
            child: const Text(AppConstants.find),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToScannedVisitor(VisitorModel visitor) async {
    setState(() {
      _isProcessing = false;
    });

    try {
      await _controller.stop();
    } catch (_) {}

    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ScannedVisitorInfoScreen(visitor: visitor),
      ),
    );

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });
    context.read<VisitorBloc>().add(const ClearSelectedVisitor());
    if (widget.isActive) {
      try {
        await _controller.start();
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VisitorBloc, VisitorState>(
      listener: (context, state) {
        if (state is VisitorLoaded) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty && _isProcessing) {
            _processingTimeout?.cancel();
            _showInvalidQrDialog(state.errorMessage!);
          } else if (state.scannedVisitor != null && _isProcessing) {
            _processingTimeout?.cancel();
            _navigateToScannedVisitor(state.scannedVisitor!);
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.black,
        appBar: AppBar(
          backgroundColor: AppColors.transparent,
          elevation: 0,
          leading: widget.isStandalone
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.white),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null,
          title: const Text(
            AppConstants.titleScanQR,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isFlashOn ? Icons.flash_on : Icons.flash_off,
                color: AppColors.white,
              ),
              onPressed: () {
                _controller.toggleTorch();
                setState(() {
                  _isFlashOn = !_isFlashOn;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.flip_camera_ios, color: AppColors.white),
              onPressed: () => _controller.switchCamera(),
            ),
          ],
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            // Camera scanner
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              errorBuilder: (context, error, child) {
                final isPermission = error.errorCode == MobileScannerErrorCode.permissionDenied;
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isPermission ? Icons.no_photography_outlined : Icons.camera_alt_outlined,
                          color: AppColors.whiteOpacity54,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isPermission ? 'Camera Permission Required' : 'Camera Unavailable',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isPermission
                              ? 'Camera permission was denied. Please grant camera access in app settings.'
                              : (error.errorDetails?.toString() ?? AppConstants.cameraPermissionNotice),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.whiteOpacity70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 12,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () async {
                                try {
                                  await _controller.start();
                                } catch (_) {}
                              },
                              icon: const Icon(Icons.refresh_rounded, color: AppColors.white),
                              label: const Text('Retry Camera', style: TextStyle(color: AppColors.white)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.whiteOpacity54),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _showManualInputDialog,
                              icon: const Icon(Icons.keyboard),
                              label: const Text(AppConstants.enterVisitorIdManually),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Scanning overlay frame with corner guides
            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.scannerFrame,
                    width: 2.5,
                  ),
                ),
                child: Stack(
                  children: [
                    // Corner accents
                    Positioned(
                      top: -2,
                      left: -2,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: AppColors.scannerFrame, width: 5),
                            left: BorderSide(color: AppColors.scannerFrame, width: 5),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: AppColors.scannerFrame, width: 5),
                            right: BorderSide(color: AppColors.scannerFrame, width: 5),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -2,
                      left: -2,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: AppColors.scannerFrame, width: 5),
                            left: BorderSide(color: AppColors.scannerFrame, width: 5),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: AppColors.scannerFrame, width: 5),
                            right: BorderSide(color: AppColors.scannerFrame, width: 5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Instructional text below scanner
            Positioned(
              bottom: 90,
              child: Column(
                children: [
                  const Text(
                    AppConstants.alignQRNotice,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: _showManualInputDialog,
                    icon: const Icon(Icons.edit, color: AppColors.whiteOpacity70, size: 16),
                    label: const Text(
                      AppConstants.enterIdManually,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_isProcessing)
              Container(
                color: AppColors.blackOpacity54,
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
