import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart'; // Serviço de autenticação
import '../../services/user_service.dart'; // Serviço para acessar dados do usuário
import '../../models/user_model.dart'; // Modelo de dados do usuário
import '../doctor_views/doctor_dashboard.dart'; // Tela do dashboard para médicos
import '../patient_views/patient_dashboard.dart'; // Tela do dashboard para pacientes
import '../login/login_view.dart'; // Tela de login

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Obtém os serviços de autenticação e de usuário usando o Provider
    final authService = context.watch<AuthService>(); 
    final userService = context.read<UserService>();

    return StreamBuilder<User?>(
      // Escuta as mudanças no estado de autenticação do Firebase
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Exibe um indicador de progresso enquanto a autenticação está carregando
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.blue, // Cor do indicador de progresso
              ),
            ),
          );
        }

        final user = snapshot.data; // Usuário retornado após a autenticação
        if (user == null) {
          // Se não há usuário autenticado, redireciona para a tela de login
          return const LoginView();
        }

        // Carrega os dados do usuário com base no ID
        return FutureBuilder<UserModel?>(
          future: userService.getUserById(user.uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              // Exibe um indicador de progresso enquanto os dados do usuário estão carregando
              return const Scaffold(
                backgroundColor: Colors.white,
                body: Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue, // Cor do indicador de progresso
                  ),
                ),
              );
            }

            final userModel = userSnapshot.data; // Dados do usuário
            if (userModel == null) {
              // Se não houver dados do usuário, redireciona para a tela de login
              return const LoginView();
            }

            return Scaffold(
              backgroundColor: Colors.white,
              body: Column(
                children: [
                  // Cabeçalho personalizado com informações do usuário
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.blue, // Cor de fundo do cabeçalho
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.medical_services_outlined,
                          size: 40,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        // Exibe o nome do usuário autenticado
                        Text(
                          'Bem-vindo, ${userModel.name}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        // Ícone de logout que desconecta o usuário
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.white),
                          onPressed: () async {
                            await authService.signOut(); // Realiza o logout
                            if (context.mounted) {
                              // Redireciona para a tela de login após o logout
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginView()),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Conteúdo principal: exibe diferentes dashboards dependendo do tipo de usuário
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: userModel.userType == UserType.doctor
                          ? const DoctorDashboard() // Tela do médico
                          : const PatientDashboard(), // Tela do paciente
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
