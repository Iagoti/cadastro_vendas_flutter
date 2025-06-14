class ItemVendaModel {
  final int? cd_item_venda;
  final int cd_venda;
  final int cd_produto;
  final String produtoNome;
  final int quantidade;
  final double valor_unitario;

  ItemVendaModel({
    this.cd_item_venda,
    required this.cd_venda,
    required this.cd_produto,
    required this.produtoNome,
    required this.quantidade,
    required this.valor_unitario,
  });

  Map<String, dynamic> toMap() {
    return {
      'cd_item_venda': cd_item_venda,
      'cd_venda': cd_venda,
      'cd_produto': cd_produto,
      'quantidade': quantidade,
      'valor_unitario': valor_unitario,
    };
  }

  factory ItemVendaModel.fromMap(Map<String, dynamic> map) {
  return ItemVendaModel(
    cd_item_venda: map['cd_item_venda'],
    cd_venda: map['cd_venda'],
    cd_produto: map['cd_produto'],
    produtoNome: map['produto_nome'] ?? '', // ajustar nome da chave conforme o banco/uso
    quantidade: map['quantidade'],
    valor_unitario: map['valor_unitario'] is int
        ? (map['valor_unitario'] as int).toDouble()
        : map['valor_unitario'],
  );
}

}