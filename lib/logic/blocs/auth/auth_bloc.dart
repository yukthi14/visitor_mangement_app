import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SharedPreferences sharedPreferences;

  AuthBloc({required this.sharedPreferences}) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    final isLoggedIn = sharedPreferences.getBool(AppConstants.prefIsLoggedIn) ?? false;
    final username = sharedPreferences.getString(AppConstants.prefLoggedUser) ?? 'Front Desk';

    if (isLoggedIn) {
      emit(Authenticated(username));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLoginSubmitted(LoginSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    await Future.delayed(const Duration(milliseconds: 600)); // Smooth UX transition

    final cleanUser = event.username.trim();
    final cleanPass = event.password;

    if (cleanUser.isEmpty) {
      emit(const AuthFailure(AppConstants.errorEnterUsername));
      return;
    }
    if (cleanPass.isEmpty) {
      emit(const AuthFailure(AppConstants.errorEnterPassword));
      return;
    }
    if (!RegExp(r'[A-Z]').hasMatch(cleanPass)) {
      emit(const AuthFailure(AppConstants.errorPasswordUppercase));
      return;
    }
    if (!RegExp(r'[0-9]').hasMatch(cleanPass)) {
      emit(const AuthFailure(AppConstants.errorPasswordNumber));
      return;
    }
    if (!RegExp(r'[^a-zA-Z0-9\s]').hasMatch(cleanPass)) {
      emit(const AuthFailure(AppConstants.errorPasswordSpecialChar));
      return;
    }

    // Front-desk authentication (flexible for testing/demo)
    await sharedPreferences.setBool(AppConstants.prefIsLoggedIn, true);
    await sharedPreferences.setString(AppConstants.prefLoggedUser, cleanUser);
    emit(Authenticated(cleanUser));
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    await sharedPreferences.setBool(AppConstants.prefIsLoggedIn, false);
    emit(Unauthenticated());
  }
}
