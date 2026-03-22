import 'package:flutter/material.dart';
import '../data/admin_service.dart';
import '../data/product_service.dart';
import '../../../shared/models/product_model.dart';
import 'edit_product_screen.dart' as eps;
import 'manage_categories_screen.dart' as mcs;

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel de Administração'),
        backgroundColor: const Color(0xFFFFA400),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Abas
          Material(
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedTabIndex = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedTabIndex == 0
                                ? const Color(0xFFFFA400)
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.cake,
                            color: _selectedTabIndex == 0
                                ? const Color(0xFFFFA400)
                                : Colors.grey,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Produtos',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _selectedTabIndex == 0
                                  ? const Color(0xFFFFA400)
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedTabIndex = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedTabIndex == 1
                                ? const Color(0xFFFFA400)
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.category,
                            color: _selectedTabIndex == 1
                                ? const Color(0xFFFFA400)
                                : Colors.grey,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Categorias',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _selectedTabIndex == 1
                                  ? const Color(0xFFFFA400)
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Conteúdo das abas
          Expanded(
            child: _selectedTabIndex == 0
                ? const _ProductsTab()
                : const mcs.ManageCategoriesScreen(),
          ),
        ],
      ),
    );
  }
}

class _ProductsTab extends StatefulWidget {
  const _ProductsTab();

  @override
  State<_ProductsTab> createState() => __ProductsTabState();
}

class __ProductsTabState extends State<_ProductsTab> {
  late Future<List<ProductModel>> productsFuture;
  final adminService = AdminService();
  final productService = ProductService();

  @override
  void initState() {
    super.initState();
    _refreshProducts();
  }

  void _refreshProducts() {
    setState(() {
      productsFuture = productService.listarProdutos();
    });
  }

  Future<void> _deleteProduct(String id, String nome) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar Produto'),
        content: Text('Tem certeza que deseja deletar "$nome"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Deletar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await adminService.deletarProduto(id: id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produto deletado com sucesso!')),
      );
      _refreshProducts();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductModel>>(
      future: productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Erro ao carregar produtos:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _refreshProducts,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar Novamente'),
                ),
              ],
            ),
          );
        }

        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inbox, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Nenhum produto cadastrado'),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const eps.EditProductScreen(),
                      ),
                    ).then((_) => _refreshProducts());
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Novo Produto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA400),
                  ),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            ListView.separated(
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final product = items[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.shade100,
                      backgroundImage: product.imagem != null
                          ? NetworkImage(product.imagem!)
                          : null,
                      child: product.imagem == null
                          ? const Icon(Icons.cake, color: Colors.orange)
                          : null,
                    ),
                    title: Text(product.nome),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.descricao,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (product.categoria != null)
                          Text(
                            'Categoria: ${product.categoria}',
                            style: const TextStyle(fontSize: 12),
                          ),
                      ],
                    ),
                    trailing: SizedBox(
                      width: 120,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'R\$ ${product.preco.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              if (!product.ativo)
                                const Text(
                                  'Inativo',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.red,
                                  ),
                                ),
                            ],
                          ),
                          PopupMenuButton(
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        eps.EditProductScreen(product: product),
                                  ),
                                ).then((_) => _refreshProducts()),
                                child: const Row(
                                  children: [
                                    Icon(Icons.edit,
                                        size: 18, color: Colors.orange),
                                    SizedBox(width: 8),
                                    Text('Editar'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                onTap: () =>
                                    _deleteProduct(product.id, product.nome),
                                child: const Row(
                                  children: [
                                    Icon(Icons.delete,
                                        size: 18, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Deletar'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    isThreeLine: true,
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemCount: items.length,
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                backgroundColor: const Color(0xFFFFA400),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const eps.EditProductScreen(),
                    ),
                  ).then((_) => _refreshProducts());
                },
                child: const Icon(Icons.add),
              ),
            ),
          ],
        );
      },
    );
  }
}
