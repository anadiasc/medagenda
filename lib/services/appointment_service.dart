import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/appointment_model.dart';

class AppointmentService with ChangeNotifier {
  // Instância do Firestore para interagir com o banco de dados
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para obter uma lista de consultas de um médico específico como um Stream
  Stream<List<AppointmentModel>> getDoctorAppointments(String doctorId) {
    return _firestore
        .collection('appointments') // Acessa a coleção 'appointments'
        .where('doctorId', isEqualTo: doctorId) // Filtra consultas pelo ID do médico
        .orderBy('dateTime', descending: false) // Ordena as consultas por data/hora (ascendente)
        .snapshots() // Obtém um Stream de snapshots (atualizações em tempo real)
        .map((snapshot) => snapshot.docs
            .map((doc) => AppointmentModel.fromMap({...doc.data(), 'id': doc.id}))
            .toList()); // Converte os documentos em objetos AppointmentModel
  }

  // Método para obter uma lista de consultas de um paciente específico como um Stream
  Stream<List<AppointmentModel>> getPatientAppointments(String patientId) {
    return _firestore
        .collection('appointments') // Acessa a coleção 'appointments'
        .where('patientId', isEqualTo: patientId) // Filtra consultas pelo ID do paciente
        .snapshots() // Obtém um Stream de snapshots (atualizações em tempo real)
        .map((snapshot) => snapshot.docs
            .map((doc) => AppointmentModel.fromMap({...doc.data(), 'id': doc.id}))
            .toList()); // Converte os documentos em objetos AppointmentModel
  }

  // Método para obter a disponibilidade de um médico em uma data específica
  Future<List<AppointmentModel>> getDoctorAvailability(String doctorId, DateTime date) async {
    try {
      // Define o início e o fim do dia para filtrar as consultas
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Consulta as consultas do médico no dia especificado, excluindo as canceladas
      final querySnapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId) // Filtra pelo ID do médico
          .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay)) // Consultas a partir do início do dia
          .where('dateTime', isLessThan: Timestamp.fromDate(endOfDay)) // Consultas até o fim do dia
          .where('status', isNotEqualTo: 'cancelled') // Exclui consultas canceladas
          .get();

      // Converte os documentos em objetos AppointmentModel
      return querySnapshot.docs
          .map((doc) => AppointmentModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error getting doctor availability: $e'); // Log de erro em caso de falha
      return [];
    }
  }

  // Método para criar uma nova consulta
  Future<void> createAppointment(AppointmentModel appointment) async {
    try {
      // Verifica se o horário da consulta já está ocupado
      final existingAppointments = await getDoctorAvailability(
        appointment.doctorId,
        appointment.dateTime,
      );

      // Verifica se há conflito de horário
      final isSlotTaken = existingAppointments.any((existing) =>
          existing.dateTime.hour == appointment.dateTime.hour &&
          existing.status != 'cancelled');

      if (isSlotTaken) {
        throw Exception('Este horário já está ocupado. Por favor, escolha outro horário.');
      }

      // Adiciona a nova consulta ao Firestore
      await _firestore.collection('appointments').add(appointment.toMap());
      notifyListeners(); // Notifica os ouvintes (útil para atualizar a UI)
    } catch (e) {
      print('Error creating appointment: $e'); // Log de erro em caso de falha
      rethrow; // Relança a exceção para ser tratada pelo chamador
    }
  }

  // Método para atualizar uma consulta existente
  Future<void> updateAppointment(AppointmentModel appointment) async {
    try {
      // Atualiza a consulta no Firestore
      await _firestore
          .collection('appointments')
          .doc(appointment.id)
          .update(appointment.toMap());
      notifyListeners(); // Notifica os ouvintes (útil para atualizar a UI)
    } catch (e) {
      print('Error updating appointment: $e'); // Log de erro em caso de falha
      rethrow; // Relança a exceção para ser tratada pelo chamador
    }
  }

  // Método para cancelar uma consulta
  Future<void> cancelAppointment(String appointmentId) async {
    try {
      // Atualiza o status da consulta para 'cancelled' no Firestore
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': 'cancelled',
      });
      notifyListeners(); // Notifica os ouvintes (útil para atualizar a UI)
    } catch (e) {
      print('Error cancelling appointment: $e'); // Log de erro em caso de falha
      rethrow; // Relança a exceção para ser tratada pelo chamador
    }
  }

  // Método para obter estatísticas de consultas de um médico
  Future<Map<String, dynamic>> getDoctorStatistics(String doctorId) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1); // Define o início do mês atual

      // Consulta as consultas do médico no mês atual
      final querySnapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId) // Filtra pelo ID do médico
          .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth)) // Consultas a partir do início do mês
          .orderBy('dateTime', descending: false) // Ordena as consultas por data/hora (ascendente)
          .get();

      // Converte os documentos em objetos AppointmentModel
      final appointments = querySnapshot.docs
          .map((doc) => AppointmentModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();

      // Calcula o total de consultas, consultas concluídas e consultas canceladas
      final totalAppointments = appointments.length;
      final completedAppointments = appointments.where((a) => a.status == 'completed').length;
      final cancelledAppointments = appointments.where((a) => a.status == 'cancelled').length;

      // Calcula os horários mais populares (quantidade de consultas por hora)
      final timeSlots = <int, int>{};
      for (final appointment in appointments) {
        final hour = appointment.dateTime.hour;
        timeSlots[hour] = (timeSlots[hour] ?? 0) + 1;
      }

      // Retorna um mapa com as estatísticas
      return {
        'totalAppointments': totalAppointments,
        'completedAppointments': completedAppointments,
        'cancelledAppointments': cancelledAppointments,
        'popularTimeSlots': timeSlots,
      };
    } catch (e) {
      print('Error getting doctor statistics: $e'); // Log de erro em caso de falha
      rethrow; // Relança a exceção para ser tratada pelo chamador
    }
  }
}