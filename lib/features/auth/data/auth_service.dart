import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../shared/models/user_model.dart';

class AuthService {
  Future<void> login({required String email, required String senha}) async {
    final response = await ApiClient.post('/auth/login', {
      'email': email,
      'senha': senha,
    });

    final success = response['success'] == true;
    if (!success) {
      throw const ApiException('Falha ao fazer login');
    }

    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Resposta de login invalida');
    }

    final token = data['token']?.toString() ?? '';
    if (token.isEmpty) {
      throw const ApiException('Token nao retornado no login');
    }

    await ApiClient.saveToken(token);
  }

  Future<void> register({
    required String nome,
    required String email,
    required String senha,
    required String senhaConfirm,
  }) async {
    final response = await ApiClient.post('/auth/register', {
      'nome': nome,
      'email': email,
      'senha': senha,
      'senhaConfirm': senhaConfirm,
    });

    if (response['success'] != true) {
      throw const ApiException('Falha ao registrar usuario');
    }
  }

  Future<UserModel> perfil() async {
    final response = await ApiClient.get('/auth/perfil');
    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Resposta de perfil invalida');
    }
    return UserModel.fromJson(data);
  }

  Future<void> logout() async {
    try {
      await ApiClient.post('/auth/logout', {});
    } catch (_) {
      // Mesmo se a API falhar no logout, o token local deve ser removido.
    }
    await ApiClient.clearToken();
  }

  Future<void> requestPasswordReset({required String emailOrPhone}) async {
    final response = await ApiClient.post('/auth/forgot-password', {
      'emailOrPhone': emailOrPhone,
    });

    if (response['success'] != true) {
      throw const ApiException('Falha ao solicitar redefinição de senha');
    }
  }

  Future<void> verifyResetCode({
    required String emailOrPhone,
    required String code,
  }) async {
    final response = await ApiClient.post('/auth/verify-code', {
      'emailOrPhone': emailOrPhone,
      'code': code,
    });

    if (response['success'] != true) {
      throw const ApiException('Código inválido ou expirado');
    }
  }

  Future<void> resetPassword({
    required String emailOrPhone,
    required String code,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await ApiClient.post('/auth/reset-password', {
      'emailOrPhone': emailOrPhone,
      'code': code,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    });

    if (response['success'] != true) {
      throw const ApiException('Falha ao redefinir senha');
    }
  }
}
