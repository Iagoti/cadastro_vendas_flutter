import '../repositories/auth_repository.dart';
import '../models/usuario_model.dart';

class AuthService {
  final AuthRepository _repository;

  AuthService(this._repository);

  Future<UsuarioModel?> login(String username, String password) async {
    try {
      return await _repository.login(username, password);
    } catch (e) {
      throw Exception('Falha ao realizar login: ${e.toString()}');
    }
  }
}