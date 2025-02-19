import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';


class UserService with ChangeNotifier {
  // Instância do Firestore para interagir com o banco de dados
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cache em memória para armazenar usuários e evitar consultas repetidas ao Firestore
  final Map<String, UserModel> _userCache = {};

  // Método para obter uma lista de médicos (usuários com role 'doctor') como um Stream
  Stream<List<UserModel>> getDoctors() {
    return _firestore
        .collection('users') // Acessa a coleção 'users' no Firestore
        .where('role', isEqualTo: 'doctor') // Filtra usuários com role 'doctor'
        .snapshots() // Obtém um Stream de snapshots (atualizações em tempo real)
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap({...doc.data(), 'id': doc.id}))
            .toList()); // Converte os documentos em objetos UserModel
  }

  // Método para obter uma lista de pacientes (usuários com role 'patient') como um Stream
  Stream<List<UserModel>> getPatients() {
    return _firestore
        .collection('users') // Acessa a coleção 'users' no Firestore
        .where('role', isEqualTo: 'patient') // Filtra usuários com role 'patient'
        .snapshots() // Obtém um Stream de snapshots (atualizações em tempo real)
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap({...doc.data(), 'id': doc.id}))
            .toList()); // Converte os documentos em objetos UserModel
  }

  // Método para buscar um usuário pelo ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      // Verifica se o usuário já está no cache
      if (_userCache.containsKey(userId)) {
        return _userCache[userId]; // Retorna o usuário do cache
      }

      // Se não estiver no cache, busca no Firestore
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        return null; // Retorna null se o usuário não existir
      }

      // Converte o documento Firestore em um objeto UserModel
      final user = UserModel.fromMap({...doc.data()!, 'id': doc.id});
      
      // Adiciona o usuário ao cache para futuras consultas
      _userCache[userId] = user;
      
      return user; // Retorna o usuário encontrado
    } catch (e) {
      print('Error getting user by ID: $e'); // Log de erro em caso de falha
      return null;
    }
  }

  // Método para atualizar um usuário no Firestore e no cache
  Future<void> updateUser(UserModel user) async {
    try {
      // Atualiza o usuário no Firestore
      await _firestore.collection('users').doc(user.id).update(user.toMap());
      
      // Atualiza o usuário no cache
      _userCache[user.id] = user;
      
      // Notifica os ouvintes (útil para atualizar a UI em tempo real)
      notifyListeners();
    } catch (e) {
      print('Error updating user: $e'); // Log de erro em caso de falha
      rethrow; // Relança a exceção para ser tratada pelo chamador
    }
  }

  // Método para limpar todo o cache de usuários
  void clearCache() {
    _userCache.clear();
  }

  // Método para remover um usuário específico do cache
  void removeFromCache(String userId) {
    _userCache.remove(userId);
  }
}