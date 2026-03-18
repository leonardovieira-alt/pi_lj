class ProductModel {
  final String id;
  final String nome;
  final String descricao;
  final double preco;
  final String? imagem;

  const ProductModel({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.preco,
    this.imagem,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: (json['_id'] ?? '').toString(),
      nome: (json['nome'] ?? 'Sem nome').toString(),
      descricao: (json['descricao'] ?? '').toString(),
      preco: (json['preco'] is num) ? (json['preco'] as num).toDouble() : 0,
      imagem: json['imagem']?.toString(),
    );
  }
}
