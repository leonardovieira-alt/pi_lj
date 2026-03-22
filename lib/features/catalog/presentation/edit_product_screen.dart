import 'package:flutter/material.dart';
import '../data/admin_service.dart';
import '../../../shared/models/product_model.dart';

class EditProductScreen extends StatefulWidget {
  final ProductModel? product;

  const EditProductScreen({super.key, this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController nomeController;
  late TextEditingController descricaoController;
  late TextEditingController precoController;
  late TextEditingController imagemController;
  late TextEditingController estoqueController;

  final adminService = AdminService();
  late Future<List<Map<String, dynamic>>> categoriasFuture;
  String? selectedCategoria;
  String? selectedSubcategoria;
  bool ativo = true;
  bool disponivel = true;
  bool isLoading = false;

  // Ingredientes
  final List<Map<String, String>> ingredientes = [];
  late TextEditingController ingredienteNomeController;
  late TextEditingController ingredienteQtdController;

  // Dias da semana
  late Map<String, bool> diasDisponiveis;

  @override
  void initState() {
    super.initState();
    nomeController = TextEditingController(text: widget.product?.nome ?? '');
    descricaoController =
        TextEditingController(text: widget.product?.descricao ?? '');
    precoController =
        TextEditingController(text: widget.product?.preco.toString() ?? '');
    imagemController = TextEditingController(text: widget.product?.imagem ?? '');
    estoqueController =
        TextEditingController(text: widget.product?.estoque?.toString() ?? '0');

    ingredienteNomeController = TextEditingController();
    ingredienteQtdController = TextEditingController();

    selectedCategoria = widget.product?.categoria;
    ativo = widget.product?.ativo ?? true;
    disponivel = widget.product?.disponivel ?? true;

    diasDisponiveis = {
      'segunda': true,
      'terca': true,
      'quarta': true,
      'quinta': true,
      'sexta': true,
      'sabado': true,
      'domingo': false,
    };

    categoriasFuture = adminService.listarCategorias();
  }

  @override
  void dispose() {
    nomeController.dispose();
    descricaoController.dispose();
    precoController.dispose();
    imagemController.dispose();
    estoqueController.dispose();
    ingredienteNomeController.dispose();
    ingredienteQtdController.dispose();
    super.dispose();
  }

  Future<void> salvarProduto() async {
    if (nomeController.text.isEmpty ||
        descricaoController.text.isEmpty ||
        precoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios')),
      );
      return;
    }

    final preco = double.tryParse(precoController.text);
    if (preco == null || preco < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preço inválido')),
      );
      return;
    }

    final estoque = int.tryParse(estoqueController.text) ?? 0;

    setState(() => isLoading = true);
    try {
      if (widget.product == null) {
        // Criar novo produto
        await adminService.criarProduto(
          nome: nomeController.text,
          descricao: descricaoController.text,
          preco: preco,
          imagem: imagemController.text.isNotEmpty ? imagemController.text : null,
          categoria: selectedCategoria,
          subcategoria: selectedSubcategoria,
          ingredientes: ingredientes.isNotEmpty ? ingredientes : null,
          disponivel: disponivel,
          estoque: estoque,
          diasDisponiveis: diasDisponiveis,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto criado com sucesso!')),
        );
      } else {
        // Atualizar produto
        await adminService.atualizarProduto(
          id: widget.product!.id,
          nome: nomeController.text,
          descricao: descricaoController.text,
          preco: preco,
          imagem: imagemController.text.isNotEmpty ? imagemController.text : null,
          categoria: selectedCategoria,
          subcategoria: selectedSubcategoria,
          ingredientes: ingredientes.isNotEmpty ? ingredientes : null,
          ativo: ativo,
          disponivel: disponivel,
          estoque: estoque,
          diasDisponiveis: diasDisponiveis,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto atualizado com sucesso!')),
        );
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFE5E7EB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFFFA400), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Novo Produto' : 'Editar Produto'),
        backgroundColor: const Color(0xFFFFA400),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seção Básica
            const Text(
              'INFORMAÇÕES BÁSICAS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFFFFA400),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Nome do Produto *',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nomeController,
              enabled: !isLoading,
              decoration: _inputDecoration(hint: 'Ex: Bolo de Cenoura'),
            ),
            const SizedBox(height: 16),
            Text(
              'Descrição *',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descricaoController,
              enabled: !isLoading,
              maxLines: 3,
              decoration: _inputDecoration(hint: 'Descrever o produto...'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preço (R\$) *',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: precoController,
                        enabled: !isLoading,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: _inputDecoration(hint: 'Ex: 35.90'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estoque',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: estoqueController,
                        enabled: !isLoading,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(hint: 'Ex: 10'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'URL da Imagem',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: imagemController,
              enabled: !isLoading,
              decoration:
                  _inputDecoration(hint: 'https://exemplo.com/imagem.jpg'),
            ),
            const SizedBox(height: 24),
            // Seção Categorias
            const Text(
              'CATEGORIAS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFFFFA400),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Categoria',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: categoriasFuture,
              builder: (context, snapshot) {
                final categorias = snapshot.data ?? [];
                return DropdownButton<String>(
                  isExpanded: true,
                  value: selectedCategoria,
                  hint: const Text('Selecione uma categoria'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Sem Categoria'),
                    ),
                    ...categorias.map((cat) {
                      final nome = cat['nome'] ?? 'Sem nome';
                      return DropdownMenuItem(
                        value: nome,
                        child: Text(nome),
                      );
                    }),
                  ],
                  onChanged: !isLoading
                      ? (value) {
                          setState(() {
                            selectedCategoria = value;
                            selectedSubcategoria = null;
                          });
                        }
                      : null,
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Subcategoria',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: categoriasFuture,
              builder: (context, snapshot) {
                final categorias = snapshot.data ?? [];
                List<String> subcategorias = [];

                if (selectedCategoria != null) {
                  final cat = categorias.firstWhere(
                    (c) => c['nome'] == selectedCategoria,
                    orElse: () => {},
                  );
                  if (cat.isNotEmpty) {
                    final subs = cat['subcategorias'] as List<dynamic>? ?? [];
                    subcategorias = subs
                        .map((s) => (s as Map<String, dynamic>)['nome'] ?? '')
                        .cast<String>()
                        .toList();
                  }
                }

                return DropdownButton<String>(
                  isExpanded: true,
                  value: selectedSubcategoria,
                  hint: const Text('Selecione uma subcategoria'),
                  disabledHint: const Text('Selecione uma categoria antes'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Nenhuma'),
                    ),
                    ...subcategorias.map((sub) {
                      return DropdownMenuItem(
                        value: sub,
                        child: Text(sub),
                      );
                    }),
                  ],
                  onChanged: selectedCategoria != null && !isLoading
                      ? (value) {
                          setState(
                              () => selectedSubcategoria = value);
                        }
                      : null,
                );
              },
            ),
            const SizedBox(height: 24),
            // Seção Ingredientes
            const Text(
              'INGREDIENTES',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFFFFA400),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: ingredienteNomeController,
                    enabled: !isLoading,
                    decoration: _inputDecoration(hint: 'Nome do ingrediente'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 0,
                  child: SizedBox(
                    width: 80,
                    child: TextField(
                      controller: ingredienteQtdController,
                      enabled: !isLoading,
                      decoration: _inputDecoration(hint: 'Qtd'),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: !isLoading &&
                          ingredienteNomeController.text.isNotEmpty
                      ? () {
                          setState(() {
                            ingredientes.add({
                              'nome': ingredienteNomeController.text,
                              'quantidade':
                                  ingredienteQtdController.text.isEmpty
                                      ? '1'
                                      : ingredienteQtdController.text,
                            });
                            ingredienteNomeController.clear();
                            ingredienteQtdController.clear();
                          });
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA400),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            if (ingredientes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(
                  ingredientes.length,
                  (index) => Chip(
                    label: Text(
                        '${ingredientes[index]['nome']} (${ingredientes[index]['quantidade']})'),
                    onDeleted: () {
                      setState(() => ingredientes.removeAt(index));
                    },
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            // Seção Disponibilidade
            const Text(
              'DISPONIBILIDADE',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFFFFA400),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Disponível',
                  style: const TextStyle(fontWeight: FontWeight.w600,
                      fontSize: 14),
                ),
                Switch(
                  value: disponivel,
                  onChanged: !isLoading ? (v) => setState(() => disponivel = v) : null,
                  activeColor: const Color(0xFFFFA400),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Dias da Semana (disponível para encomenda)',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'segunda',
                'terca',
                'quarta',
                'quinta',
                'sexta',
                'sabado',
                'domingo'
              ].map((dia) => FilterChip(
                    label: Text(dia.isEmpty ? 'Domingo' : _diasNomes[dia] ?? dia),
                    selected: diasDisponiveis[dia] ?? false,
                    onSelected: !isLoading
                        ? (selected) {
                            setState(() {
                              diasDisponiveis[dia] = selected;
                            });
                          }
                        : null,
                    selectedColor: const Color(0xFFFFA400),
                    labelStyle: TextStyle(
                      color: diasDisponiveis[dia] ?? false
                          ? Colors.white
                          : Colors.black,
                    ),
                  )).toList(),
            ),
            if (widget.product != null) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ativo',
                    style: const TextStyle(fontWeight: FontWeight.w600,
                        fontSize: 14),
                  ),
                  Switch(
                    value: ativo,
                    onChanged: !isLoading ? (v) => setState(() => ativo = v) : null,
                    activeColor: const Color(0xFFFFA400),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : salvarProduto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA400),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        widget.product == null
                            ? 'Criar Produto'
                            : 'Atualizar Produto',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  static final Map<String, String> _diasNomes = {
    'segunda': 'Segunda',
    'terca': 'Terça',
    'quarta': 'Quarta',
    'quinta': 'Quinta',
    'sexta': 'Sexta',
    'sabado': 'Sábado',
    'domingo': 'Domingo',
  };
}
