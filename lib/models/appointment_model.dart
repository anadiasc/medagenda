import 'package:cloud_firestore/cloud_firestore.dart';

// Classe que representa um agendamento de consulta médica
class AppointmentModel {
  final String id; // Identificador único do agendamento
  final String patientId; // Identificador do paciente
  final String doctorId; // Identificador do médico
  final DateTime dateTime; // Data e hora do agendamento
  final String status; // Status do agendamento (padrão: 'pending')
  final String? notes; // Notas opcionais sobre o agendamento

  // Construtor da classe, com status padrão como 'pending'
  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.dateTime,
    this.status = 'pending',
    this.notes,
  });

  // Converte o objeto AppointmentModel para um mapa (usado para armazenar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'doctorId': doctorId,
      'dateTime': Timestamp.fromDate(dateTime), // Converte DateTime para Timestamp
      'status': status,
      if (notes != null) 'notes': notes, // Adiciona notas apenas se não forem nulas
    };
  }

  // Método de fábrica que cria uma instância de AppointmentModel a partir de um mapa
  factory AppointmentModel.fromMap(Map<String, dynamic> map) {
    return AppointmentModel(
      id: map['id'] as String? ?? '', // Define um ID padrão vazio caso não exista
      patientId: map['patientId'] as String? ?? '', // Define um ID de paciente padrão vazio caso não exista
      doctorId: map['doctorId'] as String? ?? '', // Define um ID de médico padrão vazio caso não exista
      dateTime: map['dateTime'] is Timestamp 
          ? (map['dateTime'] as Timestamp).toDate() // Converte Timestamp para DateTime
          : DateTime.now(), // Se não existir, usa a data e hora atuais
      status: map['status'] as String? ?? 'pending', // Define status padrão como 'pending'
      notes: map['notes'] as String?, // Notas opcionais
    );
  }

  // Método que cria uma cópia do objeto com valores opcionais atualizados
  AppointmentModel copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    DateTime? dateTime,
    String? status,
    String? notes,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}
