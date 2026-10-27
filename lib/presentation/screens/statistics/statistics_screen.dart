import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../../logic/blocs/auth/auth_event.dart';
import '../../../logic/blocs/visitor/visitor_bloc.dart';
import '../../../logic/blocs/visitor/visitor_event.dart';
import '../../../logic/blocs/visitor/visitor_state.dart';
import '../auth/login_screen.dart';

class StatisticsScreen extends StatefulWidget {
  final bool showAppBar;

  const StatisticsScreen({super.key, this.showAppBar = true});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final DateTime _selectedDate = DateTime.now();

  void _showApiConfigDialog(BuildContext context, String currentUrl) {
    final controller = TextEditingController(text: currentUrl);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mock REST API Configuration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configure the Mock REST API Base URL. All CRUD and status operations synchronize with this endpoint with persistent local caching fallback.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Base URL',
                hintText: 'https://...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newUrl = controller.text.trim();
              if (newUrl.isNotEmpty) {
                context.read<VisitorBloc>().add(UpdateBaseUrlRequested(newUrl));
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('API URL updated: $newUrl'),
                    backgroundColor: const Color(0xFF16A34A),
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Visitor Statistics'),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  tooltip: 'API Settings',
                  onPressed: () {
                    final state = context.read<VisitorBloc>().state;
                    final url = state is VisitorLoaded ? state.baseUrl : '';
                    _showApiConfigDialog(context, url);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded),
                  tooltip: 'Logout',
                  onPressed: () {
                    context.read<AuthBloc>().add(LogoutRequested());
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
              ],
            )
          : null,
      body: BlocBuilder<VisitorBloc, VisitorState>(
        builder: (context, state) {
          int totalCustomers = 0;
          int totalVendors = 0;
          int totalOthers = 0;
          int totalVisitors = 0;
          String baseUrl = '';

          if (state is VisitorLoaded) {
            totalVisitors = state.allVisitors.length;
            baseUrl = state.baseUrl;
            for (var v in state.allVisitors) {
              if (v.visitorType == 'Customer') {
                totalCustomers++;
              } else if (v.visitorType == 'Vendor') {
                totalVendors++;
              } else {
                totalOthers++;
              }
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Date Selector Header Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.primary),
                          const SizedBox(width: 10),
                          Text(
                            DateFormatter.formatDate(_selectedDate.toIso8601String()),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Weekly Activity Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Legend
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLegendItem(const Color(0xFF16A34A), 'Checked In'),
                          const SizedBox(width: 24),
                          _buildLegendItem(const Color(0xFF7C3AED), 'Checked Out'),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Custom Weekly Bar Chart
                      SizedBox(
                        height: 180,
                        child: CustomPaint(
                          size: const Size(double.infinity, 180),
                          painter: WeeklyBarChartPainter(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Visitor Type Breakdown Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Visitor Type',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          // Donut Chart
                          SizedBox(
                            width: 130,
                            height: 130,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CustomPaint(
                                  size: const Size(130, 130),
                                  painter: DonutChartPainter(
                                    customerCount: totalCustomers > 0 ? totalCustomers : 8,
                                    vendorCount: totalVendors > 0 ? totalVendors : 5,
                                    otherCount: totalOthers > 0 ? totalOthers : 2,
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Total',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      totalVisitors > 0 ? totalVisitors.toString() : '15',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),

                          // Legend with counts
                          Expanded(
                            child: Column(
                              children: [
                                _buildTypeCountRow(
                                  const Color(0xFF16A34A),
                                  'Customer',
                                  totalCustomers > 0 ? totalCustomers : 8,
                                ),
                                const Divider(height: 16, color: AppColors.divider),
                                _buildTypeCountRow(
                                  const Color(0xFF1E5AE6),
                                  'Vendor',
                                  totalVendors > 0 ? totalVendors : 5,
                                ),
                                const Divider(height: 16, color: AppColors.divider),
                                _buildTypeCountRow(
                                  const Color(0xFF94A3B8),
                                  'Other',
                                  totalOthers > 0 ? totalOthers : 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // API & System Status Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Mock REST API & Storage',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextButton(
                            onPressed: () => _showApiConfigDialog(context, baseUrl),
                            child: const Text('Change URL'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        baseUrl,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF16A34A),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Persistent Storage Active',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF16A34A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeCountRow(Color color, String label, int count) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class WeeklyBarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final checkedInPaint = Paint()..color = const Color(0xFF16A34A);
    final checkedOutPaint = Paint()..color = const Color(0xFF7C3AED);
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 0.8;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    // Mock daily values for weekly activity
    final checkedInData = [6.0, 9.0, 8.0, 5.0, 7.0, 4.0, 5.0];
    final checkedOutData = [4.0, 7.0, 6.0, 9.0, 6.0, 8.0, 6.0];

    const double chartLeft = 25.0;
    const double chartBottom = 155.0;
    final double chartWidth = size.width - chartLeft - 10;
    const double chartHeight = 135.0;
    const double maxValue = 15.0;

    // Draw horizontal grid lines & Y labels (15, 10, 5, 0)
    for (int i = 0; i <= 3; i++) {
      final yVal = (15 - i * 5);
      final y = 20.0 + (i * (chartHeight / 3));

      canvas.drawLine(
        Offset(chartLeft, y),
        Offset(size.width - 10, y),
        gridPaint,
      );

      textPainter.text = TextSpan(
        text: yVal.toString(),
        style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(chartLeft - textPainter.width - 6, y - 6));
    }

    final double groupWidth = chartWidth / days.length;
    const double barWidth = 6.0;

    for (int i = 0; i < days.length; i++) {
      final groupCenterX = chartLeft + (i * groupWidth) + (groupWidth / 2);

      // Bar 1: Checked In (Green)
      final checkedInHeight = (checkedInData[i] / maxValue) * chartHeight;
      final rect1 = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          groupCenterX - barWidth - 1,
          chartBottom - checkedInHeight,
          barWidth,
          checkedInHeight,
        ),
        const Radius.circular(3),
      );
      canvas.drawRRect(rect1, checkedInPaint);

      // Bar 2: Checked Out (Purple)
      final checkedOutHeight = (checkedOutData[i] / maxValue) * chartHeight;
      final rect2 = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          groupCenterX + 1,
          chartBottom - checkedOutHeight,
          barWidth,
          checkedOutHeight,
        ),
        const Radius.circular(3),
      );
      canvas.drawRRect(rect2, checkedOutPaint);

      // Day label
      textPainter.text = TextSpan(
        text: days[i],
        style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(groupCenterX - (textPainter.width / 2), chartBottom + 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DonutChartPainter extends CustomPainter {
  final int customerCount;
  final int vendorCount;
  final int otherCount;

  DonutChartPainter({
    required this.customerCount,
    required this.vendorCount,
    required this.otherCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = customerCount + vendorCount + otherCount;
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 14.0;

    final paintCustomer = Paint()
      ..color = const Color(0xFF16A34A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final paintVendor = Paint()
      ..color = const Color(0xFF1E5AE6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final paintOther = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    double startAngle = -math.pi / 2;

    // Customer slice
    final sweep1 = (customerCount / total) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      startAngle,
      sweep1 - 0.08,
      false,
      paintCustomer,
    );
    startAngle += sweep1;

    // Vendor slice
    final sweep2 = (vendorCount / total) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      startAngle,
      sweep2 - 0.08,
      false,
      paintVendor,
    );
    startAngle += sweep2;

    // Other slice
    final sweep3 = (otherCount / total) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      startAngle,
      sweep3 - 0.08,
      false,
      paintOther,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
