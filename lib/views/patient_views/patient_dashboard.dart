import 'package:flutter/material.dart'; 
import 'package:med_agenda/views/patient_views/patient_appointments_view.dart'; // Importa a tela de consultas do paciente
import 'package:med_agenda/views/doctor_views/schedule_appointment_view.dart'; // Importa a tela para agendar uma consulta

// Tela principal do paciente (Dashboard)
class PatientDashboard extends StatefulWidget {
  const PatientDashboard({Key? key}) : super(key: key);

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  // Índice da navegação inferior para controlar a tela visível
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        // IndexedStack permite exibir apenas uma tela por vez
        index: _selectedIndex,
        children: const [
          PatientAppointmentsView(), // Tela de consultas do paciente
          ScheduleAppointmentView(), // Tela de agendamento de consulta
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        // Controle do índice da navegação inferior
        currentIndex: _selectedIndex,
        onTap: (int index) {
          // Alterar o índice selecionado quando um item da navegação inferior é tocado
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today), // Ícone para visualizar consultas
            label: 'Minhas Consultas', // Texto da opção de "Minhas Consultas"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add), // Ícone para agendar uma nova consulta
            label: 'Agendar', // Texto da opção de "Agendar"
          ),
        ],
      ),
    );
  }
}
