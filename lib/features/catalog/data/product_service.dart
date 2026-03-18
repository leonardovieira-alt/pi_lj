import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../shared/models/product_model.dart';

class ProductService {
  Future<List<ProductModel>> listarProdutos() async {
    final response = await ApiClient.get('/produtos');

    final success = response['success'] == true;
    if (!success) {
      throw const ApiException('Falha ao carregar produtos');
    }

    final data = response['data'];
    if (data is! List) {
      throw const ApiException('Formato de produtos invalido');
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(ProductModel.fromJson)
        .toList();
  }
}
