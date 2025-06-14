import 'package:cadastro_vendas_flutter/models/produto_model.dart';
import 'package:cadastro_vendas_flutter/repositories/cliente_repository.dart';
import 'package:cadastro_vendas_flutter/repositories/produto_repository.dart';
import 'package:cadastro_vendas_flutter/repositories/venda_repository.dart';
import 'package:cadastro_vendas_flutter/services/cliente_service.dart';
import 'package:cadastro_vendas_flutter/services/produto_service.dart';
import 'package:cadastro_vendas_flutter/services/venda_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/venda_model.dart';
import '../../models/item_venda_model.dart';
import '../../models/parcela_model.dart';
import '../../controllers/venda_controller.dart';
import '../../controllers/produto_controller.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../controllers/cliente_controller.dart';
import '../../controllers/produto_controller.dart';
import '../../controllers/venda_controller.dart';
import '../../models/cliente_model.dart';
import '../../models/item_venda_model.dart';
import '../../models/parcela_model.dart';
import '../../models/venda_model.dart';

class VendaCreateView extends StatefulWidget {
  const VendaCreateView({super.key});

  @override
  _VendaCreateViewState createState() => _VendaCreateViewState();
}

class _VendaCreateViewState extends State<VendaCreateView> {
  final _formKey = GlobalKey<FormState>();
  final _vendaController = VendaController(VendaService(VendaRepository()));
  final _produtoController = ProdutoController(ProdutoService(ProdutoRepository()));
  final _clienteController = ClienteController(ClienteService(ClienteRepository()));
  
  final _clienteTextController = TextEditingController();
  final _formaPagamentoController = TextEditingController();
  final _entradaController = TextEditingController(text: '0');
  final _parcelasController = TextEditingController(text: '1');

  final FocusNode _clienteFocusNode = FocusNode();
  
  DateTime _dataVenda = DateTime.now();
  DateTime? _dataPagamento;
  
  List<ItemVendaModel> _itens = [];
  List<ParcelaModel> _parcelas = [];
  double _total = 0;
  ClienteModel? _clienteSelecionado;

  @override
  void initState() {
    super.initState();
    _clienteTextController.addListener(_atualizarClienteSelecionado);
  }

  @override
  void dispose() {
    _clienteFocusNode.dispose();
    _clienteTextController.removeListener(_atualizarClienteSelecionado);
    _clienteTextController.dispose();
    _formaPagamentoController.dispose();
    _entradaController.dispose();
    _parcelasController.dispose();
    super.dispose();
  }

  void _atualizarClienteSelecionado() {
    if (_clienteSelecionado != null && 
        _clienteTextController.text != _clienteSelecionado!.nome) {
      setState(() {
        _clienteSelecionado = null;
      });
    }
  }

  Future<List<ClienteModel>> _buscarClientes(String query) async {
    if (query.isEmpty) {
      return [];
    }
    return await _clienteController.buscarClientesPorNome(query);
  }

  Future<void> _adicionarProduto() async {
    final produto = await showDialog<ItemVendaModel>(
      context: context,
      builder: (context) => const AdicionarProdutoDialog(),
    );
    
    if (produto != null) {
      setState(() {
        _itens.add(produto);
        _calcularTotal();
      });
    }
  }
  
  void _calcularTotal() {
    double total = 0;
    for (final item in _itens) {
      total += item.quantidade * item.valor_unitario;
    }
    setState(() => _total = total);
    _calcularParcelas();
  }
  
  void _calcularParcelas() {
    final entrada = double.tryParse(_entradaController.text) ?? 0;
    final parcelas = int.tryParse(_parcelasController.text) ?? 1;
    final valorParcela = (_total - entrada) / parcelas;
    
    final hoje = DateTime.now();
    final novasParcelas = <ParcelaModel>[];
    
    for (int i = 1; i <= parcelas; i++) {
      final vencimento = DateTime(hoje.year, hoje.month + i, hoje.day);
      novasParcelas.add(ParcelaModel(
        cd_venda: 0,
        numero_parcela: i,
        valor_parcela: valorParcela,
        data_vencimento: vencimento,
        pago: false,
      ));
    }
    
    setState(() => _parcelas = novasParcelas);
  }
  
  Future<void> _salvarVenda() async {
    if (!_formKey.currentState!.validate()) return;
    if (_itens.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos um produto')),
      );
      return;
    }
    
    if (_clienteSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um cliente válido')),
      );
      return;
    }
    
    final venda = VendaModel(
      cd_cliente: _clienteSelecionado!.cd_cliente!,
      clienteNome: _clienteSelecionado!.nome,
      data_venda: _dataVenda,
      forma_pagamento: _formaPagamentoController.text,
      data_pagamento: _dataPagamento,
      entrada: double.tryParse(_entradaController.text) ?? 0,
      total: _total,
      itens: _itens,
      parcelas: _parcelas,
    );
    
    try {
      await _vendaController.cadastrarVenda(venda);
      
      final continuar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Venda salva com sucesso!'),
          content: const Text('Deseja realizar outra venda?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Não'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sim'),
            ),
          ],
        ),
      );
      
      if (continuar == true) {
        setState(() {
          _clienteTextController.clear();
          _clienteSelecionado = null;
          _formaPagamentoController.clear();
          _entradaController.text = '0';
          _parcelasController.text = '1';
          _dataVenda = DateTime.now();
          _dataPagamento = null;
          _itens.clear();
          _parcelas.clear();
          _total = 0;
        });
      } else {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/vendas');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar venda: $e')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Venda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _salvarVenda,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RawAutocomplete<ClienteModel>(
                textEditingController: _clienteTextController,
                focusNode: _clienteFocusNode,
                optionsBuilder: (TextEditingValue textEditingValue) {
                  return _buscarClientes(textEditingValue.text);
                },
                displayStringForOption: (option) => option.nome,
                fieldViewBuilder: (
                  BuildContext context,
                  TextEditingController textEditingController,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted,
                ) {
                  return TextFormField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Cliente',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty || _clienteSelecionado == null) {
                        return 'Selecione um cliente válido';
                      }
                      return null;
                    },
                  );
                },
                optionsViewBuilder: (
                  BuildContext context,
                  AutocompleteOnSelected<ClienteModel> onSelected,
                  Iterable<ClienteModel> options,
                ) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4.0,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 32,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final cliente = options.elementAt(index);
                            return ListTile(
                              title: Text(cliente.nome),
                              subtitle: Text(cliente.telefone),
                              onTap: () {
                                onSelected(cliente);
                                setState(() {
                                  _clienteSelecionado = cliente;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
                onSelected: (ClienteModel cliente) {
                  setState(() {
                    _clienteSelecionado = cliente;
                  });
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final data = await showDatePicker(
                    context: context,
                    initialDate: _dataVenda,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (data != null) {
                    setState(() => _dataVenda = data);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data da Venda',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(DateFormat('dd/MM/yyyy').format(_dataVenda)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _formaPagamentoController,
                decoration: const InputDecoration(
                  labelText: 'Forma de Pagamento',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a forma de pagamento';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _entradaController,
                      decoration: const InputDecoration(
                        labelText: 'Entrada (R\$)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calcularParcelas(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _parcelasController,
                      decoration: const InputDecoration(
                        labelText: 'Parcelas',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calcularParcelas(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Produtos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _adicionarProduto,
                child: const Text('Adicionar Produto'),
              ),
              const SizedBox(height: 16),
              if (_itens.isNotEmpty) ...[
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _itens.length,
                  itemBuilder: (context, index) {
                    final item = _itens[index];
                    return ListTile(
                      title: Text(item.produtoNome),
                      subtitle: Text('${item.quantidade} x ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(item.valor_unitario)}'),
                      trailing: Text(NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(item.quantidade * item.valor_unitario)),
                      onLongPress: () {
                        setState(() {
                          _itens.removeAt(index);
                          _calcularTotal();
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Total: ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(_total)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.end,
                ),
              ],
              const SizedBox(height: 24),
              if (_parcelas.isNotEmpty) ...[
                const Text(
                  'Parcelas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _parcelas.length,
                  itemBuilder: (context, index) {
                    final parcela = _parcelas[index];
                    return ListTile(
                      title: Text('Parcela ${parcela.numero_parcela}'),
                      subtitle: Text(DateFormat('dd/MM/yyyy').format(parcela.data_vencimento)),
                      trailing: Text(NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(parcela.valor_parcela)),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AdicionarProdutoDialog extends StatefulWidget {
  const AdicionarProdutoDialog({super.key});

  @override
  _AdicionarProdutoDialogState createState() => _AdicionarProdutoDialogState();
}

class _AdicionarProdutoDialogState extends State<AdicionarProdutoDialog> {
  late TextEditingController _produtoController;
  final _quantidadeController = TextEditingController(text: '1');
  final _valorController = TextEditingController();
  final _produtoControllerInstance = ProdutoController(ProdutoService(ProdutoRepository()));
  List<ProdutoModel> _produtos = [];
  ProdutoModel? _produtoSelecionado;
  String? _produtoNome;
  double? _produtoValor;

  @override
  void initState() {
    super.initState();
    _produtoController = TextEditingController();
    _carregarProdutos();
  }

  @override
  void dispose() {
    _produtoController.dispose();
    _quantidadeController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _carregarProdutos() async {
    _produtos = await _produtoControllerInstance.listarProdutos();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Produto'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Autocomplete<ProdutoModel>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                return _produtos.where((produto) => 
                  produto.nome.toLowerCase().contains(textEditingValue.text.toLowerCase()));
              },
              displayStringForOption: (option) => option.nome,
              onSelected: (produto) {
                setState(() {
                  _produtoSelecionado = produto;
                  _produtoNome = produto.nome;
                  _produtoValor = produto.valorVenda;
                  _valorController.text = produto.valorVenda.toString();
                });
              },
              fieldViewBuilder: (
                context, 
                controller, 
                focusNode, 
                onFieldSubmitted
              ) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Produto',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _produtoNome = value;
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _quantidadeController,
              decoration: const InputDecoration(
                labelText: 'Quantidade',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _valorController,
              decoration: const InputDecoration(
                labelText: 'Valor Unitário',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _produtoValor = double.tryParse(value);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final quantidade = int.tryParse(_quantidadeController.text) ?? 1;
            final valor = _produtoValor ?? double.tryParse(_valorController.text) ?? 0;
            
            if (_produtoNome == null || _produtoNome!.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Selecione ou digite um nome para o produto')),
              );
              return;
            }

            if (valor <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Informe um valor válido para o produto')),
              );
              return;
            }

            Navigator.pop(context, ItemVendaModel(
              cd_venda: 0,
              cd_produto: _produtoSelecionado?.cd_produto ?? 0,
              produtoNome: _produtoNome!,
              quantidade: quantidade,
              valor_unitario: valor,
            ));
          },
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}