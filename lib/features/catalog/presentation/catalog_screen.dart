import 'package:flutter/material.dart';
import '../../../core/config/api_config.dart';
import '../../../shared/models/product_model.dart';
import '../../../shared/models/user_model.dart';
import '../data/product_service.dart';
import '../data/admin_service.dart';
import '../../../features/auth/data/auth_service.dart';
import 'admin_panel_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late Future<List<ProductModel>> productsFuture;
  late Future<List<Map<String, dynamic>>> categoriasFuture;
  final authService = AuthService();
  final productService = ProductService();
  final adminService = AdminService();
  bool isAdmin = false;
  UserModel? currentUser;

  @override
  void initState() {
    super.initState();
    productsFuture = productService.listarProdutos();
    categoriasFuture = adminService.listarCategorias();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await authService.perfil();
      setState(() {
        currentUser = user;
        isAdmin = user.isAdmin;
      });
    } catch (_) {
      setState(() => isAdmin = false);
    }
  }

  void _refreshCatalog() {
    setState(() {
      productsFuture = productService.listarProdutos();
      categoriasFuture = adminService.listarCategorias();
    });
  }

  Map<String, List<ProductModel>> _groupByCategory(List<ProductModel> products) {
    final grouped = <String, List<ProductModel>>{};
    for (var product in products.where((p) => p.ativo)) {
      final categoria = product.categoria ?? 'Sem Categoria';
      grouped.putIfAbsent(categoria, () => []).add(product);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Image.asset(
            'assets/images/candy_1.png',
            fit: BoxFit.contain,
          ),
        ),
        title: const SizedBox.shrink(),
        actions: [
          // Ícone de admin se for admin
          if (isAdmin)
            Tooltip(
              message: 'Painel de Administração',
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminPanelScreen(),
                    ),
                  ).then((_) => _refreshCatalog());
                },
                icon: Icon(Icons.verified_user, color: Colors.orange, size: 24),
              ),
            ),
          // Dados do usuário
          if (currentUser != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currentUser!.nome,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    if (isAdmin)
                      const Text(
                        'Admin',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            )
          else
            const SizedBox(width: 16),
        ],
      ),
      body: _buildCatalogView(),
    );
  }

  Widget _buildCatalogView() {
    return FutureBuilder<List<ProductModel>>(
      future: productsFuture,
      builder: (context, snapshotProducts) {
        if (snapshotProducts.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshotProducts.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar cardápio:\n${snapshotProducts.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _refreshCatalog,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            ),
          );
        }

        final items = snapshotProducts.data ?? [];
        final activeItems = items.where((p) => p.ativo).toList();
        final groupedProducts = _groupByCategory(activeItems);

        if (activeItems.isEmpty) {
          return const Center(
            child: Text('Nenhum produto disponível no momento'),
          );
        }

        // Buscar categorias para exibir imagens
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: categoriasFuture,
          builder: (context, snapshotCategorias) {
            // Criar mapa de categoria (nome) -> dados (imagem, etc)
            Map<String, Map<String, dynamic>> categoriasMap = {};
            if (snapshotCategorias.hasData) {
              for (var cat in snapshotCategorias.data!) {
                categoriasMap[cat['nome'] ?? ''] = cat;
              }
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Banner Destaque
                  if (activeItems.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.all(12),
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.shade400,
                            Colors.orange.shade600,
                          ],
                        ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -30,
                        top: -20,
                        child: Opacity(
                          opacity: 0.2,
                          child: Icon(
                            Icons.cake,
                            size: 200,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activeItems.first.nome.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  activeItems.first.descricao,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add_circle,
                                      color: Colors.orange, size: 18),
                                  SizedBox(width: 6),
                                  Text(
                                    'Peça Agora',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              // Produtos por Categoria
              ...groupedProducts.entries.map((entry) {
                final categoriaDados = categoriasMap[entry.key];
                final imagemCategoria = categoriaDados?['icone'] as String?;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: Row(
                        children: [
                          // Imagem da categoria
                          if (imagemCategoria != null && imagemCategoria.startsWith('/'))
                            Container(
                              width: 40,
                              height: 40,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.orange.shade100,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  '${ApiConfig.imageBaseUrl}$imagemCategoria',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.category, color: Colors.orange),
                                ),
                              ),
                            )
                          else
                            Container(
                              width: 40,
                              height: 40,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.orange.shade100,
                              ),
                              child: Center(
                                child: Text(
                                  imagemCategoria ?? '📦',
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                          // Nome da categoria
                          Expanded(
                            child: Text(
                              entry.key,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: entry.value.length,
                      itemBuilder: (context, index) {
                        final product = entry.value[index];
                        return ProductCard(product: product);
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              }).toList(),
            ],
          ),
            );
          },
        );
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Container(
              height: 100,
              width: double.infinity,
              color: Colors.orange.shade100,
              child: product.imagem != null
                  ? Image.network(
                      product.imagem!,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, st) {
                        return const Icon(Icons.cake, color: Colors.orange);
                      },
                    )
                  : const Icon(Icons.cake, color: Colors.orange),
            ),
          ),
          // Conteúdo
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.nome,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Color(0xFF111827),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.descricao,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'R\$ ${product.preco.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Color(0xFF111827),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.nome} adicionado ao carrinho'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.orange,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
