import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/visitor_model.dart';

class QRDisplayScreen extends StatefulWidget {
  final VisitorModel visitor;

  const QRDisplayScreen({super.key, required this.visitor});

  @override
  State<QRDisplayScreen> createState() => _QRDisplayScreenState();
}

class _QRDisplayScreenState extends State<QRDisplayScreen> {
  static const MethodChannel _storageChannel =
      MethodChannel('com.example.visitor_mangement_app/storage');

  final GlobalKey _qrCardKey = GlobalKey();
  String? savedPath;
  bool _isDownloading = false;

  /// Captures the QR card as a high-resolution PNG screenshot
  /// and saves it directly to the device Downloads folder.
  ///
  /// Uses Android MediaStore Scoped Storage on Android 10+ so it never throws
  /// Permission denied (errno = 13), with seamless fallbacks.
  Future<void> _captureAndSave() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
    });

    try {
      // Short delay to ensure widget is painted cleanly
      await Future.delayed(const Duration(milliseconds: 150));

      final boundary = _qrCardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Render boundary not ready');
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to generate PNG byte data');
      }

      final Uint8List imageBytes = byteData.buffer.asUint8List();
      final fileName = 'qr_${widget.visitor.id}.png';
      String filePath;

      // Tier 1: Try native MediaStore Downloads Scoped Storage API (No permission needed)
      try {
        final String? nativePath = await _storageChannel.invokeMethod<String>(
          'saveToDownloads',
          {
            'fileName': fileName,
            'bytes': imageBytes,
          },
        );
        filePath = nativePath ?? '/storage/emulated/0/Download/$fileName';
      } catch (nativeErr) {
        debugPrint('Native MediaStore channel unavailable ($nativeErr), attempting direct filesystem write');

        // Tier 2: Try direct write to /storage/emulated/0/Download
        bool writeSuccess = false;
        filePath = '/storage/emulated/0/Download/$fileName';

        try {
          final dir = Directory('/storage/emulated/0/Download');
          if (!await dir.exists()) {
            await dir.create(recursive: true);
          }
          final file = File(filePath);
          await file.writeAsBytes(imageBytes);
          writeSuccess = true;
        } catch (fsErr) {
          debugPrint('Direct write to /storage/emulated/0/Download failed: $fsErr');
        }

        // Tier 3: Fallback to app external Download directory (guaranteed accessible without permissions)
        if (!writeSuccess) {
          final fallbackDir = Directory('/storage/emulated/0/Android/data/com.example.visitor_mangement_app/files/Download');
          if (!await fallbackDir.exists()) {
            try {
              await fallbackDir.create(recursive: true);
            } catch (_) {
              // Final fallback if running on non-Android platform (e.g. desktop/test)
              final tempDir = Directory.systemTemp;
              final tempFile = File('${tempDir.path}/$fileName');
              await tempFile.writeAsBytes(imageBytes);
              filePath = tempFile.path;
              writeSuccess = true;
            }
          }

          if (!writeSuccess) {
            final fallbackFile = File('${fallbackDir.path}/$fileName');
            await fallbackFile.writeAsBytes(imageBytes);
            filePath = fallbackFile.path;
          }
        }
      }

      setState(() {
        savedPath = filePath;
        _isDownloading = false;
      });

      debugPrint("QR Code screenshot successfully saved at: $filePath");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: AppColors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${AppConstants.qrDownloadedPrefix} $filePath',
                    style: const TextStyle(color: AppColors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e, s) {
      debugPrint("Screenshot capture error: $e $s");
      setState(() {
        _isDownloading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${AppConstants.qrDownloadFailedPrefix} $e',
                    style: const TextStyle(color: AppColors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppConstants.titleVisitorQRCode),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              // RepaintBoundary wrapping the QR Pass badge for crisp screenshot capture
              RepaintBoundary(
                key: _qrCardKey,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.blackOpacity04,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Visitor Header Info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.visitor.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.visitor.project,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          StatusChip(status: widget.visitor.status),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(height: 1, color: AppColors.divider),
                      const SizedBox(height: 20),

                      // High quality QR code
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          color: AppColors.white,
                          child: QrImageView(
                            data: widget.visitor.toQrData(),
                            version: QrVersions.auto,
                            size: 190.0,
                            backgroundColor: AppColors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Visitor ID label & code
                      const Text(
                        AppConstants.labelVisitorId,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.visitor.id,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${AppConstants.labelPurpose}: ${widget.visitor.purpose}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Saved path indicator badge if downloaded
              if (savedPath != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.statusCheckedInBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.statusCheckedInText.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppColors.statusCheckedInText,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${AppConstants.qrSavedPrefix} $savedPath',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.statusCheckedInText,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Download QR Code Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isDownloading ? null : _captureAndSave,
                  icon: _isDownloading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(AppColors.white),
                          ),
                        )
                      : const Icon(Icons.download_rounded, size: 20),
                  label: Text(
                    _isDownloading ? AppConstants.savingToDownloads : AppConstants.downloadQRCode,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                AppConstants.qrSecurityNotice,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
