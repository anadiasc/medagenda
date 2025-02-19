import 'package:flutter/material.dart'; // Importa o pacote Flutter para UI
import 'package:provider/provider.dart'; // Importa o Provider para gerenciar o estado
import 'package:intl/intl.dart'; // Importa o pacote Intl para formatação de data
import '../../services/user_service.dart'; // Importa o serviço de usuário, responsável por obter dados de médicos
import '../../models/user_model.dart'; // Importa o modelo de dados do usuário (médico)

class ScheduleAppointmentView extends StatefulWidget {
  const ScheduleAppointmentView({Key? key}) : super(key: key);

  @override
  State<ScheduleAppointmentView> createState() => _ScheduleAppointmentViewState();
}

class _ScheduleAppointmentViewState extends State<ScheduleAppointmentView> {
  UserModel? _selectedDoctor; // Variável para armazenar o médico selecionado
  DateTime? _selectedDate; // Variável para armazenar a data da consulta
  DateTime? _selectedTime; // Variável para armazenar a hora da consulta
  final _formKey = GlobalKey<FormState>(); // Chave global para o formulário

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0), // Adiciona espaçamento ao redor do conteúdo
        child: Form(
          key: _formKey, // Associa a chave do formulário para validação
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Agendar Nova Consulta', // Título da tela
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              // StreamBuilder para carregar a lista de médicos a partir do serviço UserService
              StreamBuilder<List<UserModel>>(
                stream: context.read<UserService>().getDoctors(),
                builder: (context, snapshot) {
                  // Enquanto o Stream estiver esperando, exibe o indicador de carregamento
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  final doctors = snapshot.data ?? []; // Caso não haja dados, exibe uma lista vazia
                  if (doctors.isEmpty) {
                    return const Text('Nenhum médico disponível no momento.'); // Mensagem caso não haja médicos
                  }

                  // Dropdown para selecionar o médico
                  return DropdownButtonFormField<UserModel>(
                    value: doctors.contains(_selectedDoctor) ? _selectedDoctor : null, // Verifica o médico selecionado
                    isExpanded: true, // Expande o campo para preencher a largura
                    decoration: const InputDecoration(
                      labelText: 'Selecione o Médico', // Rótulo do campo
                      border: OutlineInputBorder(), // Borda do campo
                    ),
                    items: doctors.map((doctor) { // Mapeia os médicos para itens do Dropdown
                      return DropdownMenuItem<UserModel>(
                        value: doctor,
                        child: Text('Dr. ${doctor.name}'), // Nome do médico
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDoctor = value; // Atualiza o médico selecionado
                        _selectedTime = null; // Reseta a hora da consulta
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Por favor, selecione um médico'; // Validação do campo médico
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              // Botão para selecionar a data da consulta
              ElevatedButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(), // Data inicial é a data atual
                    firstDate: DateTime.now(), // Primeira data disponível é a data atual
                    lastDate: DateTime.now().add(const Duration(days: 90)), // Última data disponível é 90 dias à frente
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date; // Atualiza a data selecionada
                      _selectedTime = null; // Reseta a hora da consulta
                    });
                  }
                },
                icon: const Icon(Icons.calendar_today), // Ícone do calendário
                label: Text(_selectedDate == null
                    ? 'Selecionar Data' // Texto do botão caso a data não tenha sido selecionada
                    : DateFormat('dd/MM/yyyy').format(_selectedDate!)), // Formatação da data caso selecionada
              ),
              const SizedBox(height: 32),
              // Exibe os horários disponíveis se o médico e a data forem selecionados
              if (_selectedDoctor != null && _selectedDate != null) ...[
                const Text(
                  'Horários Disponíveis', // Título para os horários disponíveis
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
