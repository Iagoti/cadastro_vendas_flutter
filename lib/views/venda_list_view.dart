import 'package:cadastro_vendas_flutter/models/venda_model.dart';
import 'package:cadastro_vendas_flutter/repositories/venda_repository.dart';
import 'package:cadastro_vendas_flutter/services/venda_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../controllers/venda_controller.dart';

class VendaListView extends StatefulWidget {
  const VendaListView({super.key});

  @override
  _VendaListViewState createState() => _VendaListViewState();
}

class _VendaListViewState extends State<VendaListView> {
  final _vendaController = VendaController(VendaService(VendaRepository()));
  final _searchController = TextEditingController();
  List<VendaModel> _vendas = [];
  List<VendaModel> _filteredVendas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarVendas();
    _searchController.addListener(_filtrarVendas);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _carregarVendas() async {
    setState(() => _isLoading = true);
    try {
      _vendas = await _vendaController.listarVendas();
      _filteredVendas = _vendas;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filtrarVendas() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredVendas = _vendas.where((venda) {
        return venda.clienteNome.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Vendas'),
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
                : _filteredVendas.isEmpty
                    ? const Center(child: Text('Nenhuma venda encontrada'))
                    : ListView.builder(
                        itemCount: _filteredVendas.length,
                        itemBuilder: (context, index) {
                          final venda = _filteredVendas[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                            child: ListTile(
                              title: Text(venda.clienteNome),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(DateFormat('dd/MM/yyyy').format(venda.data_venda)),
                                  Text('Total: ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(venda.total)}'),
                                ],
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                // Navegar para detalhes da venda
                              },
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