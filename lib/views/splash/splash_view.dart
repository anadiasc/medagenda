import 'package:flutter/material.dart'; // Importa o pacote Flutter para a criação da interface
import 'package:google_fonts/google_fonts.dart'; // Importa o pacote Google Fonts para usar fontes personalizadas
import '../home/home_view.dart'; // Importa a tela principal do aplicativo

class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
  // Controlador de animação e animações de fade e slide
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Inicializa o controlador de animação com duração de 2 segundos
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this, // A animação será sincronizada com o ciclo de vida do widget
    );

    // Animação de fade (transição de opacidade de 0 a 1)
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn, // Define a curva de animação
    ));

    // Animação de slide (movimento de baixo para cima)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5), // Inicia abaixo da tela
      end: Offset.zero, // Move para a posição inicial
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut, // Define a curva de animação para um movimento suave
    ));

    // Inicia a animação
    _controller.forward();

    // Após 3 segundos, navega para a tela inicial (HomeView)
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const HomeView(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child); // Transição de fade ao trocar de tela
            },
            transitionDuration: const Duration(milliseconds: 800), // Duração da transição
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Desfaz o controlador quando o widget é destruído
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Gradiente de fundo da tela de Splash
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, // Começa do topo
            end: Alignment.bottomCenter, // Termina no fundo
            colors: [
              const Color(0xFF1A237E), // Azul escuro
              const Color(0xFF3949AB), // Azul médio
              const Color(0xFF42A5F5), // Azul claro
            ],
          ),
        ),
        child: Center(
          // Centraliza o conteúdo da tela
          child: FadeTransition(
            opacity: _fadeAnimation, // Aplica a animação de fade
            child: SlideTransition(
              position: _slideAnimation, // Aplica a animação de slide
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Centraliza os elementos na tela
                children: [
                  Icon(
                    Icons.medical_services_outlined, // Ícone de serviços médicos
                    size: 80,
                    color: Colors.white.withOpacity(0.9), // Cor branca com opacidade
                  ),
                  const SizedBox(height: 24), // Espaçamento entre o ícone e o texto
                  Text(
                    'MedAgenda', // Nome do aplicativo
                    style: GoogleFonts.montserrat(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5, // Espaçamento entre as letras
                    ),
                  ),
                  const SizedBox(height: 16), // Espaçamento entre os textos
                  Text(
                    'Cuidando da sua saúde\ncom eficiência', // Subtítulo do aplicativo
                    textAlign: TextAlign.center, // Centraliza o texto
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.8),
                      height: 1.5, // Altura da linha
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
