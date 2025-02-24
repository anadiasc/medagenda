import 'package:flutter/material.dart';
import 'package:med_agenda/views/doctor_views/schedule_appointment_view.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/user_model.dart';
import '../../models/appointment_model.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../services/appointment_service.dart';
import '../../viewmodels/appointment_viewmodel.dart';

class DoctorAppointmentsView extends StatefulWidget {
  const DoctorAppointmentsView({Key? key}) : super(key: key);

  @override
  State<DoctorAppointmentsView> createState() => _DoctorAppointmentsViewState();
}

class _DoctorAppointmentsViewState extends State<DoctorAppointmentsView> {
  late Stream<List<AppointmentModel>> _appointmentsStream;

  @override
  void initState() {
    super.initState();
    _initializeStream(); // Inicializa o Stream de consultas ao iniciar a tela
  }

  // Método para inicializar o Stream de consultas do médico
  void _initializeStream() {
    final doctorId = context.read<AuthService>().currentUser?.uid;
    if (doctorId != null) {
      _appointmentsStream = context.read<AppointmentService>().getDoctorAppointments(doctorId);
    }
  }

  // Método para recarregar o Stream de consultas
  void _refreshStream() {
    setState(() {
      _initializeStream();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consultas')), // Título da tela
      body: _buildAppointmentsList(context), // Corpo da tela com a lista de consultas
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navega para a tela de agendamento de nova consulta
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ScheduleAppointmentView(),
            ),
          );
        },
        child: const Icon(Icons.add), // Ícone de adicionar
        tooltip: 'Agendar nova consulta', // Dica de ferramenta
      ),
    );
  }

  // Método para construir a lista de consultas
  Widget _buildAppointmentsList(BuildContext context) {
    final doctorId = context.read<AuthService>().currentUser?.uid;
    if (doctorId == null) {
      return const Center(child: Text('Não autenticado')); // Mensagem de erro se não autenticado
    }

    return StreamBuilder<List<AppointmentModel>>(
      stream: _appointmentsStream, // Stream de consultas
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // Indicador de carregamento
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red), // Ícone de erro
                const SizedBox(height: 16),
                Text(
                  'Erro ao carregar consultas:\n${snapshot.error}', // Mensagem de erro
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshStream, // Botão para tentar recarregar
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          );
        }

        final appointments = snapshot.data ?? [];
        if (appointments.isEmpty) {
          return const Center(
            child: Text(
              'Nenhuma consulta encontrada', // Mensagem se não houver consultas
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime)); // Ordena as consultas por data

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment = appointments[index];
            return FutureBuilder<UserModel?>(
              future: context.read<UserService>().getUserById(appointment.patientId), // Busca o paciente
              builder: (context, userSnapshot) {
                final patientName = userSnapshot.data?.name ?? 'Carregando...'; // Nome do paciente ou "Carregando"
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    title: Text(
                      'Consulta com ${patientName}', // Título da consulta
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(appointment.dateTime), // Data e hora formatadas
                        ),
                        if (appointment.notes != null)
                          Text(
                            'Observações: ${appointment.notes}', // Observações da consulta
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                    /*trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Badge de status da consulta
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: appointment.status == 'completed'
                                ? Colors.green[100]
                                : appointment.status == 'cancelled'
                                    ? Colors.red[100]
                                    : Colors.orange[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            appointment.status == 'completed'
                                ? 'Realizada'
                                : appointment.status == 'cancelled'
                                    ? 'Cancelada'
                                    : 'Pendente',
                            style: TextStyle(
                              color: appointment.status == 'completed'
                                  ? Colors.green[900]
                                  : appointment.status == 'cancelled'
                                      ? Colors.red[900]
                                      : Colors.orange[900],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Botões de ação para consultas pendentes
                        if (appointment.status == 'pending') ...[
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.check_circle_outline),
                            color: Colors.green,
                            onPressed: () {
                              // Marca a consulta como realizada
                              context.read<AppointmentViewModel>().updateAppointment(
                                    appointment.copyWith(status: 'completed'),
                                  );
                            },
                            tooltip: 'Marcar como realizada',
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel_outlined),
                            color: Colors.red,
                            onPressed: () {
                              // Diálogo de confirmação para cancelar a consulta
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Cancelar Consulta'),
                                  content: const Text(
                                    'Tem certeza que deseja cancelar esta consulta?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Não'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        context
                                            .read<AppointmentViewModel>()
                                            .cancelAppointment(appointment.id); // Cancela a consulta
                                      },
                                      child: const Text('Sim'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            tooltip: 'Cancelar consulta',
                          ),
                        ],
                      ],
                    ),*/
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}