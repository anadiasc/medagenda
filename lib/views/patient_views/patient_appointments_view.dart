import 'package:flutter/material.dart'; 
import 'package:provider/provider.dart'; // Importando o Provider para gerenciamento de estado
import 'package:intl/intl.dart'; // Para formatar datas e horas
import '../../services/auth_service.dart'; // Serviço de autenticação
import '../../services/user_service.dart'; // Serviço para obter informações sobre o usuário
import '../../models/appointment_model.dart'; // Modelo para consulta
import '../../models/user_model.dart'; // Modelo para usuário
import '../../viewmodels/appointment_viewmodel.dart'; // ViewModel para manipular consultas

// Classe que exibe a lista de consultas do paciente
class PatientAppointmentsView extends StatelessWidget {
  const PatientAppointmentsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Obtendo o ID do usuário autenticado
    final userId = context.read<AuthService>().currentUser?.uid;
    
    // Se o ID do usuário for nulo, exibe uma mensagem de erro
    if (userId == null) {
      return const Center(child: Text('Erro ao carregar consultas.'));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Consultas')), // AppBar com o título "Minhas Consultas"
      body: StreamBuilder<List<AppointmentModel>>(
        // O StreamBuilder escuta as consultas do paciente em tempo real
        stream: context.read<AppointmentViewModel>().getPatientAppointments(userId),
        builder: (context, snapshot) {
          // Exibindo um indicador de carregamento enquanto os dados não estão prontos
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Se não houver dados ou se a lista estiver vazia, exibe uma mensagem
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma consulta agendada.'));
          }

          final appointments = snapshot.data!; // Obtemos as consultas
          final appointment = appointments.first; // Pegando a primeira consulta para mostrar inicialmente

          return ListView.builder(
            // Exibindo as consultas em uma lista
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index]; // Consulta específica
              return Card(
                margin: const EdgeInsets.all(8.0), // Definindo a margem entre os itens
                child: ListTile(
                  title: FutureBuilder<UserModel?>(
                    // Carregando o nome do médico da consulta usando o ID do médico
                    future: context.read<UserService>().getUserById(appointment.doctorId),
                    builder: (context, snapshot) {
                      // Enquanto os dados do médico estão sendo carregados, exibe "Carregando..."
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text('Carregando...');
                      }
                      // Se não encontrou dados sobre o médico, exibe "Médico não encontrado"
                      if (!snapshot.hasData || snapshot.data == null) {
                        return const Text('Médico não encontrado');
                      }
                      // Exibe o nome do médico (Dr. nome do médico)
                      return Text('Consulta com Dr. ${snapshot.data!.name}');
                    },
                  ),
                  subtitle: Text(
                    // Exibe a data e hora da consulta no formato "dd/MM/yyyy HH:mm"
                    DateFormat('dd/MM/yyyy HH:mm').format(appointment.dateTime)
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red), // Ícone para cancelar a consulta
                    onPressed: () {
                      // Ação ao pressionar o ícone: cancela a consulta
                      context.read<AppointmentViewModel>().cancelAppointment(appointment.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Consulta cancelada.')), // Exibe um Snackbar após o cancelamento
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
