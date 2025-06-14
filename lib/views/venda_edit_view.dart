import 'package:cadastro_vendas_flutter/models/item_venda_model.dart';
import 'package:cadastro_vendas_flutter/models/parcela_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/venda_model.dart';
import '../../controllers/venda_controller.dart';

class VendaEditView extends StatefulWidget {
  final VendaModel venda;
  final VendaController vendaController;

  const VendaEditView({
    super.key,
    required this.venda,
    required this.vendaController,
  });

  @override
  _VendaEditViewState createState() => _VendaEditViewState();
}

class _VendaEditViewState extends State<VendaEditView> with SingleTickerProviderStateMixin {
  late VendaModel _vendaEditada;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _vendaEditada = widget.venda.copyWith();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _adicionarProduto() async {
    // Implemente a lógica para adicionar produto
    // Pode ser um dialog ou navegação para tela de produtos
  }

  Future<void> _removerProduto(ItemVendaModel item) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Produto'),
        content: const Text('Deseja realmente remover este produto da venda?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      setState(() {
        _vendaEditada.itens.remove(item);
        _atualizarTotal();
      });
    }
  }

  void _atualizarTotal() {
    double total = 0;
    for (final item in _vendaEditada.itens) {
      total += item.quantidade * item.valor_unitario;
    }
    setState(() {
      _vendaEditada = _vendaEditada.copyWith(total: total);
    });
  }

  Future<void> _marcarParcelaComoPaga(ParcelaModel parcela) async {
    final dataPagamento = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (dataPagamento != null) {
      setState(() {
        final index = _vendaEditada.parcelas.indexOf(parcela);
        _vendaEditada.parcelas[index] = parcela.copyWith(
          pago: true,
          data_pagamento: dataPagamento,
        );
      });

      // Atualiza no banco de dados
      await widget.vendaController.registrarPagamentoParcela(
        parcela.cd_parcela!,
        dataPagamento,
      );
    }
  }

  Future<void> _salvarAlteracoes() async {
    try {
      await widget.vendaController.atualizarVenda(_vendaEditada);
      if (mounted) {
        Navigator.pop(context, true); // Retorna true indicando sucesso
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar alterações: $e'),
            behavior: SnackBarBehavior.fixed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Venda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _salvarAlteracoes,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) => setState(() {}),
          tabs: const [
            Tab(text: 'Produtos'),
            Tab(text: 'Parcelas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Aba de Produtos
          _buildListaProdutos(),
          // Aba de Parcelas
          _buildListaParcelas(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _adicionarProduto,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildListaProdutos() {
    return ListView.builder(
      itemCount: _vendaEditada.itens.length,
      itemBuilder: (context, index) {
        final item = _vendaEditada.itens[index];
        return ListTile(
          title: Text(item.produto.nome),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${item.quantidade} x ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(item.valor_unitario)}'),
              Text('Tamanho: ${item.produto.tamanho}'),
            ],
          ),
          trailing: Text(
            NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(item.quantidade * item.valor_unitario),
          ),
          onLongPress: () => _removerProduto(item),
        );
      },
    );
  }

  Widget _buildListaParcelas() {
    return ListView.builder(
      itemCount: _vendaEditada.parcelas.length,
      itemBuilder: (context, index) {
        final parcela = _vendaEditada.parcelas[index];
        return ListTile(
          title: Text('Parcela ${parcela.numero_parcela}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(DateFormat('dd/MM/yyyy').format(parcela.data_vencimento)),
              if (parcela.pago && parcela.data_pagamento != null)
                Text('Pago em ${DateFormat('dd/MM/yyyy').format(parcela.data_pagamento!)}'),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(parcela.valor_parcela),
                style: TextStyle(
                  color: parcela.pago ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!parcela.pago)
                TextButton(
                  onPressed: () => _marcarParcelaComoPaga(parcela),
                  child: const Text('Marcar como paga'),
                ),
            ],
          ),
        );
      },
    );
  }
}