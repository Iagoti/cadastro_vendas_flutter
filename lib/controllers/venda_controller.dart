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
      final vendas = await _service.listarVendas();
      return vendas;
    } catch (e) {
      print('Erro no VendaController.listarVendas: $e');
      return []; // Retorna lista vazia em caso de erro
    }
  }

  Future<void> atualizarVenda(VendaModel venda) async {
  await _service.atualizarVenda(venda);
}

Future<void> registrarPagamentoParcela(int cdParcela, DateTime dataPagamento) async {
  await _service.registrarPagamentoParcela(cdParcela, dataPagamento);
}
}