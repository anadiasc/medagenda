import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// Widget que exibe um gráfico de barras para mostrar a disponibilidade de horários
class TimeSlotChart extends StatelessWidget {
  // Recebe um mapa de horários (chaves são as horas e os valores são a quantidade de slots disponíveis)
  final Map<dynamic, dynamic> timeSlots;

  const TimeSlotChart({required this.timeSlots});

  @override
  Widget build(BuildContext context) {
    // Lista para armazenar os grupos de barras que serão exibidos no gráfico
    final List<BarChartGroupData> barGroups = [];

    // Ordena as horas em ordem crescente
    final sortedHours = timeSlots.keys.map((e) => int.parse(e.toString())).toList()..sort();

    // Para cada hora, cria um grupo de barras (BarChartGroupData)
    for (var i = 0; i < sortedHours.length; i++) {
      final hour = sortedHours[i];
      barGroups.add(
        BarChartGroupData(
          x: hour, // A hora em que o slot está disponível
          barRods: [
            BarChartRodData(
              toY: timeSlots[hour].toDouble(), // A altura da barra representa a quantidade de slots
              color: Colors.blue, // Cor da barra
              width: 16, // Largura da barra
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)), // Borda arredondada no topo
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround, // Alinha as barras de maneira espaçada
        maxY: timeSlots.values.fold<num>(0, (p, c) => p > c ? p : c).toDouble() + 1, // Define o valor máximo do eixo Y (1 a mais que o maior valor de slots)
        titlesData: FlTitlesData(
          show: true, // Exibe os títulos do gráfico
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true, // Exibe os títulos do eixo X
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('${value.toInt()}h'), // Exibe a hora com "h" após o número
                );
              },
              reservedSize: 30, // Espaço reservado para os títulos do eixo X
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true, // Exibe os títulos do eixo Y
              getTitlesWidget: (value, meta) {
                return Text(value.toInt().toString()); // Exibe o valor no eixo Y
              },
              reservedSize: 30, // Espaço reservado para os títulos do eixo Y
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false), // Não exibe títulos no topo
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false), // Não exibe títulos no lado direito
          ),
        ),
        borderData: FlBorderData(
          show: true, // Exibe a borda ao redor do gráfico
          border: Border.all(color: const Color(0xff37434d), width: 1), // Definição da cor e espessura da borda
        ),
        barGroups: barGroups, // Grupos de barras que foram criados
        gridData: const FlGridData(show: false), // Não exibe a grade no gráfico
      ),
    );
  }
}
