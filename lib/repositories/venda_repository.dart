import 'package:cadastro_vendas_flutter/models/item_venda_model.dart';
import 'package:cadastro_vendas_flutter/models/parcela_model.dart';
import 'package:cadastro_vendas_flutter/models/venda_model.dart';
import 'package:cadastro_vendas_flutter/repositories/database_repository.dart';
import 'package:intl/intl.dart';

class VendaRepository {
  final _dbService = DataBaseRepository();

  Future<int> insertVenda(VendaModel venda) async {
    final db = await _dbService.database;
    
    return await db.transaction<int>((txn) async {
      // Inserir venda principal
      final cdVenda = await txn.insert('venda', {
        ...venda.toMap(),
        'cd_venda': null, // Garante que será autoincrementado
      });
      
      // Inserir itens da venda
      for (final item in venda.itens) {
        await txn.insert('item_venda', {
          'cd_venda': cdVenda,
          'cd_produto': item.cd_produto,
          'quantidade': item.quantidade,
          'valor_unitario': item.valor_unitario,
        });
      }
      
      // Inserir parcelas
      for (final parcela in venda.parcelas) {
        await txn.insert('parcela', {
          ...parcela.toMap(),
          'cd_venda': cdVenda,
          'cd_parcela': null, // Garante que será autoincrementado
        });
      }
      
      return cdVenda;
    });
  }

  Future<List<Map<String, dynamic>>> listarVendasBase() async {
    final db = await _dbService.database;
    return await db.rawQuery('''
      SELECT v.*, c.nome as cliente_nome 
      FROM venda v
      JOIN cliente c ON v.cd_cliente = c.cd_cliente
      ORDER BY v.data_venda DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> listarItensVenda(int cdVenda) async {
    final db = await _dbService.database;
    return await db.rawQuery('''
      SELECT iv.*, p.*
      FROM item_venda iv
      JOIN produto p ON iv.cd_produto = p.cd_produto
      WHERE iv.cd_venda = ?
    ''', [cdVenda]);
  }

  Future<List<Map<String, dynamic>>> listarParcelasVenda(int cdVenda) async {
    final db = await _dbService.database;
    return await db.query(
      'parcela',
      where: 'cd_venda = ?',
      whereArgs: [cdVenda],
      orderBy: 'numero_parcela',
    );
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