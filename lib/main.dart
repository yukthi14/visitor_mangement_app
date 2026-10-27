import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'data/datasources/visitor_local_datasource.dart';
import 'data/datasources/visitor_remote_datasource.dart';
import 'data/repositories/visitor_repository.dart';
import 'logic/blocs/auth/auth_bloc.dart';
import 'logic/blocs/auth/auth_event.dart';
import 'logic/blocs/visitor/visitor_bloc.dart';
import 'logic/blocs/visitor/visitor_event.dart';
import 'presentation/screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Initialize HTTP Client and Data Sources
  final httpClient = http.Client();
  final localDataSource = VisitorLocalDataSourceImpl(sharedPreferences: sharedPreferences);
  final remoteDataSource = VisitorRemoteDataSourceImpl(client: httpClient);

  // Initialize Repository
  final visitorRepository = VisitorRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );

  runApp(
    VisitorManagementApp(
      visitorRepository: visitorRepository,
      sharedPreferences: sharedPreferences,
    ),
  );
}

class VisitorManagementApp extends StatelessWidget {
  final VisitorRepository visitorRepository;
  final SharedPreferences sharedPreferences;

  const VisitorManagementApp({
    super.key,
    required this.visitorRepository,
    required this.sharedPreferences,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            sharedPreferences: sharedPreferences,
          )..add(AppStarted()),
        ),
        BlocProvider<VisitorBloc>(
          create: (context) => VisitorBloc(
            repository: visitorRepository,
          )..add(const LoadVisitors()),
        ),
      ],
      child: MaterialApp(
        title: 'Visitor Management',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
