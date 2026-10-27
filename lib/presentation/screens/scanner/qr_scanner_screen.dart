import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/constants/app_colors.dart';
import '../../../logic/blocs/visitor/visitor_bloc.dart';
import '../../../logic/blocs/visitor/visitor_event.dart';
import '../../../logic/blocs/visitor/visitor_state.dart';
import 'scanned_visitor_info_screen.dart';

class QRScannerScreen extends StatefulWidget {
  final bool isStandalone;

  const QRScannerScreen({super.key, this.isStandalone = false});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isProcessing = false;
  bool _isFlashOn = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.trim().isEmpty) return;

    _handleScannedValue(rawValue.trim());
  }

  void _handleScannedValue(String visitorId) {
    setState(() {
      _isProcessing = true;
    });

    final bloc = context.read<VisitorBloc>();
    bloc.add(ScanVisitorRequested(visitorId));
  }

  void _showManualInputDialog() {
    final textController = TextEditingController(text: 'VST001');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter Visitor ID'),
        content: TextField(
          controller: textController,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            hintText: 'e.g. VST001',
            labelText: 'Visitor ID',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (textController.text.trim().isNotEmpty) {
                _handleScannedValue(textController.text.trim());
              }
            },
            child: const Text('Find'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VisitorBloc, VisitorState>(
      listener: (context, state) {
        if (state is VisitorLoaded) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty && _isProcessing) {
            setState(() {
              _isProcessing = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.danger,
              ),
            );
          } else if (state.scannedVisitor != null && _isProcessing) {
            setState(() {
              _isProcessing = false;
            });
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ScannedVisitorInfoScreen(visitor: state.scannedVisitor!),
              ),
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: widget.isStandalone
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null,
          title: const Text(
            'Scan QR Code',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isFlashOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
              ),
              onPressed: () {
                _controller.toggleTorch();
                setState(() {
                  _isFlashOn = !_isFlashOn;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
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
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.camera_alt_outlined, color: Colors.white54, size: 64),
                        const SizedBox(height: 16),
                        const Text(
                          'Camera Unavailable or Permission Denied',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'You can still test and verify scanning by entering a Visitor ID manually.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _showManualInputDialog,
                          icon: const Icon(Icons.keyboard),
                          label: const Text('Enter Visitor ID Manually'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
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
                    color: const Color(0xFF38BDF8),
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
                            top: BorderSide(color: Color(0xFF38BDF8), width: 5),
                            left: BorderSide(color: Color(0xFF38BDF8), width: 5),
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
                            top: BorderSide(color: Color(0xFF38BDF8), width: 5),
                            right: BorderSide(color: Color(0xFF38BDF8), width: 5),
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
                            bottom: BorderSide(color: Color(0xFF38BDF8), width: 5),
                            left: BorderSide(color: Color(0xFF38BDF8), width: 5),
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
                            bottom: BorderSide(color: Color(0xFF38BDF8), width: 5),
                            right: BorderSide(color: Color(0xFF38BDF8), width: 5),
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
                    'Place the QR code within the frame',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: _showManualInputDialog,
                    icon: const Icon(Icons.edit, color: Colors.white70, size: 16),
                    label: const Text(
                      'Enter ID Manually',
                      style: TextStyle(
                        color: Colors.white,
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
                color: Colors.black54,
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
