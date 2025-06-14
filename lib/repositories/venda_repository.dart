import 'package:cadastro_vendas_flutter/repositories/database_repository.dart';
import 'package:intl/intl.dart';
import '../models/venda_model.dart';
import '../models/item_venda_model.dart';
import '../models/parcela_model.dart';

class VendaRepository {
  final _dbService = DataBaseRepository();

  Future<int> insertVenda(VendaModel venda) async {
    final db = await _dbService.database;
    
    final cdVenda = await db.transaction<int>((txn) async {
      // Inserir venda
      final cdVenda = await txn.insert('venda', venda.toMap());
      
      // Inserir itens da venda
      for (final item in venda.itens) {
        await txn.insert('item_venda', {
          ...item.toMap(),
          'cd_venda': cdVenda,
        });
      }
      
      // Inserir parcelas
      for (final parcela in venda.parcelas) {
        await txn.insert('parcela', {
          ...parcela.toMap(),
          'cd_venda': cdVenda,
        });
      }
      
      return cdVenda;
    });
    
    return cdVenda;
  }

  Future<List<VendaModel>> listarVendas() async {
    final db = await _dbService.database;
    
    final vendas = await db.rawQuery('''
      SELECT v.*, c.nome as cliente_nome 
      FROM venda v
      JOIN cliente c ON v.cd_cliente = c.cd_cliente
      ORDER BY v.data_venda DESC
    ''');
    
    final listaVendas = <VendaModel>[];
    
    for (final vendaMap in vendas) {
      final cdVenda = vendaMap['cd_venda'] as int;
      
      // Buscar itens da venda
      final itens = await db.rawQuery('''
        SELECT iv.*, p.nome as produto_nome
        FROM item_venda iv
        JOIN produto p ON iv.cd_produto = p.cd_produto
        WHERE iv.cd_venda = ?
      ''', [cdVenda]);
      
      // Buscar parcelas da venda
      final parcelas = await db.query(
        'parcela',
        where: 'cd_venda = ?',
        whereArgs: [cdVenda],
        orderBy: 'numero_parcela',
      );
      
      // Calcular total
      double total = 0;
      for (final item in itens) {
        total += (item['quantidade'] as int) * (item['valor_unitario'] as double);
      }
      
      listaVendas.add(VendaModel(
        cd_venda: cdVenda,
        cd_cliente: vendaMap['cd_cliente'] as int,
        clienteNome: vendaMap['cliente_nome'] as String,
        data_venda: DateFormat('yyyy-MM-dd').parse(vendaMap['data_venda'] as String),
        forma_pagamento: vendaMap['forma_pagamento'] as String,
        data_pagamento: vendaMap['data_pagamento'] != null 
            ? DateFormat('yyyy-MM-dd').parse(vendaMap['data_pagamento'] as String) 
            : null,
        entrada: vendaMap['entrada'] as double,
        total: total,
        itens: itens.map((e) => ItemVendaModel.fromMap(e)).toList(),
        parcelas: parcelas.map((e) => ParcelaModel.fromMap(e)).toList(),
      ));
    }
    
    return listaVendas;
  }

  Future<void> registrarPagamentoParcela(int cdParcela, DateTime dataPagamento) async {
    final db = await _dbService.database;
    await db.update(
      'parcela',
      {
        'data_pagamento': DateFormat('yyyy-MM-dd').format(dataPagamento),
        'pago': 1,
      },
      where: 'cd_parcela = ?',
      whereArgs: [cdParcela],
    );
  }
}