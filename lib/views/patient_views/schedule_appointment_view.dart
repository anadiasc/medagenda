import 'dart:async';

import 'package:flutter/material.dart';
import 'package:med_agenda/services/auth_service.dart';
import 'package:med_agenda/views/home/home_view.dart';
import 'package:med_agenda/views/patient_views/patient_dashboard.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';
import '../../services/appointment_service.dart';
import '../../models/appointment_model.dart';

class ScheduleAppointmentView extends StatefulWidget {
  const ScheduleAppointmentView({Key? key}) : super(key: key);

  @override
  State<ScheduleAppointmentView> createState() => _ScheduleAppointmentViewState();
}

class _ScheduleAppointmentViewState extends State<ScheduleAppointmentView> {
  UserModel? _selectedDoctor;
  DateTime? _selectedDate;
  DateTime? _selectedTime;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  List<DateTime> _availableTimeSlots = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Agendar Nova Consulta',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              // StreamBuilder para carregar a lista de médicos a partir do serviço UserService
              StreamBuilder<List<UserModel>>(
                stream: context.read<UserService>().getDoctors(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  final doctors = snapshot.data ?? [];
                  if (doctors.isEmpty) {
                    return const Text('Nenhum médico disponível no momento.');
                  }

                  return DropdownButtonFormField<UserModel>(
                    value: doctors.contains(_selectedDoctor) ? _selectedDoctor : null,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Selecione o Médico',
                      border: OutlineInputBorder(),
                    ),
                    items: doctors.map((doctor) {
                      return DropdownMenuItem<UserModel>(
                        value: doctor,
                        child: Text('Dr. ${doctor.name}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDoctor = value;
                        _selectedTime = null;
                        _availableTimeSlots = [];
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Por favor, selecione um médico';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
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
                      _selectedTime = null;
                      // Atualiza os horários disponíveis quando a data é selecionada
                      _loadAvailableTimeSlots();
                    });
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(_selectedDate == null
                    ? 'Selecionar Data'
                    : DateFormat('dd/MM/yyyy').format(_selectedDate!)),
              ),
              const SizedBox(height: 32),
              // Exibe os horários disponíveis se o médico e a data forem selecionados
              if (_selectedDoctor != null && _selectedDate != null) ...[
                const Text(
                  'Horários Disponíveis',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildTimeSlots(),
              ],
              const SizedBox(height: 32),
              if (_selectedTime != null) ...[
                ElevatedButton(
                  onPressed: _scheduleAppointment,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text('Confirmar Agendamento'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Método para carregar os horários disponíveis
  void _loadAvailableTimeSlots() async {
    if (_selectedDoctor == null || _selectedDate == null) return;

    setState(() {
      _isLoading = true;
      _availableTimeSlots = [];
    });

    try {
      // Obtém as consultas do médico para a data selecionada
      final appointments = await context
          .read<AppointmentService>()
          .getDoctorAvailability(_selectedDoctor!.id, _selectedDate!);

      // Gera os horários de consulta (das 8h às 18h, de hora em hora)
      final allTimeSlots = List.generate(11, (index) {
        final hour = index + 8; // Começa às 8h
        return DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          hour,
        );
      });

      // Filtra os horários ocupados
      final occupiedTimeSlots = appointments
          .where((appointment) => appointment.status != 'cancelled')
          .map((appointment) => DateTime(
                appointment.dateTime.year,
                appointment.dateTime.month,
                appointment.dateTime.day,
                appointment.dateTime.hour,
              ))
          .toList();

      // Determina os horários disponíveis
      _availableTimeSlots = allTimeSlots.where((timeSlot) {
        return !occupiedTimeSlots.any((occupiedSlot) =>
            occupiedSlot.hour == timeSlot.hour);
      }).toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar horários disponíveis: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar horários: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Método para construir a grid de horários disponíveis
  Widget _buildTimeSlots() {
    if (_availableTimeSlots.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Não há horários disponíveis para esta data. Por favor, selecione outra data.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.0,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _availableTimeSlots.length,
      itemBuilder: (context, index) {
        final timeSlot = _availableTimeSlots[index];
        final isSelected = _selectedTime != null &&
            _selectedTime!.hour == timeSlot.hour &&
            _selectedTime!.day == timeSlot.day &&
            _selectedTime!.month == timeSlot.month &&
            _selectedTime!.year == timeSlot.year;

        return InkWell(
          onTap: () {
            setState(() {
              _selectedTime = timeSlot;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).primaryColor,
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              DateFormat('HH:00').format(timeSlot),
              style: TextStyle(
                color: isSelected ? Colors.white : Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  // Método para agendar a consulta
  void _scheduleAppointment() async {
    if (_formKey.currentState!.validate() && _selectedTime != null) {
      try {
        // Define loading state
        setState(() {
          _isLoading = true;
        });

        // Cria um objeto AppointmentModel com os dados da consulta
        final currentUser = context.read<AuthService>().currentUser;
        
        if (currentUser == null) {
          throw Exception('Usuário não autenticado');
        }
        
        // Cria o modelo de agendamento com todos os campos necessários
        final appointment = AppointmentModel(
          id: '', // O ID será gerado pelo Firestore
          doctorId: _selectedDoctor!.id,
          patientId: currentUser.uid,
          dateTime: _selectedTime!,
          status: 'scheduled',
          notes: '',
          //createdAt: DateTime.now(),
        );

        // Verifica se o horário ainda está disponível antes de agendar
        final existingAppointments = await context
            .read<AppointmentService>()
            .getDoctorAvailability(_selectedDoctor!.id, _selectedDate!);
            
        final isSlotTaken = existingAppointments.any((existing) =>
            existing.dateTime.hour == _selectedTime!.hour &&
            existing.status != 'cancelled');
            
        if (isSlotTaken) {
          throw Exception('Este horário já não está mais disponível. Por favor, escolha outro horário.');
        }

        // Chama o serviço para criar a consulta com tratamento de timeouts
        await context.read<AppointmentService>()
            .createAppointment(appointment)
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () => throw TimeoutException('Tempo esgotado ao tentar agendar. Verifique sua conexão.'),
            );

        // Se chegou aqui, o agendamento foi bem-sucedido
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          // Mostra mensagem de sucesso
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Consulta agendada com sucesso!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          
          // Usa navegação de substituição para ir direto para a tela de consultas do paciente
          // Isso evita problemas com a pilha de navegação
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              // Substitui a tela atual pela tela de consultas do paciente
              // Isso remove a tela de agendamento da pilha de navegação
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => HomeView(),
                ),
              );
            }
          });
        }
      } catch (e) {
        // Trata o erro e desativa o loading
        print('Erro no agendamento: $e');
        
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          // Mostra mensagem de erro
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao agendar consulta: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } else {
      // Formulário inválido ou horário não selecionado
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos e selecione um horário'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}