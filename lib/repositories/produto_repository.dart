import 'package:cadastro_vendas_flutter/repositories/database_repository.dart';
import '../models/produto_model.dart';

class ProdutoRepository {
  final _dbService = DataBaseRepository();

  Future<int> salvarProduto(ProdutoModel produto) async {
    final db = await _dbService.database;
    
    if (produto.cd_produto != null) {
      return await db.update(
        'produto',
        produto.toMap(),
        where: 'cd_produto = ?',
        whereArgs: [produto.cd_produto],
      );
    } else {
      return await db.insert('produto', produto.toMap());
    }
  }

  Future<List<ProdutoModel>> listarProdutos() async {
    final db = await _dbService.database;
    final produtos = await db.query('produto', orderBy: 'nome');
    return produtos.map((e) => ProdutoModel.fromMap(e)).toList();
  }

  Future<List<ProdutoModel>> buscarProdutosPorNome(String nome) async {
    final db = await _dbService.database;
    final produtos = await db.query(
      'produto',
      where: 'nome LIKE ?',
      whereArgs: ['%$nome%'],
      orderBy: 'nome',
    );
    return produtos.map((e) => ProdutoModel.fromMap(e)).toList();
  }

  Future<int> excluirProduto(int cdProduto) async {
    final db = await _dbService.database;
    return await db.delete(
      'produto',
      where: 'cd_produto = ?',
      whereArgs: [cdProduto],
    );
  }
}