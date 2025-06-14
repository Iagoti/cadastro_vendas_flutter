import '../repositories/produto_repository.dart';
import '../models/produto_model.dart';

class ProdutoService {
  final ProdutoRepository _repository;

  ProdutoService(this._repository);

  Future<List<ProdutoModel>> listarProdutos() async {
    try {
      return await _repository.listarProdutos();
    } catch (e) {
      throw Exception('Falha ao listar produtos: ${e.toString()}');
    }
  }

  Future<ProdutoModel?> obterProdutoPorId(int cdProduto) async {
    try {
      return await _repository.obterProdutoPorId(cdProduto);
    } catch (e) {
      throw Exception('Falha ao obter produto: ${e.toString()}');
    }
  }
}