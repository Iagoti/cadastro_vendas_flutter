import '../services/venda_service.dart';
import '../models/venda_model.dart';

class VendaController {
  final VendaService _service;

  VendaController(this._service);

  Future<int> cadastrarVenda(VendaModel venda) async {
    return await _service.cadastrarVenda(venda);
  }

  Future<List<VendaModel>> listarVendas() async {
    try {
      return await _service.listarVendas();
    } catch (e, stackTrace) {
      print('Erro ao listar vendas: $e');
      print('StackTrace: $stackTrace');
      rethrow;
    }
  }

  Future<void> registrarPagamentoParcela(int cdParcela, DateTime dataPagamento) async {
    await _service.registrarPagamentoParcela(cdParcela, dataPagamento);
  }
}