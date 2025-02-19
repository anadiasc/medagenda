import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../home/home_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>(); // Chave para o formulário
  final _emailController = TextEditingController(); // Controlador para o campo de email
  final _passwordController = TextEditingController(); // Controlador para o campo de senha
  final _nameController = TextEditingController(); // Controlador para o campo de nome
  bool _isRegistering = false; // Indica se o usuário está no modo de registro ou login
  UserType _selectedUserType = UserType.patient; // Tipo de usuário selecionado (paciente ou médico)

  @override
  void dispose() {
    // Limpa os controladores quando o widget for descartado
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1A237E), // Azul escuro
              const Color(0xFF3949AB), // Azul médio
              const Color(0xFF42A5F5), // Azul claro
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícone do serviço médico
                Icon(
                  Icons.medical_services_outlined,
                  size: 80,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(height: 24),
                // Título, muda entre 'Login' e 'Criar Conta' dependendo do estado
                Text(
                  _isRegistering ? 'Criar Conta' : 'Login',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                // Formulário de login/registro
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (_isRegistering) ...[
                        // Campo para nome, visível apenas no modo de registro
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Nome',
                            labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.8)),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Por favor, insira seu nome';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        // Dropdown para escolher o tipo de usuário (Médico ou Paciente)
                        DropdownButtonFormField<UserType>(
                          value: _selectedUserType,
                          decoration: InputDecoration(
                            labelText: 'Tipo de Usuário',
                            labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                          ),
                          dropdownColor: const Color(0xFF1A237E),
                          style: const TextStyle(color: Colors.white),
                          items: UserType.values.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type == UserType.doctor ? 'Médico' : 'Paciente'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedUserType = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                      ],
                      // Campo de email
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.8)),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Por favor, insira seu email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      // Campo de senha
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.8)),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        obscureText: true, // Torna a senha invisível
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Por favor, insira sua senha';
                          }
                          if (_isRegistering && (value?.length ?? 0) < 6) {
                            return 'A senha deve ter pelo menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Botão de login ou registro
                      ElevatedButton(
                        onPressed: _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          _isRegistering ? 'Registrar' : 'Entrar',
                          style: const TextStyle(
                            color: Color(0xFF1A237E),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Botão para alternar entre o modo de login e registro
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isRegistering = !_isRegistering;
                          });
                        },
                        child: Text(
                          _isRegistering
                              ? 'Já tem uma conta? Entre'
                              : 'Não tem uma conta? Registre-se',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Botão para login com Google
                      OutlinedButton.icon(
                        onPressed: _handleGoogleSignIn,
                        icon: const Icon(Icons.account_circle, color: Colors.white),
                        label: const Text(
                          'Continuar com Google',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withOpacity(0.8)),
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Função para enviar os dados de login ou registro
  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authService = context.read<AuthService>();
      UserModel? user;

      try {
        if (_isRegistering) {
          // Registro de novo usuário
          user = await authService.registerWithEmailPassword(
            _emailController.text,
            _passwordController.text,
            _nameController.text,
            _selectedUserType,
          );
        } else {
          // Login de usuário existente
          user = await authService.signInWithEmailPassword(
            _emailController.text,
            _passwordController.text,
          );
        }

        if (!mounted) return;

        // Se o usuário for autenticado, redireciona para a Home
        if (user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeView()),
          );
        } else {
          // Caso contrário, exibe mensagem de erro
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao autenticar. Tente novamente.')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.toString()}')),
        );
      }
    }
  }

  // Função para login com Google
  Future<void> _handleGoogleSignIn() async {
    final authService = context.read<AuthService>();
    try {
      final user = await authService.signInWithGoogle();
      
      if (!mounted) return;
      
      // Se o login for bem-sucedido, redireciona para a Home
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeView()),
        );
      } else {
        // Caso contrário, exibe mensagem de erro
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao autenticar com Google. Tente novamente.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${e.toString()}')),
      );
    }
  }
}
