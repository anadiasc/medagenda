import 'package:flutter/material.dart'; // Importa a biblioteca de widgets do Flutter
import 'package:med_agenda/models/user_model.dart'; // Importa o modelo de dados de usuário
import 'package:provider/provider.dart'; // Importa a biblioteca provider para gerenciamento de estado
import 'package:intl/intl.dart'; // Importa para formatação de datas
import 'package:med_agenda/models/appointment_model.dart'; // Importa o modelo de dados da consulta
import 'package:med_agenda/services/auth_service.dart'; // Importa o serviço de autenticação
import 'package:med_agenda/services/appointment_service.dart'; // Importa o serviço de agendamento de consulta
import 'package:med_agenda/services/user_service.dart'; // Importa o serviço de usuário

// Tela de agendamento de consulta
class ScheduleAppointmentView extends StatefulWidget {
  const ScheduleAppointmentView({Key? key}) : super(key: key);

  @override
  _ScheduleAppointmentViewState createState() => _ScheduleAppointmentViewState();
}

class _ScheduleAppointmentViewState extends State<ScheduleAppointmentView> {
  final _formKey = GlobalKey<FormState>(); // Chave para o formulário
  UserModel? _selectedPatient; // Paciente selecionado para a consulta
  DateTime? _selectedDate; // Data selecionada para o agendamento
  TimeOfDay? _selectedTime; // Hora selecionada para o agendamento
  final TextEditingController _notesController = TextEditingController(); // Controlador para as observações

  // Função para agendar a consulta
  void _scheduleAppointment() async {
    // Verifica se todos os campos necessários foram preenchidos
    if (_selectedPatient == null || _selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos.')),
      );
      return;
    }

    // Verifica se o médico está autenticado
    final doctorId = context.read<AuthService>().currentUser?.uid;
    if (doctorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro: Médico não autenticado.')),
      );
      return;
    }

    // Tenta criar a consulta com os dados fornecidos
    try {
      final appointment = AppointmentModel(
        doctorId: doctorId, // ID do médico autenticado
        patientId: _selectedPatient!.id, // ID do paciente selecionado
        dateTime: DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        ), // Data e hora combinadas
        status: 'pending', // Status inicial da consulta
        notes: _notesController.text, // Observações inseridas
        id: '', // ID vazio que será preenchido no banco
      );

      // Cria a consulta no banco de dados
      await context.read<AppointmentService>().createAppointment(appointment);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Consulta agendada com sucesso!')),
      );

      Navigator.pop(context); // Fecha a tela após o agendamento
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao agendar consulta: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Agendar Consulta'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título para seleção do paciente
              const Text(
                'Selecionar Paciente',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              // StreamBuilder que obtém a lista de pacientes
              StreamBuilder<List<UserModel>>(
                stream: context.read<UserService>().getPatients(),
                builder: (context, snapshot) {
                  // Exibe indicador de carregamento enquanto espera os dados
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Se não houver pacientes, exibe uma mensagem
                  final patients = snapshot.data ?? [];
                  if (patients.isEmpty) {
                    return const Text(
                      'Nenhum paciente disponível.',
                      style: TextStyle(color: Colors.black54),
                    );
                  }

                  // Dropdown para selecionar o paciente
                  return DropdownButtonFormField<UserModel>(
                    value: patients.contains(_selectedPatient) ? _selectedPatient : null,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Paciente',
                      labelStyle: TextStyle(color: Colors.black54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: patients.map((patient) {
                      return DropdownMenuItem<UserModel>(
                        value: patient,
                        child: Text(
                          patient.name,
                          style: const TextStyle(color: Colors.black87),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPatient = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Por favor, selecione um paciente';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              
              // Título para selecionar data e horário
              const Text(
                'Selecionar Data e Horário',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              // Botões para selecionar data e hora
              Row(
                children: [
                  // Botão para selecionar a data
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 90)),
                        );
                        if (date != null) {
                          setState(() {
                            _selectedDate = date;
                          });
                        }
                      },
                      icon: const Icon(Icons.calendar_today, color: Colors.blue),
                      label: Text(
                        _selectedDate == null
                            ? 'Selecionar Data'
                            : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                        style: const TextStyle(color: Colors.blue),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Botão para selecionar a hora
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() {
                            _selectedTime = time;
                          });
                        }
                      },
                      icon: const Icon(Icons.access_time, color: Colors.blue),
                      label: Text(
                        _selectedTime == null
                            ? 'Selecionar Horário'
                            : _selectedTime!.format(context),
                        style: const TextStyle(color: Colors.blue),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Título para observações
              const Text(
                'Observações',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              // Campo de texto para inserir observações
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Observações',
                  labelStyle: TextStyle(color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 3,
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 32),
              
              // Botão para agendar a consulta
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _scheduleAppointment,
                  child: const Text(
                    'Agendar Consulta',
                    style: TextStyle(fontSize: 16, color: Color(0xFFFFFFFF)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
