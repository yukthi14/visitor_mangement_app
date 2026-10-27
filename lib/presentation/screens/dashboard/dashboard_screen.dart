import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../../logic/blocs/auth/auth_event.dart';
import '../../../logic/blocs/auth/auth_state.dart';
import '../../../logic/blocs/visitor/visitor_bloc.dart';
import '../../../logic/blocs/visitor/visitor_event.dart';
import '../../../logic/blocs/visitor/visitor_state.dart';
import '../auth/login_screen.dart';
import '../scanner/qr_scanner_screen.dart';
import '../visitors/register_visitor_screen.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int)? onNavigateToTab;

  const DashboardScreen({super.key, this.onNavigateToTab});

  Widget _buildQuickActionItem({
    required String title,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
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
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
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
    final todayFormatted = DateFormatter.formatHeaderDate(DateTime.now());
    final authState = context.watch<AuthBloc>().state;
    final userName = authState is Authenticated ? authState.username : AppConstants.defaultUser;

    return Scaffold(
      backgroundColor: AppColors.background,
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
      ),
      drawer: Drawer(
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
                onNavigateToTab?.call(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people_outline, color: AppColors.primary),
              title: const Text(AppConstants.titleVisitorList),
              onTap: () {
                Navigator.of(context).pop();
                onNavigateToTab?.call(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner, color: AppColors.primary),
              title: const Text(AppConstants.titleScanQR),
              onTap: () {
                Navigator.of(context).pop();
                onNavigateToTab?.call(2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart_outlined, color: AppColors.primary),
              title: const Text(AppConstants.titleStatistics),
              onTap: () {
                Navigator.of(context).pop();
                onNavigateToTab?.call(3);
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

          int totalToday = 0;
          int checkedIn = 0;
          int checkedOut = 0;

          if (state is VisitorLoaded) {
            totalToday = state.totalVisitorsToday;
            checkedIn = state.currentlyCheckedIn;
            checkedOut = state.checkedOutToday;
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
                  // Date Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          todayFormatted,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Three Stat Cards in a row
                  Row(
                    children: [
                      StatCard(
                        type: StatCardType.totalToday,
                        count: totalToday,
                      ),
                      const SizedBox(width: 10),
                      StatCard(
                        type: StatCardType.checkedIn,
                        count: checkedIn,
                      ),
                      const SizedBox(width: 10),
                      StatCard(
                        type: StatCardType.checkedOut,
                        count: checkedOut,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Quick Actions Header
                  const Text(
                    AppConstants.quickActions,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Quick Action Cards
                  Row(
                    children: [
                      // Register Visitor
                      _buildQuickActionItem(
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
                        title: AppConstants.actionVisitorList,
                        icon: Icons.format_list_bulleted_rounded,
                        iconBgColor: AppColors.statusCheckedInText,
                        iconColor: AppColors.white,
                        onTap: () {
                          if (onNavigateToTab != null) {
                            onNavigateToTab!(1);
                          }
                        },
                      ),
                      const SizedBox(width: 12),

                      // Scan QR Code
                      _buildQuickActionItem(
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
