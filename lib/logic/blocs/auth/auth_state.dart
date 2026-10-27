import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final String username;
  const Authenticated(this.username);

  @override
  List<Object?> get props => [username];
}

class Unauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String error;
  const AuthFailure(this.error);

  @override
  List<Object?> get props => [error];
}
