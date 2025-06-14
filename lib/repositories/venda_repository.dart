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

  Future<List<Map<String, dynamic>>> listarVendasCompletas() async {
    final db = await _dbService.database;
    
    final query = '''
      SELECT 
        v.cd_venda,
        v.data_venda,
        v.forma_pagamento,
        v.entrada,
        v.total,
        v.quantidade_parcelas,
        
        -- Dados do cliente
        c.cd_cliente,
        c.nome as cliente_nome,
        
        -- Itens da venda
        iv.cd_produto,
        iv.quantidade as item_quantidade,
        iv.valor_unitario,
        
        -- Dados do produto
        p.nome as produto_nome,
        p.valor_venda,
        p.tamanho,
        
        -- Parcelas
        parc.cd_parcela,
        parc.numero_parcela,
        parc.valor_parcela,
        parc.data_vencimento,
        parc.data_pagamento,
        parc.pago
      FROM venda v
      JOIN cliente c ON v.cd_cliente = c.cd_cliente
      LEFT JOIN item_venda iv ON v.cd_venda = iv.cd_venda
      LEFT JOIN produto p ON iv.cd_produto = p.cd_produto
      LEFT JOIN parcela parc ON v.cd_venda = parc.cd_venda
      ORDER BY v.data_venda DESC, parc.numero_parcela ASC
    ''';
    
    return await db.rawQuery(query);
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