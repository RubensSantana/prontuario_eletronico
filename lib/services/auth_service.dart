import 'package:firebase_auth/firebase_auth.dart';

/// Serviço que centraliza todas as operações de autenticação com o Firebase.
///
/// Essa classe encapsula o uso do FirebaseAuth, tornando o código mais
/// organizado e fácil de manter. Pode ser usada em qualquer parte do app.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Retorna o usuário atual (logado)
  User? get currentUser => _auth.currentUser;

  /// Stream que monitora mudanças no estado de autenticação.
  /// É usada no AuthGate (main.dart) para exibir a tela correta.
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  ///  Registrar um novo usuário com e-mail e senha.
  ///
  /// Após criar, envia automaticamente um e-mail de verificação.
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Envia e-mail de verificação (opcional, pode ser desativado)
    if (!cred.user!.emailVerified) {
      await cred.user!.sendEmailVerification();
    }

    return cred;
  }

  /// Fazer login com e-mail e senha
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Verifica se o e-mail foi confirmado (opcional)
    if (!cred.user!.emailVerified) {
      // Você pode decidir o que fazer aqui:
      // - Bloquear o acesso até verificar
      // - Apenas mostrar um aviso
      // Aqui, só enviamos um novo e-mail de verificação se ainda não foi verificado.
      await cred.user!.sendEmailVerification();
    }

    return cred;
  }

  /// Logout (encerra a sessão do usuário atual)
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Enviar e-mail de verificação manualmente
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// Enviar e-mail para redefinição de senha
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Deletar a conta atual (opcional)
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.delete();
    }
  }
}
