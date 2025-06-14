import 'package:cadastro_vendas_flutter/repositories/database_repository.dart';
import '../models/cliente_model.dart';

class ClienteRepository {
  final _dbService = DataBaseRepository();

  Future<int> salvarCliente(ClienteModel cliente) async {
    final db = await _dbService.database;
    
    if (cliente.cd_cliente != null) {
      return await db.update(
        'cliente',
        cliente.toMap(),
        where: 'cd_cliente = ?',
        whereArgs: [cliente.cd_cliente],
      );
    } else {
      return await db.insert('cliente', cliente.toMap());
    }
  }

  Future<List<ClienteModel>> listarClientes() async {
    final db = await _dbService.database;
    final clientes = await db.query('cliente', orderBy: 'nome');
    return clientes.map((e) => ClienteModel.fromMap(e)).toList();
  }

  Future<List<ClienteModel>> buscarClientesPorNome(String nome) async {
    final db = await _dbService.database;
    final clientes = await db.query(
      'cliente',
      where: 'nome LIKE ?',
      whereArgs: ['%$nome%'],
      orderBy: 'nome',
    );
    return clientes.map((e) => ClienteModel.fromMap(e)).toList();
  }

  Future<int> excluirCliente(int cdCliente) async {
    final db = await _dbService.database;
    return await db.delete(
      'cliente',
      where: 'cd_cliente = ?',
      whereArgs: [cdCliente],
    );
  }
}