import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DataBaseRepository {
  static Database? _db;

  Future<Database> get database async {
    return _db ??= await initDataBase();
  }

  Future<Database> initDataBase() async {
    final path = join(await getDatabasesPath(), 'vendas.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> recreateDatabase() async {
    final db = await database;
    await db.close(); // Fecha a conexão atual
    _db = null; // Reseta a instância do banco de dados
    
    // Deleta o arquivo do banco de dados existente
    final path = join(await getDatabasesPath(), 'vendas.db');
    await deleteDatabase(path);
    
    // Recria o banco de dados chamando initDataBase novamente
    await initDataBase();
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuario (
        cd_usuario INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        password TEXT NOT NULL
      )
    ''');
    
    await db.insert(
      'usuario',
      {
        'username': 'admin',
        'password': 'admin', 
      },
    );
    
    await db.execute('''
      CREATE TABLE produto (
        cd_produto INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        valor REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE cliente (
        cd_cliente INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        telefone TEXT NOT NULL,
        cpf TEXT NOT NULL,
        UNIQUE(cpf)
      )
    ''');
    
    await db.execute('''
      CREATE TABLE venda (
        cd_venda INTEGER PRIMARY KEY AUTOINCREMENT,
        cd_cliente INTEGER NOT NULL,
        data_venda TEXT NOT NULL,
        forma_pagamento TEXT NOT NULL,
        data_pagamento TEXT,
        entrada REAL DEFAULT 0,
        FOREIGN KEY (cd_cliente) REFERENCES cliente (cd_cliente)
      )
    ''');
    
    await db.execute('''
      CREATE TABLE item_venda (
        cd_item_venda INTEGER PRIMARY KEY AUTOINCREMENT,
        cd_venda INTEGER NOT NULL,
        cd_produto INTEGER NOT NULL,
        quantidade INTEGER NOT NULL,
        valor_unitario REAL NOT NULL,
        FOREIGN KEY (cd_venda) REFERENCES venda (cd_venda),
        FOREIGN KEY (cd_produto) REFERENCES produto (cd_produto)
      )
    ''');
    
    await db.execute('''
      CREATE TABLE parcela (
        cd_parcela INTEGER PRIMARY KEY AUTOINCREMENT,
        cd_venda INTEGER NOT NULL,
        numero_parcela INTEGER NOT NULL,
        valor_parcela REAL NOT NULL,
        data_vencimento TEXT NOT NULL,
        data_pagamento TEXT,
        pago INTEGER DEFAULT 0,
        FOREIGN KEY (cd_venda) REFERENCES venda (cd_venda)
      )
    ''');
  }
}