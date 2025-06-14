import '../services/produto_service.dart';
import '../models/produto_model.dart';

class ProdutoController {
  final ProdutoService _service;

  ProdutoController(this._service);

  Future<int> salvarProduto(ProdutoModel produto) async {
    try {
      return await _service.salvarProduto(produto);
    } catch (e) {
      throw Exception('Falha ao salvar produto: ${e.toString()}');
    }
  }

  Future<void> excluirProduto(int cdProduto) async {
    try {
      await _service.excluirProduto(cdProduto);
    } catch (e) {
      throw Exception('Falha ao excluir produto: ${e.toString()}');
    }
  }

  Future<List<ProdutoModel>> listarProdutos() async {
    return await _service.listarProdutos();
  }

  Future<List<ProdutoModel>> buscarProdutosPorNome(String nome) async {
    try {
      return await _service.buscarProdutosPorNome(nome);
    } catch (e) {
      throw Exception('Falha ao buscar produtos: ${e.toString()}');
    }
  }
}