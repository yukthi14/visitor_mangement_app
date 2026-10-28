import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../core/widgets/theme_toggle_button.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../../logic/blocs/auth/auth_event.dart';
import '../../../logic/blocs/auth/auth_state.dart';
import '../../../logic/blocs/visitor/visitor_bloc.dart';
import '../../../logic/blocs/visitor/visitor_event.dart';
import '../../../logic/blocs/visitor/visitor_state.dart';
import '../auth/login_screen.dart';
import '../scanner/qr_scanner_screen.dart';
import '../visitors/register_visitor_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const DashboardScreen({super.key, this.onNavigateToTab});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _pickDate() async {
    final isDark = AppColors.isDark(context);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: AppColors.primary,
                    onPrimary: AppColors.white,
                    surface: AppColors.darkSurface,
                    onSurface: AppColors.darkTextPrimary,
                  )
                : const ColorScheme.light(
                    primary: AppColors.primary,
                    onPrimary: AppColors.white,
                    surface: AppColors.white,
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

  Widget _buildQuickActionItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: AppColors.cardBgColor(context),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor(context)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryColor(context),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final userName = authState is Authenticated ? authState.username : AppConstants.defaultUser;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        centerTitle: true,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(ctx).openDrawer();
            },
          ),
        ),
        actions: const [
          ThemeToggleButton(),
        ],
      ),
      drawer: Drawer(
        backgroundColor: AppColors.surfaceColor(context),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppColors.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.white,
                    child: Icon(Icons.person, color: AppColors.primary, size: 36),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userName,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined, color: AppColors.primary),
              title: const Text(AppConstants.titleDashboard),
              onTap: () {
                Navigator.of(context).pop();
                widget.onNavigateToTab?.call(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people_outline, color: AppColors.primary),
              title: const Text(AppConstants.titleVisitorList),
              onTap: () {
                Navigator.of(context).pop();
                widget.onNavigateToTab?.call(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner, color: AppColors.primary),
              title: const Text(AppConstants.titleScanQR),
              onTap: () {
                Navigator.of(context).pop();
                widget.onNavigateToTab?.call(2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart_outlined, color: AppColors.primary),
              title: const Text(AppConstants.titleStatistics),
              onTap: () {
                Navigator.of(context).pop();
                widget.onNavigateToTab?.call(3);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.danger),
              title: const Text(
                AppConstants.labelLogOut,
                style: TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(LogoutRequested());
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: BlocBuilder<VisitorBloc, VisitorState>(
        builder: (context, state) {
          if (state is VisitorLoading) {
            return const DashboardShimmer();
          }

          final now = DateTime.now();
          final isToday = _selectedDate.year == now.year &&
              _selectedDate.month == now.month &&
              _selectedDate.day == now.day;

          int totalCount = 0;
          int checkedIn = 0;
          int checkedOut = 0;

          if (state is VisitorLoaded) {
            if (isToday) {
              totalCount = state.totalVisitorsToday;
              checkedIn = state.currentlyCheckedIn;
              checkedOut = state.checkedOutToday;
            } else {
              final visitorsOnDate = state.allVisitors.where(
                (v) => DateFormatter.isSameDate(v.createdAt, _selectedDate),
              ).toList();
              totalCount = visitorsOnDate.length;
              checkedIn = visitorsOnDate
                  .where((v) => v.status == AppConstants.statusCheckedIn)
                  .length;
              checkedOut = visitorsOnDate
                  .where((v) => v.status == AppConstants.statusCheckedOut)
                  .length;
            }
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<VisitorBloc>().add(const LoadVisitors(isRefresh: true));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Interactive Date Card
                  Row(
                    children: [
                      Material(
                        color: AppColors.cardBgColor(context),
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.borderColor(context)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormatter.formatHeaderDate(_selectedDate),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimaryColor(context),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_drop_down,
                                  size: 18,
                                  color: AppColors.textSecondaryColor(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (!isToday) ...[
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedDate = DateTime.now();
                            });
                          },
                          icon: const Icon(Icons.today, size: 14, color: AppColors.primary),
                          label: const Text(
                            AppConstants.labelToday,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Three Stat Cards in a row
                  Row(
                    children: [
                      StatCard(
                        type: StatCardType.totalToday,
                        count: totalCount,
                        customTitle: isToday ? null : AppConstants.statTotalVisitors,
                      ),
                      const SizedBox(width: 10),
                      StatCard(
                        type: StatCardType.checkedIn,
                        count: checkedIn,
                        customTitle: isToday ? null : AppConstants.statCheckedInDay,
                      ),
                      const SizedBox(width: 10),
                      StatCard(
                        type: StatCardType.checkedOut,
                        count: checkedOut,
                        customTitle: isToday ? null : AppConstants.statCheckedOutDay,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Quick Actions Header
                  Text(
                    AppConstants.quickActions,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryColor(context),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Quick Action Cards
                  Row(
                    children: [
                      // Register Visitor
                      _buildQuickActionItem(
                        context: context,
                        title: AppConstants.actionRegisterVisitor,
                        icon: Icons.add,
                        iconBgColor: AppColors.primary,
                        iconColor: AppColors.white,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RegisterVisitorScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),

                      // Visitor List
                      _buildQuickActionItem(
                        context: context,
                        title: AppConstants.actionVisitorList,
                        icon: Icons.format_list_bulleted_rounded,
                        iconBgColor: AppColors.statusCheckedInText,
                        iconColor: AppColors.white,
                        onTap: () {
                          widget.onNavigateToTab?.call(1);
                        },
                      ),
                      const SizedBox(width: 12),

                      // Scan QR Code
                      _buildQuickActionItem(
                        context: context,
                        title: AppConstants.actionScanQRCode,
                        icon: Icons.qr_code_scanner_rounded,
                        iconBgColor: AppColors.statusCheckedOutText,
                        iconColor: AppColors.white,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const QRScannerScreen(isStandalone: true),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
