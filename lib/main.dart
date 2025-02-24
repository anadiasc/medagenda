import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart'; // Para verificar se está em modo de desenvolvimento
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/appointment_service.dart';
import 'services/user_service.dart';
import 'viewmodels/appointment_viewmodel.dart';
import 'views/splash/splash_view.dart';
import 'views/home/home_view.dart';
import 'views/login/login_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyB53o9J4asxis--oQwIvsYGatgf_f8-AcQ",
      authDomain: "medagenda-b9371.firebaseapp.com",
      projectId: "medagenda-b9371",
      storageBucket: "medagenda-b9371.firebasestorage.app",
      messagingSenderId: "583635801702",
      appId: "1:583635801702:web:470ab8a901bb6acb54bfa7",
    ),
  );

  final authService = AuthService();
  final userService = UserService();
  final appointmentService = AppointmentService();

  runApp(
    DevicePreview(
      enabled: !kReleaseMode, // Ativa apenas em modo de desenvolvimento
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>.value(value: authService),
          //ChangeNotifierProvider<UserService>.value(value: userService),
          ChangeNotifierProvider(create: (_) => UserService()),
          ChangeNotifierProvider<AppointmentService>.value(value: appointmentService),
          ChangeNotifierProxyProvider<AppointmentService, AppointmentViewModel>(
            create: (context) => AppointmentViewModel(appointmentService),
            update: (context, appointmentService, previous) => AppointmentViewModel(appointmentService),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Med Agenda',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      builder: DevicePreview.appBuilder, // Integração com DevicePreview
      locale: DevicePreview.locale(context), // Define a localização
      home: FutureBuilder(
        future: Future.delayed(const Duration(seconds: 2)),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SplashView();
          }
          return StreamBuilder(
            stream: context.read<AuthService>().authStateChanges,
            builder: (context, authSnapshot) {
              if (authSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (authSnapshot.hasData) {
                return const HomeView();
              }
              return const LoginView();
            },
          );
        },
      ),
    );
  }
}

