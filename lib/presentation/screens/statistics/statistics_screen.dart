import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../logic/blocs/visitor/visitor_bloc.dart';
import '../../../logic/blocs/visitor/visitor_state.dart';

class StatisticsScreen extends StatefulWidget {
  final bool showAppBar;

  const StatisticsScreen({super.key, this.showAppBar = true});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text(AppConstants.titleStatistics),
              centerTitle: true,
            )
          : null,
      body: BlocBuilder<VisitorBloc, VisitorState>(
        builder: (context, state) {
          if (state is VisitorLoading) {
            return const DashboardShimmer();
          }

          int totalCustomers = 0;
          int totalVendors = 0;
          int totalOthers = 0;
          int totalVisitors = 0;

          // Weekly data initialization (Mon to Sun)
          final checkedInData = List<double>.filled(7, 0.0);
          final checkedOutData = List<double>.filled(7, 0.0);

          if (state is VisitorLoaded) {
            // Calculate Monday of the selected week
            final monday = DateTime(
              _selectedDate.year,
              _selectedDate.month,
              _selectedDate.day,
            ).subtract(Duration(days: _selectedDate.weekday - 1));
            final sundayEnd = monday.add(const Duration(days: 7));

            // Weekly Visitors for the selected week
            final weeklyVisitors = state.allVisitors.where((v) {
              final dates = <DateTime>[];
              final created = DateTime.tryParse(v.createdAt)?.toLocal();
              if (created != null) dates.add(created);
              if (v.checkInTime != null) {
                final inTime = DateTime.tryParse(v.checkInTime!)?.toLocal();
                if (inTime != null) dates.add(inTime);
              }
              if (v.checkOutTime != null) {
                final outTime = DateTime.tryParse(v.checkOutTime!)?.toLocal();
                if (outTime != null) dates.add(outTime);
              }
              return dates.any((d) => !d.isBefore(monday) && d.isBefore(sundayEnd));
            }).toList();

            totalVisitors = weeklyVisitors.length;
            for (var v in weeklyVisitors) {
              if (v.visitorType == AppConstants.typeCustomer) {
                totalCustomers++;
              } else if (v.visitorType == AppConstants.typeVendor) {
                totalVendors++;
              } else {
                totalOthers++;
              }
            }

            for (int i = 0; i < 7; i++) {
              final dayStart = monday.add(Duration(days: i));
              final dayEnd = dayStart.add(const Duration(days: 1));

              for (final v in state.allVisitors) {
                DateTime? checkInDt;
                if (v.checkInTime != null) {
                  checkInDt = DateTime.tryParse(v.checkInTime!)?.toLocal();
                } else if (v.status == AppConstants.statusCheckedIn) {
                  checkInDt = DateTime.tryParse(v.createdAt)?.toLocal();
                }

                if (checkInDt != null &&
                    !checkInDt.isBefore(dayStart) &&
                    checkInDt.isBefore(dayEnd)) {
                  checkedInData[i] += 1.0;
                }

                DateTime? checkOutDt;
                if (v.checkOutTime != null) {
                  checkOutDt = DateTime.tryParse(v.checkOutTime!)?.toLocal();
                } else if (v.status == AppConstants.statusCheckedOut) {
                  checkOutDt = DateTime.tryParse(v.createdAt)?.toLocal();
                }

                if (checkOutDt != null &&
                    !checkOutDt.isBefore(dayStart) &&
                    checkOutDt.isBefore(dayEnd)) {
                  checkedOutData[i] += 1.0;
                }
              }
            }
          }

          // Determine maximum bar value rounded to 5
          final highestVal = [
            15.0,
            ...checkedInData,
            ...checkedOutData,
          ].reduce(math.max);
          final chartMax = ((highestVal / 5).ceil() * 5).toDouble();

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Date Selector Header Card (Interactive)
                Material(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
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
                  ),
                ),
                const SizedBox(height: 16),

                // Weekly Activity Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
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
                          _buildLegendItem(AppColors.statusCheckedInText, AppConstants.statusCheckedIn),
                          const SizedBox(width: 24),
                          _buildLegendItem(AppColors.statusCheckedOutText, AppConstants.statusCheckedOut),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Custom Weekly Bar Chart
                      SizedBox(
                        height: 180,
                        child: CustomPaint(
                          size: const Size(double.infinity, 180),
                          painter: WeeklyBarChartPainter(
                            checkedInData: checkedInData,
                            checkedOutData: checkedOutData,
                            maxValue: chartMax,
                          ),
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
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        AppConstants.labelVisitorType,
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
                                    customerCount: totalCustomers,
                                    vendorCount: totalVendors,
                                    otherCount: totalOthers,
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      AppConstants.labelTotal,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      totalVisitors.toString(),
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
                                  AppColors.statusCheckedInText,
                                  AppConstants.typeCustomer,
                                  totalCustomers,
                                ),
                                const Divider(height: 16, color: AppColors.divider),
                                _buildTypeCountRow(
                                  AppColors.primary,
                                  AppConstants.typeVendor,
                                  totalVendors,
                                ),
                                const Divider(height: 16, color: AppColors.divider),
                                _buildTypeCountRow(
                                  AppColors.textMuted,
                                  AppConstants.typeOther,
                                  totalOthers,
                                ),
                              ],
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
  final List<double> checkedInData;
  final List<double> checkedOutData;
  final double maxValue;
  final List<String> days;

  WeeklyBarChartPainter({
    required this.checkedInData,
    required this.checkedOutData,
    this.maxValue = 15.0,
    this.days = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
  });

  @override
  void paint(Canvas canvas, Size size) {
    final checkedInPaint = Paint()..color = AppColors.statusCheckedInText;
    final checkedOutPaint = Paint()..color = AppColors.statusCheckedOutText;
    final gridPaint = Paint()
      ..color = AppColors.chartGrid
      ..strokeWidth = 0.8;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    const double chartLeft = 25.0;
    const double chartBottom = 155.0;
    final double chartWidth = size.width - chartLeft - 10;
    const double chartHeight = 135.0;

    // Draw horizontal grid lines & Y labels (maxValue, 2/3, 1/3, 0)
    for (int i = 0; i <= 3; i++) {
      final yVal = (maxValue - i * (maxValue / 3)).round();
      final y = 20.0 + (i * (chartHeight / 3));

      canvas.drawLine(
        Offset(chartLeft, y),
        Offset(size.width - 10, y),
        gridPaint,
      );

      textPainter.text = TextSpan(
        text: yVal.toString(),
        style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(chartLeft - textPainter.width - 6, y - 6));
    }

    final double groupWidth = chartWidth / days.length;
    const double barWidth = 6.0;

    for (int i = 0; i < days.length; i++) {
      final groupCenterX = chartLeft + (i * groupWidth) + (groupWidth / 2);

      // Bar 1: Checked In (Green)
      final inCount = i < checkedInData.length ? checkedInData[i] : 0.0;
      final checkedInHeight = maxValue > 0 ? (inCount / maxValue) * chartHeight : 0.0;
      if (checkedInHeight > 0) {
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
      }

      // Bar 2: Checked Out (Purple)
      final outCount = i < checkedOutData.length ? checkedOutData[i] : 0.0;
      final checkedOutHeight = maxValue > 0 ? (outCount / maxValue) * chartHeight : 0.0;
      if (checkedOutHeight > 0) {
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
      }

      // Day label
      textPainter.text = TextSpan(
        text: days[i],
        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(groupCenterX - (textPainter.width / 2), chartBottom + 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant WeeklyBarChartPainter oldDelegate) => true;
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
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 14.0;

    final total = customerCount + vendorCount + otherCount;
    if (total == 0) {
      // Draw clean empty circular outline in AppColors.border
      final emptyPaint = Paint()
        ..color = AppColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawCircle(center, radius - strokeWidth / 2, emptyPaint);
      return;
    }

    final paintCustomer = Paint()
      ..color = AppColors.statusCheckedInText
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final paintVendor = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final paintOther = Paint()
      ..color = AppColors.textMuted
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    double startAngle = -math.pi / 2;

    // Customer slice
    if (customerCount > 0) {
      final sweep1 = (customerCount / total) * 2 * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweep1 > 0.1 ? sweep1 - 0.08 : sweep1,
        false,
        paintCustomer,
      );
      startAngle += sweep1;
    }

    // Vendor slice
    if (vendorCount > 0) {
      final sweep2 = (vendorCount / total) * 2 * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweep2 > 0.1 ? sweep2 - 0.08 : sweep2,
        false,
        paintVendor,
      );
      startAngle += sweep2;
    }

    // Other slice
    if (otherCount > 0) {
      final sweep3 = (otherCount / total) * 2 * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweep3 > 0.1 ? sweep3 - 0.08 : sweep3,
        false,
        paintOther,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) => true;
}
