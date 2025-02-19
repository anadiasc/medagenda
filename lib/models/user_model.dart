// Enumeração que define os tipos de usuário: médico (doctor) ou paciente (patient)
enum UserType { doctor, patient }

// Classe que representa um usuário no sistema
class UserModel {
  final String id; // Identificador único do usuário
  final String name; // Nome do usuário
  final String email; // Endereço de e-mail do usuário
  final UserType userType; // Tipo de usuário: médico ou paciente

  // Construtor da classe, exigindo que todos os campos sejam obrigatórios
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.userType,
  });

  // Converte o objeto UserModel para um mapa (usado, por exemplo, para armazenar em um banco de dados)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      // Converte o enum UserType para string antes de salvar no mapa
      'userType': userType == UserType.doctor ? 'doctor' : 'patient',
    };
  }

  // Método de fábrica que cria uma instância de UserModel a partir de um mapa
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '', // Define um ID padrão vazio caso não exista
      name: map['name'] ?? '', // Define um nome padrão vazio caso não exista
      email: map['email'] ?? '', // Define um e-mail padrão vazio caso não exista
      // Converte a string armazenada no mapa de volta para um enum UserType
      userType: map['userType'] == 'doctor' ? UserType.doctor : UserType.patient,
    );
  }

  // Método que cria uma cópia do objeto com valores opcionais atualizados
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    UserType? userType,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      userType: userType ?? this.userType,
    );
  }

  // Sobrescreve o operador de igualdade para comparar objetos com base no ID
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  // Sobrescreve o hashCode para garantir que a comparação de objetos seja consistente
  @override
  int get hashCode => id.hashCode;
}
