import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../../logic/blocs/theme/theme_bloc.dart';
import '../../logic/blocs/theme/theme_event.dart';
import '../../logic/blocs/theme/theme_state.dart';

class ThemeSelectionDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            return AlertDialog(
              backgroundColor: AppColors.surfaceColor(context),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                AppConstants.titleSelectTheme,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.textPrimaryColor(context),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildThemeOption(
                    context: context,
                    title: AppConstants.labelSystemDefault,
                    subtitle: AppConstants.descSystemDefault,
                    isSelected: themeState.themeMode == ThemeMode.system,
                    onTap: () {
                      context.read<ThemeBloc>().add(const ChangeThemeMode(ThemeMode.system));
                      Navigator.of(ctx).pop();
                    },
                  ),
                  const SizedBox(height: 4),
                  _buildThemeOption(
                    context: context,
                    title: AppConstants.labelLightMode,
                    subtitle: AppConstants.descLightMode,
                    isSelected: themeState.themeMode == ThemeMode.light,
                    onTap: () {
                      context.read<ThemeBloc>().add(const ChangeThemeMode(ThemeMode.light));
                      Navigator.of(ctx).pop();
                    },
                  ),
                  const SizedBox(height: 4),
                  _buildThemeOption(
                    context: context,
                    title: AppConstants.labelDarkMode,
                    subtitle: AppConstants.descDarkMode,
                    isSelected: themeState.themeMode == ThemeMode.dark,
                    onTap: () {
                      context.read<ThemeBloc>().add(const ChangeThemeMode(ThemeMode.dark));
                      Navigator.of(ctx).pop();
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text(
                    AppConstants.cancel,
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Widget _buildThemeOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.primary : AppColors.textSecondaryColor(context),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryColor(context),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryColor(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isCurrentDark = themeState.isDarkMode(context);
        return IconButton(
          icon: Icon(
            isCurrentDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          ),
          tooltip: AppConstants.labelTheme,
          onPressed: () => ThemeSelectionDialog.show(context),
        );
      },
    );
  }
}
