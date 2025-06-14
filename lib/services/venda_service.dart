import 'package:cadastro_vendas_flutter/models/item_venda_model.dart';
import 'package:cadastro_vendas_flutter/models/parcela_model.dart';
import 'package:cadastro_vendas_flutter/models/produto_model.dart';
import 'package:intl/intl.dart';

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
      final results = await _repository.listarVendasCompletas();
      final vendasMap = <int, VendaModel>{};
      final itensMap = <int, List<ItemVendaModel>>{};
      final parcelasMap = <int, List<ParcelaModel>>{};

      for (final row in results) {
        final cdVenda = row['cd_venda'] as int;
        
        // Processa dados básicos da venda
        if (!vendasMap.containsKey(cdVenda)) {
          vendasMap[cdVenda] = VendaModel(
            cd_venda: cdVenda,
            cd_cliente: row['cd_cliente'] as int,
            clienteNome: row['cliente_nome'] as String,
            data_venda: DateTime.parse(row['data_venda'] as String),
            forma_pagamento: row['forma_pagamento'] as String,
            entrada: row['entrada'] as double,
            total: row['total'] as double,
            quantidade_parcelas: row['quantidade_parcelas'] as int,
            itens: [],
            parcelas: [],
          );
          itensMap[cdVenda] = [];
          parcelasMap[cdVenda] = [];
        }

        // Processa itens da venda (se existirem)
        if (row['cd_produto'] != null) {
          final novoItem = ItemVendaModel(
            cd_venda: cdVenda,
            cd_produto: row['cd_produto'] as int,
            produto: ProdutoModel.venda(
              cd_produto: row['cd_produto'] as int,
              nome: row['produto_nome'] as String,
              valorVenda: row['valor_venda'] as double,
              tamanho: row['tamanho'] as String,
            ),
            quantidade: row['item_quantidade'] as int,
            valor_unitario: row['valor_unitario'] as double,
          );
          
          // Verifica se o item já foi adicionado
          if (!itensMap[cdVenda]!.any((i) => 
              i.cd_produto == novoItem.cd_produto &&
              i.quantidade == novoItem.quantidade &&
              i.valor_unitario == novoItem.valor_unitario)) {
            itensMap[cdVenda]!.add(novoItem);
          }
        }

        // Processa parcelas (se existirem)
        if (row['cd_parcela'] != null && !parcelasMap[cdVenda]!.any((p) => p.cd_parcela == row['cd_parcela'])) {
          parcelasMap[cdVenda]!.add(ParcelaModel(
            cd_parcela: row['cd_parcela'] as int,
            cd_venda: cdVenda,
            numero_parcela: row['numero_parcela'] as int,
            valor_parcela: row['valor_parcela'] as double,
            data_vencimento: DateTime.parse(row['data_vencimento'] as String),
            data_pagamento: row['data_pagamento'] != null 
                ? DateTime.parse(row['data_pagamento'] as String) 
                : null,
            pago: (row['pago'] as int) == 1,
          ));
        }
      }

      // Combina todos os dados
      return vendasMap.values.map((venda) {
        return venda.copyWith(
          itens: itensMap[venda.cd_venda] ?? [],
          parcelas: parcelasMap[venda.cd_venda] ?? [],
        );
      }).toList();
    } catch (e) {
      print('Erro ao listar vendas: $e');
      return [];
    }
  }

  DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is DateTime) return date;
    try {
      return DateFormat('yyyy-MM-dd').parse(date.toString());
    } catch (e) {
      return DateTime.now();
    }
  }

  Future<void> atualizarVenda(VendaModel venda) async {
  try {
    await _repository.atualizarVenda(venda);
  } catch (e) {
    throw Exception('Falha ao atualizar venda: ${e.toString()}');
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