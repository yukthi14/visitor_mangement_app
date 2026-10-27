import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../../logic/blocs/auth/auth_event.dart';
import '../../../logic/blocs/auth/auth_state.dart';
import '../main/main_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  String? _usernameError;
  String? _passwordError;
  String? _generalError;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final isRemembered = prefs.getBool(AppConstants.prefRememberMe) ?? false;
    final savedUsername = prefs.getString(AppConstants.prefRememberedUsername) ?? '';

    if (mounted && isRemembered) {
      setState(() {
        _rememberMe = true;
        if (savedUsername.isNotEmpty) {
          _usernameController.text = savedUsername;
        }
      });
    }
  }

  Future<void> _onRememberMeChanged(bool? value) async {
    final checked = value ?? false;
    setState(() {
      _rememberMe = checked;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefRememberMe, checked);
    if (checked) {
      final currentUsername = _usernameController.text.trim();
      if (currentUsername.isNotEmpty) {
        await prefs.setString(AppConstants.prefRememberedUsername, currentUsername);
      }
    } else {
      await prefs.remove(AppConstants.prefRememberedUsername);
    }
  }

  void _onLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    final userErr = Validators.validateUsername(username);
    final passErr = Validators.validatePassword(password);

    if (userErr != null || passErr != null) {
      setState(() {
        _usernameError = userErr;
        _passwordError = passErr;
        _generalError = null;
      });
      return;
    }

    setState(() {
      _usernameError = null;
      _passwordError = null;
      _generalError = null;
    });

    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setBool(AppConstants.prefRememberMe, true);
      await prefs.setString(AppConstants.prefRememberedUsername, username);
    } else {
      await prefs.setBool(AppConstants.prefRememberMe, false);
      await prefs.remove(AppConstants.prefRememberedUsername);
    }

    if (mounted) {
      context.read<AuthBloc>().add(
            LoginSubmitted(
              username: username,
              password: password,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is Authenticated) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
              );
            } else if (state is AuthFailure) {
              setState(() {
                final errLower = state.error.toLowerCase();
                if (errLower.contains('username')) {
                  _usernameError = state.error;
                } else if (errLower.contains('password')) {
                  _passwordError = state.error;
                } else {
                  _generalError = state.error;
                }
              });
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 70),

                  // Top Icon Badge
                  Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.person,
                                size: 48,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 2),
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.primary, width: 1.8),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(
                                  Icons.badge_outlined,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title & Subtitle
                  const Center(
                    child: Text(
                      AppConstants.appName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Center(
                    child: Text(
                      AppConstants.welcomeBack,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Username Field
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.inputFill,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _usernameError != null ? AppColors.danger : AppColors.border,
                        width: _usernameError != null ? 1.2 : 1.0,
                      ),
                    ),
                    child: TextField(
                      controller: _usernameController,
                      onChanged: (val) {
                        if (_usernameError != null) {
                          setState(() {
                            _usernameError = null;
                          });
                        }
                        if (_rememberMe) {
                          SharedPreferences.getInstance().then((prefs) {
                            prefs.setString(AppConstants.prefRememberedUsername, val.trim());
                          });
                        }
                      },
                      decoration: InputDecoration(
                        hintText: AppConstants.labelUsername,
                        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: _usernameError != null ? AppColors.danger : AppColors.textSecondary,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  if (_usernameError != null) ...[
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 14, color: AppColors.danger),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _usernameError!,
                              style: const TextStyle(
                                color: AppColors.danger,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Password Field
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.inputFill,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _passwordError != null ? AppColors.danger : AppColors.border,
                        width: _passwordError != null ? 1.2 : 1.0,
                      ),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      onChanged: (_) {
                        if (_passwordError != null) {
                          setState(() {
                            _passwordError = null;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        hintText: AppConstants.labelPassword,
                        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: _passwordError != null ? AppColors.danger : AppColors.textSecondary,
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  if (_passwordError != null) ...[
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 14, color: AppColors.danger),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _passwordError!,
                              style: const TextStyle(
                                color: AppColors.danger,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),

                  // Remember Me Checkbox
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _rememberMe,
                          activeColor: AppColors.primary,
                          checkColor: AppColors.white,
                          side: const BorderSide(color: AppColors.textSecondary, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: _onRememberMeChanged,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _onRememberMeChanged(!_rememberMe),
                        child: const Text(
                          AppConstants.labelRememberMe,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // General error if any
                  if (_generalError != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.dangerBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 16, color: AppColors.danger),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _generalError!,
                              style: const TextStyle(
                                color: AppColors.danger,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Login Button
                  ElevatedButton(
                    onPressed: isLoading ? null : _onLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : const Text(
                            AppConstants.labelLogin,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
