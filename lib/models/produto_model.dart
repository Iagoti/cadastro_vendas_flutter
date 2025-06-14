class ProdutoModel {
  final int? cd_produto;
  final String nome;
  final double valor;

  ProdutoModel({
    this.cd_produto,
    required this.nome,
    required this.valor,
  });

  Map<String, dynamic> toMap() {
    return {
      'cd_produto': cd_produto,
      'nome': nome,
      'valor': valor,
    };
  }

  factory ProdutoModel.fromMap(Map<String, dynamic> map) {
    return ProdutoModel(
      cd_produto: map['cd_produto'] as int?,
      nome: map['nome'] as String,
      valor: map['valor'] as double,
    );
  }
}