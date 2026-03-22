class ProductModel {
  final String id;
  final String nome;
  final String descricao;
  final double preco;
  final String? imagem;
  final String? categoria;
  final bool ativo;
  final int? estoque;
  final bool disponivel;

  const ProductModel({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.preco,
    this.imagem,
    this.categoria,
    this.ativo = true,
    this.estoque,
    this.disponivel = true,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: (json['_id'] ?? '').toString(),
      nome: (json['nome'] ?? 'Sem nome').toString(),
      descricao: (json['descricao'] ?? '').toString(),
      preco: (json['preco'] is num) ? (json['preco'] as num).toDouble() : 0,
      imagem: json['imagem']?.toString(),
      categoria: json['categoria']?.toString(),
      ativo: json['ativo'] != false,
      estoque: json['estoque'] is int ? json['estoque'] : null,
      disponivel: json['disponivel'] != false,
    );
  }
}
