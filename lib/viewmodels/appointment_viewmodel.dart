import 'package:flutter/foundation.dart';
import '../models/appointment_model.dart';
import '../services/appointment_service.dart';

class AppointmentViewModel with ChangeNotifier {
  // Instância do serviço de consultas (AppointmentService) para interagir com a lógica de negócios
  final AppointmentService _appointmentService;

  // Armazena as estatísticas do médico (total de consultas, concluídas, canceladas, etc.)
  Map<String, dynamic>? _statistics;

  // Armazena a lista de consultas (pode ser usada para cache ou manipulação local)
  List<AppointmentModel>? _appointments;

  // Construtor que recebe o serviço de consultas como dependência
  AppointmentViewModel(this._appointmentService);

  // Getter para acessar as estatísticas do médico
  Map<String, dynamic>? get statistics => _statistics;

  // Getter para acessar a lista de consultas
  List<AppointmentModel>? get appointments => _appointments;

  // Método para obter uma lista de consultas de um médico como um Stream
  Stream<List<AppointmentModel>> getDoctorAppointments(String doctorId) {
    return _appointmentService.getDoctorAppointments(doctorId);
  }

  // Método para obter uma lista de consultas de um paciente como um Stream
  Stream<List<AppointmentModel>> getPatientAppointments(String patientId) {
    return _appointmentService.getPatientAppointments(patientId);
  }

  // Método para obter a disponibilidade de um médico em uma data específica
  Future<List<AppointmentModel>> getDoctorAvailability(String doctorId, DateTime date) {
    return _appointmentService.getDoctorAvailability(doctorId, date);
  }

  // Método para criar uma nova consulta
  Future<void> createAppointment(AppointmentModel appointment) async {
    await _appointmentService.createAppointment(appointment);
    notifyListeners(); // Notifica os ouvintes (útil para atualizar a UI)
  }

  // Método para atualizar uma consulta existente
  Future<void> updateAppointment(AppointmentModel appointment) async {
    await _appointmentService.updateAppointment(appointment);
    notifyListeners(); // Notifica os ouvintes (útil para atualizar a UI)
  }

  // Método para cancelar uma consulta
  Future<void> cancelAppointment(String appointmentId) async {
    await _appointmentService.cancelAppointment(appointmentId);
    notifyListeners(); // Notifica os ouvintes (útil para atualizar a UI)
  }

  // Método para carregar as estatísticas de um médico
  Future<void> loadDoctorStatistics(String doctorId) async {
    _statistics = await _appointmentService.getDoctorStatistics(doctorId);
    notifyListeners(); // Notifica os ouvintes (útil para atualizar a UI)
  }

  // Método para verificar se um horário está disponível
  bool isTimeSlotAvailable(DateTime dateTime, List<AppointmentModel> existingAppointments) {
    return !existingAppointments.any((appointment) =>
        appointment.dateTime.hour == dateTime.hour && // Verifica se há conflito de horário
        appointment.status != 'cancelled'); // Ignora consultas canceladas
  }

  // Método para gerar uma lista de horários disponíveis em um dia específico
  List<DateTime> getAvailableTimeSlots(
    DateTime date,
    List<AppointmentModel> existingAppointments, {
    int startHour = 8, // Horário inicial padrão (8h)
    int endHour = 17, // Horário final padrão (17h)
    int intervalMinutes = 60, // Intervalo entre os horários (60 minutos)
  }) {
    final List<DateTime> availableSlots = [];
    
    // Itera sobre os horários do dia, dentro do intervalo especificado
    for (int hour = startHour; hour <= endHour; hour++) {
      final timeSlot = DateTime(
        date.year,
        date.month,
        date.day,
        hour,
      );
      
      // Ignora horários passados para o dia atual
      if (date.year == DateTime.now().year &&
          date.month == DateTime.now().month &&
          date.day == DateTime.now().day &&
          hour <= DateTime.now().hour) {
        continue;
      }
      
      // Adiciona o horário à lista se estiver disponível
      if (isTimeSlotAvailable(timeSlot, existingAppointments)) {
        availableSlots.add(timeSlot);
      }
    }
    
    return availableSlots; // Retorna a lista de horários disponíveis
  }
}