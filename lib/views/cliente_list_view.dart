import 'package:cadastro_vendas_flutter/repositories/cliente_repository.dart';
import 'package:cadastro_vendas_flutter/services/cliente_service.dart';
import 'package:flutter/material.dart';
import '../../controllers/cliente_controller.dart';
import '../../models/cliente_model.dart';
import 'cliente_form_view.dart';

class ClienteListView extends StatefulWidget {
  const ClienteListView({super.key});

  @override
  _ClienteListViewState createState() => _ClienteListViewState();
}

class _ClienteListViewState extends State<ClienteListView> {
  final _clienteController = ClienteController(ClienteService(ClienteRepository()));
  final _searchController = TextEditingController();
  List<ClienteModel> _clientes = [];
  List<ClienteModel> _filteredClientes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarClientes();
    _searchController.addListener(_filtrarClientes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _carregarClientes() async {
    setState(() => _isLoading = true);
    try {
      _clientes = await _clienteController.listarClientes();
      _filteredClientes = _clientes;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filtrarClientes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredClientes = _clientes.where((cliente) {
        return cliente.nome.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _excluirCliente(int cdCliente) async {
    try {
      await _clienteController.excluirCliente(cdCliente);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente excluído com sucesso')),
        );
        await _carregarClientes();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir cliente: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ClienteFormView(),
                ),
              );
              await _carregarClientes();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Pesquisar cliente',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredClientes.isEmpty
                    ? const Center(child: Text('Nenhum cliente encontrado'))
                    : ListView.builder(
                        itemCount: _filteredClientes.length,
                        itemBuilder: (context, index) {
                          final cliente = _filteredClientes[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                            child: ListTile(
                              title: Text(cliente.nome),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(cliente.telefone),
                                  Text(cliente.cpf),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ClienteFormView(cliente: cliente),
                                        ),
                                      );
                                      await _carregarClientes();
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Confirmar exclusão'),
                                          content: const Text('Deseja realmente excluir este cliente?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: const Text('Cancelar'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              child: const Text('Excluir'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await _excluirCliente(cliente.cd_cliente!);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}