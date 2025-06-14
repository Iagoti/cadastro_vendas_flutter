import '../services/auth_service.dart';
import '../models/usuario_model.dart';

class AuthController {
  final AuthService _service;

  AuthController(this._service);

  Future<UsuarioModel?> login(String username, String password) async {
    return await _service.login(username, password);
  }
}