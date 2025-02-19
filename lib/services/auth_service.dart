import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService with ChangeNotifier {
  // Instância do FirebaseAuth para autenticação
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Instância do GoogleSignIn para autenticação com o Google
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Instância do Firestore para interagir com o banco de dados
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Getter para obter o usuário atualmente autenticado
  User? get currentUser => _auth.currentUser;

  // Stream que emite alterações no estado de autenticação (útil para atualizar a UI em tempo real)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Método para autenticar o usuário com o Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      // Inicia o processo de login com o Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // Retorna null se o usuário cancelar o login

      // Obtém as credenciais de autenticação do Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Autentica o usuário no Firebase com as credenciais do Google
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Verifica se o usuário já existe no Firestore
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        
        if (!userDoc.exists) {
          // Se for um novo usuário, cria um perfil no Firestore
          final newUser = UserModel(
            id: user.uid,
            name: user.displayName ?? '', // Usa o nome do Google ou uma string vazia
            email: user.email ?? '', // Usa o email do Google ou uma string vazia
            userType: UserType.patient, // Define o tipo de usuário como 'patient' por padrão
          );
          
          // Salva o novo usuário no Firestore
          await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
          return newUser; // Retorna o novo usuário criado
        }
        
        // Se o usuário já existir, retorna os dados do Firestore
        return UserModel.fromMap({...userDoc.data()!, 'id': user.uid});
      }
      return null; // Retorna null se o usuário não for autenticado
    } catch (e) {
      print('Error signing in with Google: $e'); // Log de erro em caso de falha
      return null;
    }
  }

  // Método para autenticar o usuário com email e senha
  Future<UserModel?> signInWithEmailPassword(String email, String password) async {
    try {
      // Autentica o usuário no Firebase com email e senha
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final User? user = userCredential.user;
      if (user != null) {
        // Busca os dados do usuário no Firestore
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          // Retorna os dados do usuário se existirem
          return UserModel.fromMap({...userDoc.data()!, 'id': user.uid});
        }
      }
      return null; // Retorna null se o usuário não for encontrado
    } catch (e) {
      print('Error signing in with email/password: $e'); // Log de erro em caso de falha
      return null;
    }
  }

  // Método para registrar um novo usuário com email e senha
  Future<UserModel?> registerWithEmailPassword(
    String email,
    String password,
    String name,
    UserType userType,
  ) async {
    try {
      // Cria um novo usuário no Firebase com email e senha
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final User? user = userCredential.user;
      if (user != null) {
        // Cria um novo objeto UserModel com os dados fornecidos
        final newUser = UserModel(
          id: user.uid,
          name: name,
          email: email,
          userType: userType,
        );
        
        // Salva o novo usuário no Firestore
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
        return newUser; // Retorna o novo usuário criado
      }
      return null; // Retorna null se o usuário não for criado
    } catch (e) {
      print('Error registering with email/password: $e'); // Log de erro em caso de falha
      return null;
    }
  }

  // Método para fazer logout do usuário
  Future<void> signOut() async {
    try {
      // Faz logout do Firebase e do Google Sign-In simultaneamente
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      notifyListeners(); // Notifica os ouvintes (útil para atualizar a UI)
    } catch (e) {
      print('Error signing out: $e'); // Log de erro em caso de falha
    }
  }
}