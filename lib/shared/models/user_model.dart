class UserModel {
  final String id;
  final String nome;
  final String email;
  final String? telefone;
  final bool isAdmin;

  const UserModel({
    required this.id,
    required this.nome,
    required this.email,
    this.telefone,
    this.isAdmin = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['_id'] ?? '').toString(),
      nome: (json['nome'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      telefone: json['telefone']?.toString(),
      isAdmin: json['isAdmin'] == true || json['role'] == 'admin',
    );
  }
}
