import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import 'api_exception.dart';

class ApiClient {
  static const _tokenKey = 'auth_token';

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(_tokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

  static Future<Map<String, dynamic>> get(String path) async {
    try {
      final response = await _dio.get(path);
      return _asJson(response.data);
    } on DioException catch (e) {
      throw ApiException(_messageFromError(e));
    }
  }

  static Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post(path, data: data);
      return _asJson(response.data);
    } on DioException catch (e) {
      throw ApiException(_messageFromError(e));
    }
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Map<String, dynamic> _asJson(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    throw const ApiException('Resposta da API em formato inesperado');
  }

  static String _messageFromError(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Sem conexao com a API. Verifique servidor e URL.';
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Tempo de conexao esgotado.';
    }

    return 'Erro ao comunicar com a API.';
  }
}
