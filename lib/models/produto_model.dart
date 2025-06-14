class ProdutoModel {
  final int? cd_produto;
  final String nome;
  final String dataCompra;
  final double valorCompra;
  final double valorVenda;
  final int quantidade;
  final String cidadeCompra;
  final String tamanho;

  ProdutoModel({
    this.cd_produto,
    required this.nome,
    required this.dataCompra,
    required this.valorCompra,
    required this.valorVenda,
    required this.quantidade,
    required this.cidadeCompra,
    required this.tamanho,
  });

  // Construtor para listagem de vendas
  ProdutoModel.venda({
    required this.cd_produto,
    required this.nome,
    required this.valorVenda,
    required this.tamanho,
  }) : dataCompra = '',
       valorCompra = 0,
       quantidade = 0,
       cidadeCompra = '';

  Map<String, dynamic> toMap() {
    return {
      'cd_produto': cd_produto,
      'nome': nome,
      'data_compra': dataCompra,
      'valor_compra': valorCompra,
      'valor_venda': valorVenda,
      'quantidade': quantidade,
      'cidade_compra': cidadeCompra,
      'tamanho': tamanho,
    };
  }

  factory ProdutoModel.fromMap(Map<String, dynamic> map) {
    return ProdutoModel(
      cd_produto: map['cd_produto'] as int?,
      nome: map['nome'] as String,
      dataCompra: map['data_compra'] as String,
      valorCompra: map['valor_compra'] as double,
      valorVenda: map['valor_venda'] as double,
      quantidade: map['quantidade'] as int,
      cidadeCompra: map['cidade_compra'] as String,
      tamanho: map['tamanho'] as String,
    );
  }
}