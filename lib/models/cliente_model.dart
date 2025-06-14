class ClienteModel {
  final int? cd_cliente;
  final String nome;
  final String telefone;
  final String cpf;

  ClienteModel({
    this.cd_cliente,
    required this.nome,
    required this.telefone,
    required this.cpf,
  });

  Map<String, dynamic> toMap() {
    return {
      'cd_cliente': cd_cliente,
      'nome': nome,
      'telefone': telefone,
      'cpf': cpf,
    };
  }

  factory ClienteModel.fromMap(Map<String, dynamic> map) {
    return ClienteModel(
      cd_cliente: map['cd_cliente'] as int?,
      nome: map['nome'] as String,
      telefone: map['telefone'] as String,
      cpf: map['cpf'] as String,
    );
  }
}