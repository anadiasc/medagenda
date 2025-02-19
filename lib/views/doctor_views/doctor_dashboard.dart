import 'package:flutter/material.dart';
import 'package:med_agenda/views/doctor_views/doctor_appointments_view.dart';
import 'package:med_agenda/views/doctor_views/doctor_statistics_view.dart';
import 'package:med_agenda/views/doctor_views/patient_list_view.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../viewmodels/appointment_viewmodel.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({Key? key}) : super(key: key);

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final doctorId = context.read<AuthService>().currentUser?.uid;
      if (doctorId != null) {
        context.read<AppointmentViewModel>().loadDoctorStatistics(doctorId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          DoctorStatisticsView(),
          DoctorAppointmentsView(),
          PatientListView(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Consultas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Pacientes',
          ),
        ],
      ),
    );
  }
}