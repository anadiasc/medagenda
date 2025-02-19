import 'package:flutter/material.dart';

// Card que exibe informações estatísticas, com ícone, título e valor
class StatisticCard extends StatelessWidget {
  // Definição dos parâmetros que a classe irá receber
  final String title;   // Título do cartão, ex: "Consultas Agendadas"
  final String value;   // Valor a ser exibido, ex: "10"
  final IconData icon;  // Ícone representativo, ex: ícone de calendário
  final Color? color;   // Cor do ícone e do valor, opcional

  // Construtor que recebe os parâmetros obrigatórios e o opcional
  const StatisticCard({
    required this.title,
    required this.value,
    required this.icon,
    this.color,  // Cor opcional
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // Estilo do cartão, com padding de 16 pixels em todos os lados
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // O tamanho da coluna é o mínimo necessário para caber os widgets
          mainAxisSize: MainAxisSize.min,
          children: [
            // Exibe o ícone com o tamanho de 32 e a cor opcional
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8), // Espaço entre o ícone e o título
            // Exibe o título do cartão com estilo de texto em negrito
            Text(
              title,
              style: const TextStyle(
                fontSize: 16, // Tamanho da fonte do título
                fontWeight: FontWeight.bold, // Título em negrito
              ),
            ),
            const SizedBox(height: 4), // Espaço entre o título e o valor
            // Exibe o valor com a cor opcional e estilo em negrito
            Text(
              value,
              style: TextStyle(
                fontSize: 24, // Tamanho maior para o valor
                fontWeight: FontWeight.bold, // Valor em negrito
                color: color, // Cor do valor, se fornecida
              ),
            ),
          ],
        ),
      ),
    );
  }
}
