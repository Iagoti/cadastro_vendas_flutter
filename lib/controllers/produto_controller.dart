import '../services/produto_service.dart';
import '../models/produto_model.dart';

class ProdutoController {
  final ProdutoService _service;

  ProdutoController(this._service);

  Future<List<ProdutoModel>> listarProdutos() async {
    return await _service.listarProdutos();
  }

  Future<ProdutoModel?> obterProdutoPorId(int cdProduto) async {
    return await _service.obterProdutoPorId(cdProduto);
  }
}