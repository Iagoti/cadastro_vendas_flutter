
import 'package:cadastro_vendas_flutter/repositories/database_repository.dart';

import '../models/produto_model.dart';

class ProdutoRepository {
  final _dbService = DataBaseRepository();

  Future<List<ProdutoModel>> listarProdutos() async {
    final db = await _dbService.database;
    final produtos = await db.query('produto');
    return produtos.map((e) => ProdutoModel.fromMap(e)).toList();
  }

  Future<ProdutoModel?> obterProdutoPorId(int cdProduto) async {
    final db = await _dbService.database;
    final result = await db.query(
      'produto',
      where: 'cd_produto = ?',
      whereArgs: [cdProduto],
      limit: 1,
    );
    
    if (result.isNotEmpty) {
      return ProdutoModel.fromMap(result.first);
    }
    return null;
  }
}