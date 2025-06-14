import 'package:cadastro_vendas_flutter/repositories/database_repository.dart';
import 'package:flutter/material.dart';

class DashboardView extends StatelessWidget {
  final String username;

  const DashboardView({super.key, required this.username});

  Future<void> _recreateDatabase(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar Reconstrução'),
        content: Text('Tem certeza que deseja reconstruir o banco de dados? Todos os dados serão perdidos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Substitua esta parte pelo seu código real de inicialização do banco de dados
        await DataBaseRepository().recreateDatabase();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Banco de dados reconstruído com sucesso!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao reconstruir banco de dados: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard - Olá, $username'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_circle, size: 50, color: Colors.blue),
                  SizedBox(height: 10),
                  Text(
                    username,
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Início'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/dashboard');
              },
            ),
            ExpansionTile(
              leading: Icon(Icons.people),
              title: Text('Clientes'),
              children: [
                ListTile(
                  leading: Icon(Icons.list),
                  title: Text('Lista de Clientes'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/lista-clientes');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.person_add),
                  title: Text('Novo Cliente'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/cliente-form');
                  },
                ),
              ],
            ),
            ExpansionTile(
              leading: Icon(Icons.point_of_sale),
              title: Text('Vendas'),
              children: [
                ListTile(
                  leading: Icon(Icons.list_alt),
                  title: Text('Lista de Vendas'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/vendas');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.add),
                  title: Text('Nova Venda'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/cadastrar-venda');
                  },
                ),
              ],
            ),
            ListTile(
                leading: Icon(Icons.build),
                title: Text('Reconstruir Banco de Dados'),
                onTap: () {
                  Navigator.pop(context);
                  _recreateDatabase(context);
                },
              ),
            Divider(),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Sair'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
          'Bem-vindo ao sistema!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
