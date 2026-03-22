import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

import '../data/admin_service.dart';
import '../../../core/config/api_config.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  late Future<List<Map<String, dynamic>>> categoriesFuture;
  final adminService = AdminService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshCategories();
  }

  void _refreshCategories() {
    setState(() {
      categoriesFuture = adminService.listarCategorias();
    });
  }

  Future<void> _deleteCategory(String id, String nome) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar Categoria'),
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
      setState(() => _isLoading = true);
      await adminService.deletarCategoria(id: id);
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Categoria deletada com sucesso!')),
      );
      _refreshCategories();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder<List<Map<String, dynamic>>>(
          future: categoriesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Erro ao carregar categorias:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final items = snapshot.data!;

            if (items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.inbox, size: 48, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('Nenhuma categoria cadastrada'),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        _showCategoryDialog();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Nova Categoria'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFA400),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final category = items[index];
                final nome = category['nome'] ?? 'Sem nome';
                final descricao = category['descricao'] ?? '';
                final subcategorias =
                    category['subcategorias'] as List<dynamic>? ?? [];

                return Card(
                  child: ExpansionTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: category['icone'] != null && (category['icone'] as String).startsWith('/')
                            ? Image.network(
                                '${ApiConfig.imageBaseUrl}${category['icone']}',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Text('📦', style: TextStyle(fontSize: 20)),
                              )
                            : Text(
                                category['icone'] ?? '📦',
                                style: const TextStyle(fontSize: 20),
                              ),
                      ),
                    ),
                    title: Text(nome),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (descricao.isNotEmpty)
                          Text(
                            descricao,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (subcategorias.isNotEmpty)
                          Text(
                            '${subcategorias.length} subcategoria(s)',
                            style: const TextStyle(fontSize: 12),
                          ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          onTap: () => _showCategoryDialog(
                              categoryData: category),
                          child: const Row(
                            children: [
                              Icon(Icons.edit, size: 18, color: Colors.orange),
                              SizedBox(width: 8),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          onTap: () => _deleteCategory(
                              category['_id'] ?? category['id'] ?? '', nome),
                          child: const Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Deletar'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    children: subcategorias.isNotEmpty
                        ? [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Subcategorias:',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: subcategorias.map((sub) {
                                      final subNome =
                                          (sub as Map<String, dynamic>)
                                                  ['nome'] ??
                                              'Sem nome';
                                      return Chip(
                                        label: Text(subNome),
                                        backgroundColor:
                                            Colors.orange.shade50,
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ]
                        : [],
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemCount: items.length,
            );
          },
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            backgroundColor: const Color(0xFFFFA400),
            onPressed: _showCategoryDialog,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  void _showCategoryDialog({Map<String, dynamic>? categoryData}) {
    final isEditing = categoryData != null;
    final nomeController =
        TextEditingController(text: categoryData?['nome'] ?? '');
    final descricaoController =
        TextEditingController(text: categoryData?['descricao'] ?? '');
    Uint8List? iconeBytes; // Bytes do ícone
    String? iconFileName; // Nome do arquivo
    String? iconePath; // Caminho da imagem retornado pela API
    if (isEditing) {
      final iconValue = categoryData['icone'];
      if (iconValue is String) {
        iconePath = iconValue;
      }
    }
    final List<Map<String, dynamic>> subcategorias = List.from(
      (categoryData?['subcategorias'] as List<dynamic>? ?? [])
          .map((s) => {
            'nome': s['nome'] ?? '',
            'descricao': s['descricao'] ?? '',
            'iconePath': s['icone'], // Usar caminho em vez de bytes
          }),
    );

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title:
            Text(isEditing ? 'Editar Categoria' : 'Nova Categoria'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(
                  hintText: 'Nome da categoria',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descricaoController,
                decoration: const InputDecoration(
                  hintText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: StatefulBuilder(
                  builder: (context, setIconeState) => Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ícone da Categoria',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            // Exibir imagem atual ou selecionada
                            Container(
                              width: double.infinity,
                              height: 100,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey.shade100,
                              ),
                              child: iconePath != null
                                  ? Image.network(
                                      '${ApiConfig.imageBaseUrl}$iconePath',
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Center(
                                            child: Icon(Icons.broken_image,
                                                color: Colors.red),
                                          ),
                                    )
                                  : (iconeBytes != null
                                      ? Image.memory(
                                          iconeBytes!,
                                          fit: BoxFit.cover,
                                        )
                                      : const Center(
                                          child: Icon(Icons.image_not_supported,
                                              color: Colors.grey, size: 48),
                                        )),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        iconePath != null
                                            ? 'Imagem atual'
                                            : (iconeBytes != null
                                                ? 'Imagem selecionada'
                                                : 'Nenhuma imagem selecionada'),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: (iconePath != null || iconeBytes != null)
                                              ? Colors.green
                                              : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.image),
                                  label: const Text('Selecionar'),
                                  onPressed: () async {
                                    final picker = ImagePicker();
                                    final image = await picker.pickImage(
                                      source: ImageSource.gallery,
                                      maxWidth: 1024,
                                      maxHeight: 1024,
                                      imageQuality: 85,
                                    );
                                    if (image != null) {
                                      final bytes = await image.readAsBytes();
                                      setIconeState(() {
                                        iconeBytes = bytes;
                                        iconFileName = image.name;
                                      });
                                      setDialogState(() {});
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Subcategorias:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar'),
                    onPressed: () async {
                      final nova = await _showSubcategoryDialog(context);
                      if (nova != null) {
                        setDialogState(() {
                          subcategorias.add(nova);
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (subcategorias.isNotEmpty)
                Column(
                  children: List.generate(
                    subcategorias.length,
                    (index) {
                      final sub = subcategorias[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.orange.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sub['nome'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if ((sub['descricao'] as String?)?.isNotEmpty ?? false)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          sub['descricao'] ?? '',
                                          style: const TextStyle(fontSize: 12),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.orange, size: 20),
                                onPressed: () async {
                                  final editado = await _showSubcategoryDialog(
                                    context,
                                    initialData: sub,
                                  );
                                  if (editado != null) {
                                    setDialogState(() {
                                      subcategorias[index] = editado;
                                    });
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red, size: 20),
                                onPressed: () {
                                  setDialogState(() {
                                    subcategorias.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              if (subcategorias.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Nenhuma subcategoria adicionada',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFA400),
            ),
            onPressed: () async {
              if (nomeController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nome é obrigatório')),
                );
                return;
              }

              if (iconeBytes == null && iconePath == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ícone é obrigatório')),
                );
                return;
              }

              try {
                setState(() => _isLoading = true);

                // Formatar subcategorias removendo valores null
                List<Map<String, String>>? subCategoriasFormatadas;
                if (subcategorias.isNotEmpty) {
                  subCategoriasFormatadas = subcategorias
                      .map((sub) => {
                        'nome': sub['nome'] ?? '',
                        'descricao': sub['descricao'] ?? '',
                      })
                      .where((sub) => sub['nome']!.isNotEmpty)
                      .cast<Map<String, String>>()
                      .toList();
                  if (subCategoriasFormatadas.isEmpty) {
                    subCategoriasFormatadas = null;
                  }
                }

                if (isEditing) {
                  final response = await adminService.atualizarCategoria(
                    id: categoryData['_id'] ?? categoryData['id'] ?? '',
                    nome: nomeController.text,
                    descricao: descricaoController.text.isEmpty
                        ? null
                        : descricaoController.text,
                    iconBytes: iconeBytes,
                    iconFileName: iconFileName,
                    subcategorias: subCategoriasFormatadas,
                  );
                  iconePath = response['iconePath'] as String?;
                } else {
                  final response = await adminService.criarCategoria(
                    nome: nomeController.text,
                    descricao: descricaoController.text.isEmpty
                        ? null
                        : descricaoController.text,
                    iconBytes: iconeBytes,
                    iconFileName: iconFileName,
                    subcategorias: subCategoriasFormatadas,
                  );
                  iconePath = response['iconePath'] as String?;
                }

                if (!mounted) return;
                setState(() => _isLoading = false);
                Navigator.pop(context);

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Categoria ${isEditing ? 'atualizada' : 'criada'} com sucesso!',
                    ),
                  ),
                );
                _refreshCategories();
              } catch (e) {
                if (!mounted) return;
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro: $e')),
                );
              }
            },
            child: Text(isEditing ? 'Editar' : 'Criar'),
          ),
        ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> _showSubcategoryDialog(
    BuildContext context, {
    Map<String, dynamic>? initialData,
  }) async {
    final nomeController =
        TextEditingController(text: initialData?['nome'] ?? '');
    final descricaoController =
        TextEditingController(text: initialData?['descricao'] ?? '');
    Uint8List? iconeBytes;
    String? iconFileName;
    String? iconePath = initialData?['iconePath']; // Caminho da imagem se existir

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(initialData != null ? 'Editar Subcategoria' : 'Adicionar Subcategoria'),
        content: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setSubState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome *',
                    hintText: 'Nome da subcategoria',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descricaoController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    hintText: 'Descrição (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.orange.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ícone da Subcategoria',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        // Exibir imagem atual ou selecionada
                        Container(
                          width: double.infinity,
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade100,
                          ),
                          child: iconePath != null
                              ? Image.network(
                                  '${ApiConfig.imageBaseUrl}$iconePath',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(
                                        child: Icon(Icons.broken_image,
                                            color: Colors.red),
                                      ),
                                )
                              : (iconeBytes != null
                                  ? Image.memory(
                                      iconeBytes!,
                                      fit: BoxFit.cover,
                                    )
                                  : const Center(
                                      child: Icon(Icons.image_not_supported,
                                          color: Colors.grey, size: 48),
                                    )),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    iconePath != null
                                        ? 'Imagem atual'
                                        : (iconeBytes != null
                                            ? 'Imagem selecionada'
                                            : 'Nenhuma imagem selecionada'),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: (iconePath != null || iconeBytes != null)
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.image),
                              label: const Text('Selecionar'),
                              onPressed: () async {
                                final picker = ImagePicker();
                                final image = await picker.pickImage(
                                  source: ImageSource.gallery,
                                  maxWidth: 1024,
                                  maxHeight: 1024,
                                  imageQuality: 85,
                                );
                                if (image != null) {
                                  final bytes = await image.readAsBytes();
                                  setSubState(() {
                                    iconeBytes = bytes;
                                    iconFileName = image.name;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFA400),
            ),
            onPressed: () {
              if (nomeController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nome é obrigatório')),
                );
                return;
              }

              if (iconeBytes == null && iconePath == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ícone é obrigatório')),
                );
                return;
              }

              Navigator.pop(context, {
                'nome': nomeController.text,
                'descricao': descricaoController.text.isEmpty
                    ? null
                    : descricaoController.text,
                if (iconeBytes != null)
                  ...{
                    'iconBytes': iconeBytes,
                    'iconFileName': iconFileName,
                  }
                else
                  ...{
                    'iconePath': iconePath,
                  },
              });
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
