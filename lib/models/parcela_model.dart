import 'package:intl/intl.dart';

class ParcelaModel {
  final int? cd_parcela;
  final int cd_venda;
  final int numero_parcela;
  final double valor_parcela;
  final DateTime data_vencimento;
  final DateTime? data_pagamento;
  final bool pago;

  ParcelaModel({
    this.cd_parcela,
    required this.cd_venda,
    required this.numero_parcela,
    required this.valor_parcela,
    required this.data_vencimento,
    this.data_pagamento,
    required this.pago,
  });

  Map<String, dynamic> toMap() {
    return {
      'cd_parcela': cd_parcela,
      'cd_venda': cd_venda,
      'numero_parcela': numero_parcela,
      'valor_parcela': valor_parcela,
      'data_vencimento': DateFormat('yyyy-MM-dd').format(data_vencimento),
      'data_pagamento': data_pagamento != null 
          ? DateFormat('yyyy-MM-dd').format(data_pagamento!) 
          : null,
      'pago': pago ? 1 : 0,
    };
  }

  factory ParcelaModel.fromMap(Map<String, dynamic> map) {
    return ParcelaModel(
      cd_parcela: map['cd_parcela'],
      cd_venda: map['cd_venda'],
      numero_parcela: map['numero_parcela'],
      valor_parcela: map['valor_parcela'],
      data_vencimento: DateFormat('yyyy-MM-dd').parse(map['data_vencimento']),
      data_pagamento: map['data_pagamento'] != null 
          ? DateFormat('yyyy-MM-dd').parse(map['data_pagamento']) 
          : null,
      pago: map['pago'] == 1,
    );
  }
}