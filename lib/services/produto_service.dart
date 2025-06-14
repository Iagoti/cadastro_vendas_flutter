import '../repositories/produto_repository.dart';
import '../models/produto_model.dart';

class ProdutoService {
  final ProdutoRepository _repository;

  ProdutoService(this._repository);

  Future<int> salvarProduto(ProdutoModel produto) async {
    try {
      return await _repository.salvarProduto(produto);
    } catch (e) {
      throw Exception('Erro ao salvar produto: ${e.toString()}');
    }
  }

  Future<List<ProdutoModel>> listarProdutos() async {
    try {
      return await _repository.listarProdutos();
    } catch (e) {
      throw Exception('Falha ao listar produtos: ${e.toString()}');
    }
  }

  Future<List<ProdutoModel>> buscarProdutosPorNome(String nome) async {
    try {
      return await _repository.buscarProdutosPorNome(nome);
    } catch (e) {
      throw Exception('Erro ao buscar produtos: ${e.toString()}');
    }
  }

  Future<void> excluirProduto(int cdProduto) async {
    try {
      await _repository.excluirProduto(cdProduto);
    } catch (e) {
      throw Exception('Erro ao excluir produto: ${e.toString()}');
    }
  }
}