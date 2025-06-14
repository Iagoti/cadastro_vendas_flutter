import 'package:intl/intl.dart';
import 'package:cadastro_vendas_flutter/models/item_venda_model.dart';
import 'package:cadastro_vendas_flutter/models/parcela_model.dart';

class VendaModel {
  final int? cd_venda;
  final int cd_cliente;
  final String clienteNome;
  final DateTime data_venda;
  final String forma_pagamento;
  final DateTime? data_pagamento;
  final double entrada;
  final double total;
  final List<ItemVendaModel> itens;
  final List<ParcelaModel> parcelas;

  VendaModel({
    this.cd_venda,
    required this.cd_cliente,
    required this.clienteNome,
    required this.data_venda,
    required this.forma_pagamento,
    this.data_pagamento,
    required this.entrada,
    required this.total,
    required this.itens,
    required this.parcelas,
  });

  Map<String, dynamic> toMap() {
    return {
      'cd_venda': cd_venda,
      'cd_cliente': cd_cliente,
      'data_venda': DateFormat('yyyy-MM-dd').format(data_venda),
      'forma_pagamento': forma_pagamento,
      'data_pagamento': data_pagamento != null 
          ? DateFormat('yyyy-MM-dd').format(data_pagamento!) 
          : null,
      'entrada': entrada,
    };
  }
}