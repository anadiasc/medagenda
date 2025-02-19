import 'package:flutter/material.dart';
import 'package:med_agenda/views/doctor_views/statistic_card.dart';
import 'package:med_agenda/views/doctor_views/time_slot_chart.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../viewmodels/appointment_viewmodel.dart';

class DoctorStatisticsView extends StatefulWidget {
  const DoctorStatisticsView({Key? key}) : super(key: key);

  @override
  State<DoctorStatisticsView> createState() => _DoctorStatisticsViewState();
}

class _DoctorStatisticsViewState extends State<DoctorStatisticsView> {
  @override
  void initState() {
    super.initState();
    // Carrega as estatísticas do médico após a construção do widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final doctorId = context.read<AuthService>().currentUser?.uid;
      if (doctorId != null) {
        context.read<AppointmentViewModel>().loadDoctorStatistics(doctorId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Obtém as estatísticas do médico a partir do ViewModel
    final statistics = context.watch<AppointmentViewModel>().statistics;

    // Exibe um indicador de carregamento enquanto as estatísticas são carregadas
    if (statistics == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título da seção de estatísticas
          const Text(
            'Estatísticas do Mês',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Lista horizontal de cartões de estatísticas
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Cartão de estatística: Total de consultas
                StatisticCard(
                  title: 'Total de Consultas',
                  value: statistics['totalAppointments'].toString(),
                  icon: Icons.calendar_month,
                ),
                const SizedBox(width: 16),

                // Cartão de estatística: Consultas realizadas
                StatisticCard(
                  title: 'Consultas Realizadas',
                  value: statistics['completedAppointments'].toString(),
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
                const SizedBox(width: 16),

                // Cartão de estatística: Consultas canceladas
                StatisticCard(
                  title: 'Consultas Canceladas',
                  value: statistics['cancelledAppointments'].toString(),
                  icon: Icons.cancel,
                  color: Colors.red,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Título da seção de horários populares
          const Text(
            'Horários Mais Populares',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Gráfico de horários populares
          SizedBox(
            height: 300,
            child: TimeSlotChart(timeSlots: statistics['popularTimeSlots'] ?? {}),
          ),
        ],
      ),
    );
  }
}