import 'package:cadastro_vendas_flutter/models/produto_model.dart';

class ItemVendaModel {
  int cd_venda;
  int cd_produto;
  ProdutoModel produto;
  int quantidade;
  double valor_unitario;

  ItemVendaModel({
    required this.cd_venda,
    required this.cd_produto,
    required this.produto,
    required this.quantidade,
    required this.valor_unitario,
  });

  factory ItemVendaModel.fromMap(Map<String, dynamic> json) {
    return ItemVendaModel(
      cd_venda: json['cd_venda'],
      cd_produto: json['cd_produto'],
      produto: ProdutoModel.fromMap(json['produto']),
      quantidade: json['quantidade'],
      valor_unitario: json['valor_unitario'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cd_venda': cd_venda,
      'cd_produto': cd_produto,
      'produto': produto.toMap(),
      'quantidade': quantidade,
      'valor_unitario': valor_unitario,
    };
  }
}