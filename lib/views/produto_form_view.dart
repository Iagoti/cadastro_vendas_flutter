import 'package:cadastro_vendas_flutter/repositories/produto_repository.dart';
import 'package:cadastro_vendas_flutter/services/produto_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../controllers/produto_controller.dart';
import '../../models/produto_model.dart';

class ProdutoFormView extends StatefulWidget {
  final ProdutoModel? produto;

  const ProdutoFormView({super.key, this.produto});

  @override
  _ProdutoFormViewState createState() => _ProdutoFormViewState();
}

class _ProdutoFormViewState extends State<ProdutoFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _valorCompraController = TextEditingController();
  final _valorVendaController = TextEditingController();
  final _quantidadeController = TextEditingController(text: '1');
  final _tamanhoController = TextEditingController();
  final _produtoController = ProdutoController(ProdutoService(ProdutoRepository()));
  
  DateTime _dataCompra = DateTime.now();
  String? _cidadeCompra;
  bool _isLoading = false;

  final List<String> _cidades = ['Selecione a cidade', 'SP', 'GO'];

  @override
  void initState() {
    super.initState();
    if (widget.produto != null) {
      _nomeController.text = widget.produto!.nome;
      _dataCompra = DateFormat('yyyy-MM-dd').parse(widget.produto!.dataCompra);
      _valorCompraController.text = widget.produto!.valorCompra.toString();
      _valorVendaController.text = widget.produto!.valorVenda.toString();
      _quantidadeController.text = widget.produto!.quantidade.toString();
      _cidadeCompra = widget.produto!.cidadeCompra;
      _tamanhoController.text = widget.produto!.tamanho;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _valorCompraController.dispose();
    _valorVendaController.dispose();
    _quantidadeController.dispose();
    _tamanhoController.dispose();
    super.dispose();
  }

  Future<void> _salvarProduto() async {
    if (!_formKey.currentState!.validate()) return;
    if (_cidadeCompra == null || _cidadeCompra == 'Selecione a cidade') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma cidade válida')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final produto = ProdutoModel(
        cd_produto: widget.produto?.cd_produto,
        nome: _nomeController.text,
        dataCompra: DateFormat('yyyy-MM-dd').format(_dataCompra),
        valorCompra: double.parse(_valorCompraController.text),
        valorVenda: double.parse(_valorVendaController.text),
        quantidade: int.parse(_quantidadeController.text),
        cidadeCompra: _cidadeCompra!,
        tamanho: _tamanhoController.text,
      );

      await _produtoController.salvarProduto(produto);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar produto: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.produto == null ? 'Novo Produto' : 'Editar Produto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _salvarProduto,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Produto',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o nome do produto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final data = await showDatePicker(
                    context: context,
                    initialDate: _dataCompra,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (data != null) {
                    setState(() => _dataCompra = data);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data da Compra',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(DateFormat('dd/MM/yyyy').format(_dataCompra)),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _cidadeCompra ?? 'Selecione a cidade',
                items: _cidades.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _cidadeCompra = newValue == 'Selecione a cidade' ? null : newValue;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Cidade da Compra',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value == 'Selecione a cidade') {
                    return 'Selecione uma cidade';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valorCompraController,
                decoration: const InputDecoration(
                  labelText: 'Valor de Compra',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o valor de compra';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Informe um valor válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valorVendaController,
                decoration: const InputDecoration(
                  labelText: 'Valor de Venda',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o valor de venda';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Informe um valor válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantidadeController,
                decoration: const InputDecoration(
                  labelText: 'Quantidade',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a quantidade';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Informe um número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tamanhoController,
                decoration: const InputDecoration(
                  labelText: 'Tamanho',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o tamanho';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (_isLoading) const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}