
import 'package:cadastro_vendas_flutter/repositories/database_repository.dart';

class SqlQueryRepository {
   final _dbService = DataBaseRepository();

  Future<List<Map<String, dynamic>>> executeQuery(String sql) async {
   final db = await _dbService.database;
    return await db.rawQuery(sql);
  }
}