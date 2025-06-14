import 'package:intl/intl.dart';
import 'package:cadastro_vendas_flutter/models/item_venda_model.dart';
import 'package:cadastro_vendas_flutter/models/parcela_model.dart';

class VendaModel {
  final int? cd_venda;
  final int cd_cliente;
  final String clienteNome;
  final DateTime data_venda;
  final String forma_pagamento;
  final double entrada;
  final double total;
  final int quantidade_parcelas;
  final List<ItemVendaModel> itens;
  final List<ParcelaModel> parcelas;

  VendaModel({
    this.cd_venda,
    required this.cd_cliente,
    required this.clienteNome,
    required this.data_venda,
    required this.forma_pagamento,
    required this.entrada,
    required this.total,
    required this.quantidade_parcelas,
    required this.itens,
    required this.parcelas,
  });

  Map<String, dynamic> toMap() {
    return {
      'cd_venda': cd_venda,
      'cd_cliente': cd_cliente,
      'data_venda': DateFormat('yyyy-MM-dd').format(data_venda),
      'forma_pagamento': forma_pagamento,
      'entrada': entrada,
      'total': total,
      'quantidade_parcelas': quantidade_parcelas,
    };
  }

  factory VendaModel.fromMap(Map<String, dynamic> map, {
    required List<ItemVendaModel> itens,
    required List<ParcelaModel> parcelas,
    required String clienteNome,
  }) {
    return VendaModel(
      cd_venda: map['cd_venda'],
      cd_cliente: map['cd_cliente'],
      clienteNome: clienteNome,
      data_venda: DateFormat('yyyy-MM-dd').parse(map['data_venda']),
      forma_pagamento: map['forma_pagamento'],
      entrada: map['entrada'],
      total: map['total'],
      quantidade_parcelas: map['quantidade_parcelas'],
      itens: itens,
      parcelas: parcelas,
    );
  }

  VendaModel copyWith({
    List<ItemVendaModel>? itens,
    List<ParcelaModel>? parcelas,
  }) {
    return VendaModel(
      cd_venda: this.cd_venda,
      cd_cliente: this.cd_cliente,
      clienteNome: this.clienteNome,
      data_venda: this.data_venda,
      forma_pagamento: this.forma_pagamento,
      entrada: this.entrada,
      total: this.total,
      quantidade_parcelas: this.quantidade_parcelas,
      itens: itens ?? this.itens,
      parcelas: parcelas ?? this.parcelas,
    );
  }
}