import 'package:cadastro_vendas_flutter/models/venda_model.dart';
import 'package:cadastro_vendas_flutter/repositories/venda_repository.dart';
import 'package:cadastro_vendas_flutter/services/venda_service.dart';
import 'package:cadastro_vendas_flutter/views/venda_edit_view.dart';
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
  bool _showOnlyPending = false;

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
      final vendas = await _vendaController.listarVendas();
      
      if (vendas.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nenhuma venda encontrada'),
              behavior: SnackBarBehavior.fixed,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }

      setState(() {
        _vendas = vendas;
        _filteredVendas = vendas;
      });
    } catch (e) {
      debugPrint('Erro no _carregarVendas: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar vendas: ${e.toString()}'),
            behavior: SnackBarBehavior.fixed,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filtrarVendas() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredVendas = _vendas.where((venda) {
        final matchesSearch = venda.clienteNome.toLowerCase().contains(query) ||
            venda.forma_pagamento.toLowerCase().contains(query);
        
        final matchesPendingFilter = !_showOnlyPending || 
            venda.parcelas.any((parcela) => !parcela.pago);
        
        return matchesSearch && matchesPendingFilter;
      }).toList();
    });
  }

  Widget _buildStatusIndicator(VendaModel venda) {
    final todasPagas = !venda.parcelas.any((parcela) => !parcela.pago);
    final temAtrasadas = venda.parcelas.any((parcela) => 
        !parcela.pago && parcela.data_vencimento.isBefore(DateTime.now()));

    if (todasPagas) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Pago',
          style: TextStyle(color: Colors.green, fontSize: 12),
        ),
      );
    } else if (temAtrasadas) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Atrasado',
          style: TextStyle(color: Colors.red, fontSize: 12),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Pendente',
          style: TextStyle(color: Colors.orange, fontSize: 12),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Vendas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarVendas,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Pesquisar',
                    hintText: 'Cliente ou forma de pagamento',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
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
                          final parcelasPagas = venda.parcelas.where((p) => p.pago).length;
                          final totalParcelas = venda.parcelas.length;

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                            child: InkWell(
                              onTap: () async {
                                final atualizado = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VendaEditView(
                                      venda: venda,
                                      vendaController: _vendaController,
                                    ),
                                  ),
                                );

                                if (atualizado == true) {
                                  _carregarVendas(); // Recarrega a lista se houve atualização
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          venda.clienteNome,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        _buildStatusIndicator(venda),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              DateFormat('dd/MM/yyyy').format(venda.data_venda),
                                              style: TextStyle(color: Colors.grey[600]),
                                            ),
                                            Text(
                                              venda.forma_pagamento,
                                              style: TextStyle(color: Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              NumberFormat.currency(
                                                locale: 'pt_BR', 
                                                symbol: 'R\$',
                                              ).format(venda.total),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              '$parcelasPagas/$totalParcelas parcelas',
                                              style: TextStyle(color: Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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