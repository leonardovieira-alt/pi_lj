import 'dart:typed_data';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../shared/models/product_model.dart';

class AdminService {
  // PRODUTOS
  Future<ProductModel> criarProduto({
    required String nome,
    required String descricao,
    required double preco,
    String? imagem,
    String? categoria,
    String? subcategoria,
    List<Map<String, String>>? ingredientes,
    bool disponivel = true,
    int estoque = 0,
    Map<String, bool>? diasDisponiveis,
  }) async {
    final response = await ApiClient.post('/produtos', {
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'imagem': imagem,
      'categoria': categoria,
      'subcategoria': subcategoria,
      'ingredientes': ingredientes ?? [],
      'disponivel': disponivel,
      'estoque': estoque,
      'diasDisponiveis': diasDisponiveis ?? {},
    });

    if (response['success'] != true) {
      throw const ApiException('Falha ao criar produto');
    }

    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Resposta invalida ao criar produto');
    }

    return ProductModel.fromJson(data);
  }

  Future<ProductModel> atualizarProduto({
    required String id,
    required String nome,
    required String descricao,
    required double preco,
    String? imagem,
    String? categoria,
    String? subcategoria,
    List<Map<String, String>>? ingredientes,
    bool? disponivel,
    int? estoque,
    Map<String, bool>? diasDisponiveis,
    bool? ativo,
  }) async {
    final response = await ApiClient.put('/produtos/$id', {
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'imagem': imagem,
      'categoria': categoria,
      'subcategoria': subcategoria,
      'ingredientes': ingredientes,
      'disponivel': disponivel,
      'estoque': estoque,
      'diasDisponiveis': diasDisponiveis,
    });

    if (response['success'] != true) {
      throw const ApiException('Falha ao atualizar produto');
    }

    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Resposta invalida ao atualizar produto');
    }

    return ProductModel.fromJson(data);
  }

  Future<void> deletarProduto({required String id}) async {
    final response = await ApiClient.delete('/produtos/$id');

    if (response['success'] != true) {
      throw const ApiException('Falha ao deletar produto');
    }
  }

  // CATEGORIAS
  Future<List<Map<String, dynamic>>> listarCategorias() async {
    final response = await ApiClient.get('/categorias');

    if (response['success'] != true) {
      throw const ApiException('Falha ao carregar categorias');
    }

    final data = response['data'];
    if (data is! List) {
      throw const ApiException('Formato de categorias invalido');
    }

    return data.whereType<Map<String, dynamic>>().toList();
  }

  Future<Map<String, dynamic>> criarCategoria({
    required String nome,
    String? descricao,
    Uint8List? iconBytes,
    String? iconFileName,
    List<Map<String, String>>? subcategorias,
  }) async {
    try {
      final payload = {
        'nome': nome,
        'descricao': descricao,
        if (subcategorias != null && subcategorias.isNotEmpty)
          'subcategorias': subcategorias,
      };

      print('🔵 AdminService.criarCategoria - Enviando: {nome: $nome, descricao: $descricao, icone: ${iconFileName ?? 'nenhum'}, subcategorias: ${subcategorias?.length ?? 0}}');

      final response = iconBytes != null && iconFileName != null
          ? await ApiClient.postWithFile(
              '/categorias',
              payload,
              fileKey: 'icone',
              fileBytes: iconBytes,
              fileName: iconFileName,
            )
          : await ApiClient.post('/categorias', payload);

      print('🟢 AdminService.criarCategoria - Resposta: $response');

      if (response['success'] != true) {
        final errorMessage = response['message'] ?? 'Falha ao criar categoria';
        print('🔴 AdminService.criarCategoria - Erro na resposta: $errorMessage');
        throw ApiException(errorMessage);
      }

      final data = response['data'];
      if (data is! Map<String, dynamic>) {
        print('🔴 AdminService.criarCategoria - Dados inválidos: $data');
        throw const ApiException('Resposta invalida ao criar categoria');
      }

      // Extrair caminho da imagem se disponível
      final iconePath = data['icone'] as String?; // ex: "/images/categoria-123.png"
      print('✅ AdminService.criarCategoria - Categoria criada com sucesso: ${data['_id'] ?? data['id']}, icone: $iconePath');

      return {
        ...data,
        'iconePath': iconePath, // Adicionar caminho da imagem ao retorno
      };
    } catch (e) {
      print('🔴 AdminService.criarCategoria - Exceção: $e');
      throw ApiException(
        'Erro ao criar categoria: ${e.toString()}',
      );
    }
  }

  Future<Map<String, dynamic>> atualizarCategoria({
    required String id,
    required String nome,
    String? descricao,
    Uint8List? iconBytes,
    String? iconFileName,
    List<Map<String, String>>? subcategorias,
  }) async {
    try {
      final payload = {
        'nome': nome,
        'descricao': descricao,
        if (subcategorias != null && subcategorias.isNotEmpty)
          'subcategorias': subcategorias,
      };

      final response = iconBytes != null && iconFileName != null
          ? await ApiClient.postWithFile(
              '/categorias/$id',
              payload,
              fileKey: 'icone',
              fileBytes: iconBytes,
              fileName: iconFileName,
            )
          : await ApiClient.put('/categorias/$id', payload);

      if (response['success'] != true) {
        throw ApiException(
          response['message'] ?? 'Falha ao atualizar categoria',
        );
      }

      final data = response['data'];
      if (data is! Map<String, dynamic>) {
        throw const ApiException('Resposta invalida ao atualizar categoria');
      }

      // Extrair caminho da imagem se disponível
      final iconePath = data['icone'] as String?;

      return {
        ...data,
        'iconePath': iconePath, // Adicionar caminho da imagem ao retorno
      };
    } catch (e) {
      throw ApiException(
        'Erro ao atualizar categoria: ${e.toString()}',
      );
    }
  }

  Future<void> deletarCategoria({required String id}) async {
    try {
      final response = await ApiClient.delete('/categorias/$id');

      if (response['success'] != true) {
        throw ApiException(
          response['message'] ?? 'Falha ao deletar categoria',
        );
      }
    } catch (e) {
      throw ApiException(
        'Erro ao deletar categoria: ${e.toString()}',
      );
    }
  }

  // SUBCATEGORIAS
  Future<Map<String, dynamic>> adicionarSubcategoria({
    required String categoriaId,
    required String nome,
    String? descricao,
    String? icone,
  }) async {
    final response = await ApiClient.post(
      '/categorias/$categoriaId/subcategorias',
      {
        'nome': nome,
        'descricao': descricao,
        'icone': icone,
      },
    );

    if (response['success'] != true) {
      throw const ApiException('Falha ao adicionar subcategoria');
    }

    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Resposta invalida ao adicionar subcategoria');
    }

    return data;
  }

  Future<void> removerSubcategoria({
    required String categoriaId,
    required String subcategoriaId,
  }) async {
    final response = await ApiClient.delete(
      '/categorias/$categoriaId/subcategorias/$subcategoriaId',
    );

    if (response['success'] != true) {
      throw const ApiException('Falha ao remover subcategoria');
    }
  }
}
