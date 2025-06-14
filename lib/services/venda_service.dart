import 'package:cadastro_vendas_flutter/models/item_venda_model.dart';
import 'package:cadastro_vendas_flutter/models/parcela_model.dart';

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
      final vendasBase = await _repository.listarVendasBase();
      final listaVendas = <VendaModel>[];

      for (final vendaMap in vendasBase) {
        final cdVenda = vendaMap['cd_venda'] as int;
        
        // Buscar dados relacionados
        final itens = await _repository.listarItensVenda(cdVenda);
        final parcelas = await _repository.listarParcelasVenda(cdVenda);

        // Validar dados antes de criar o modelo
        if (vendaMap['cliente_nome'] == null) {
          throw Exception('Nome do cliente não encontrado para venda $cdVenda');
        }

        listaVendas.add(VendaModel.fromMap(
          vendaMap,
          itens: itens.map((e) => ItemVendaModel.fromMap(e)).toList(),
          parcelas: parcelas.map((e) => ParcelaModel.fromMap(e)).toList(),
          clienteNome: vendaMap['cliente_nome'] as String,
        ));
      }

      return listaVendas;
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