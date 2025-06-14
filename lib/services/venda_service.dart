import '../repositories/venda_repository.dart';
import '../models/venda_model.dart';

class VendaService {
  final VendaRepository _repository;

  VendaService(this._repository);

  Future<int> cadastrarVenda(VendaModel venda) async {
    try {
      return await _repository.insertVenda(venda);
    } catch (e) {
      throw Exception('Falha ao cadastrar venda: ${e.toString()}');
    }
  }

  Future<List<VendaModel>> listarVendas() async {
    try {
      return await _repository.listarVendas();
    } catch (e) {
      throw Exception('Falha ao listar vendas: ${e.toString()}');
    }
  }

  Future<void> registrarPagamentoParcela(int cdParcela, DateTime dataPagamento) async {
    try {
      await _repository.registrarPagamentoParcela(cdParcela, dataPagamento);
    } catch (e) {
      throw Exception('Falha ao registrar pagamento: ${e.toString()}');
    }
  }
}