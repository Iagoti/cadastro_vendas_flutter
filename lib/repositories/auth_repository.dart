import 'package:cadastro_vendas_flutter/repositories/database_repository.dart';

import '../models/usuario_model.dart';

class AuthRepository {
  final _dbService = DataBaseRepository();

  Future<UsuarioModel?> login(String username, String password) async {
    final db = await _dbService.database;
    final result = await db.query(
      'usuario',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
      limit: 1,
    );
    
    if (result.isNotEmpty) {
      return UsuarioModel.fromMap(result.first);
    }
    return null;
  }
}