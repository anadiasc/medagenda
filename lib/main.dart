import 'package:flutter/material.dart'; // Importa o pacote Flutter para criar a interface de usuário
import 'package:firebase_core/firebase_core.dart'; // Importa o Firebase para inicializar o aplicativo com Firebase
import 'package:provider/provider.dart'; // Importa o pacote provider para gerenciar o estado
import 'services/auth_service.dart'; // Serviço para autenticação de usuários
import 'services/appointment_service.dart'; // Serviço para agendamentos
import 'services/user_service.dart'; // Serviço para gerenciamento de usuários
import 'viewmodels/appointment_viewmodel.dart'; // ViewModel para agendamentos
import 'views/splash/splash_view.dart'; // Tela de splash
import 'views/home/home_view.dart'; // Tela principal do aplicativo
import 'views/login/login_view.dart'; // Tela de login

void main() async {
  // Garante que o framework Flutter foi inicializado antes de chamar Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase com as credenciais do projeto
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyB53o9J4asxis--oQwIvsYGatgf_f8-AcQ", // Chave API do Firebase
      authDomain: "medagenda-b9371.firebaseapp.com", // Domínio de autenticação
      projectId: "medagenda-b9371", // ID do projeto Firebase
      storageBucket: "medagenda-b9371.firebasestorage.app", // Bucket de armazenamento
      messagingSenderId: "583635801702", // ID do remetente de mensagens
      appId: "1:583635801702:web:470ab8a901bb6acb54bfa7", // ID do app
    ),
  );

  // Inicializa os serviços necessários para o aplicativo
  final authService = AuthService(); // Serviço de autenticação
  final userService = UserService(); // Serviço de usuários
  final appointmentService = AppointmentService(); // Serviço de agendamentos

  // Inicializa o app com múltiplos providers para gerenciar o estado
  runApp(
    MultiProvider(
      providers: [
        // Provedor para o serviço de autenticação
        ChangeNotifierProvider<AuthService>.value(value: authService),
        
        // Provedor para o serviço de usuários
        ChangeNotifierProvider<UserService>.value(value: userService),
        
        // Provedor para o serviço de agendamentos
        ChangeNotifierProvider<AppointmentService>.value(value: appointmentService),
        
        // Provedor para o ViewModel de agendamentos, que depende do serviço de agendamentos
        ChangeNotifierProxyProvider<AppointmentService, AppointmentViewModel>(
          create: (context) => AppointmentViewModel(appointmentService),
          update: (context, appointmentService, previous) =>
              AppointmentViewModel(appointmentService),
        ),
      ],
      child: const MyApp(), // Executa o aplicativo com os providers configurados
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Med Agenda', // Define o título do aplicativo
      debugShowCheckedModeBanner: false, // Desabilita o banner de depuração no canto superior direito
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E), // Cor principal do aplicativo
          brightness: Brightness.light, // Define o tema claro
        ),
        useMaterial3: true, // Habilita o Material Design 3
      ),
      home: FutureBuilder(
        // Atraso de 2 segundos para exibir a tela de splash
        future: Future.delayed(const Duration(seconds: 2)),
        builder: (context, snapshot) {
          // Exibe a tela de splash enquanto o futuro não é completado
          if (snapshot.connectionState != ConnectionState.done) {
            return const SplashView();
          }

          // Após a tela de splash, verifica o estado de autenticação
          return StreamBuilder(
            stream: context.read<AuthService>().authStateChanges, // Observa mudanças no estado de autenticação
            builder: (context, authSnapshot) {
              // Exibe um indicador de progresso enquanto aguarda a autenticação
              if (authSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(), // Exibe o indicador de carregamento
                  ),
                );
              }

              // Se o usuário estiver autenticado, exibe a tela principal
              if (authSnapshot.hasData) {
                return const HomeView();
              }

              // Se não estiver autenticado, exibe a tela de login
              return const LoginView();
            },
          );
        },
      ),
    );
  }
}
