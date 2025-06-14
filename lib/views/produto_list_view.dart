import 'package:cadastro_vendas_flutter/repositories/produto_repository.dart';
import 'package:cadastro_vendas_flutter/services/produto_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../controllers/produto_controller.dart';
import '../../models/produto_model.dart';
import 'produto_form_view.dart';

class ProdutoListView extends StatefulWidget {
  const ProdutoListView({super.key});

  @override
  _ProdutoListViewState createState() => _ProdutoListViewState();
}

class _ProdutoListViewState extends State<ProdutoListView> {
  final _produtoController = ProdutoController(ProdutoService(ProdutoRepository()));
  final _searchController = TextEditingController();
  List<ProdutoModel> _produtos = [];
  List<ProdutoModel> _filteredProdutos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
    _searchController.addListener(_filtrarProdutos);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _carregarProdutos() async {
    setState(() => _isLoading = true);
    try {
      _produtos = await _produtoController.listarProdutos();
      _filteredProdutos = _produtos;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filtrarProdutos() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProdutos = _produtos.where((produto) {
        return produto.nome.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _excluirProduto(int cdProduto) async {
    try {
      await _produtoController.excluirProduto(cdProduto);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto excluído com sucesso')),
        );
        await _carregarProdutos();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir produto: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProdutoFormView(),
                ),
              );
              await _carregarProdutos();
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
                labelText: 'Pesquisar produto',
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
                : _filteredProdutos.isEmpty
                    ? const Center(child: Text('Nenhum produto encontrado'))
                    : ListView.builder(
                        itemCount: _filteredProdutos.length,
                        itemBuilder: (context, index) {
                          final produto = _filteredProdutos[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                            child: ListTile(
                              title: Text(produto.nome),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Compra: ${DateFormat('dd/MM/yyyy').format(DateFormat('yyyy-MM-dd').parse(produto.dataCompra))}'),
                                  Text('Valor: ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(produto.valorVenda)}'),
                                  Text('Quantidade: ${produto.quantidade}'),
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
                                          builder: (context) => ProdutoFormView(produto: produto),
                                        ),
                                      );
                                      await _carregarProdutos();
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Confirmar exclusão'),
                                          content: const Text('Deseja realmente excluir este produto?'),
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
                                        await _excluirProduto(produto.cd_produto!);
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