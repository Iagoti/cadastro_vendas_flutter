class UsuarioModel {
  final int? cd_usuario;
  final String username;
  final String password;

  UsuarioModel({
    this.cd_usuario,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'cd_usuario': cd_usuario,
      'username': username,
      'password': password,
    };
  }

  factory UsuarioModel.fromMap(Map<String, dynamic> map) {
    return UsuarioModel(
      cd_usuario: map['cd_usuario'] as int?,
      username: map['username'] as String,
      password: map['password'] as String,
    );
  }
}