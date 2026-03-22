import 'dart:convert';
import 'dart:typed_data';

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
      print('📤 ApiClient.post($path) - Enviando: $data');
      final response = await _dio.post(path, data: data);
      final result = _asJson(response.data);
      print('✅ ApiClient.post($path) - Resposta: $result');
      return result;
    } on DioException catch (e) {
      final errorMsg = _messageFromError(e);
      print('❌ ApiClient.post($path) - Erro: $errorMsg');
      print('   Status: ${e.response?.statusCode}');
      print('   Body: ${e.response?.data}');
      throw ApiException(errorMsg);
    }
  }

  static Future<Map<String, dynamic>> postWithFile(
    String path,
    Map<String, dynamic> data, {
    required String fileKey,
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    try {
      final formData = FormData();

      // Adicionar campos de texto
      for (final entry in data.entries) {
        if (entry.value == null) {
          continue; // Pular valores null
        }

        if (entry.value is List) {
          // Para listas, enviar como JSON string
          final jsonString = jsonEncode(entry.value);
          formData.fields.add(MapEntry(entry.key, jsonString));
        } else if (entry.value is! Uint8List) {
          formData.fields.add(MapEntry(entry.key, entry.value.toString()));
        }
      }

      // Adicionar arquivo
      formData.files.add(
        MapEntry(
          fileKey,
          MultipartFile.fromBytes(fileBytes, filename: fileName),
        ),
      );

      print('📤 ApiClient.postWithFile($path) - Enviando: ${data.keys.where((k) => data[k] != null).toList()} + arquivo ($fileName)');

      final response = await _dio.post(path, data: formData);
      final result = _asJson(response.data);
      print('✅ ApiClient.postWithFile($path) - Resposta: $result');
      return result;
    } on DioException catch (e) {
      final errorMsg = _messageFromError(e);
      print('❌ ApiClient.postWithFile($path) - Erro: $errorMsg');
      print('   Status: ${e.response?.statusCode}');
      print('   Body: ${e.response?.data}');
      throw ApiException(errorMsg);
    }
  }

  static Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put(path, data: data);
      return _asJson(response.data);
    } on DioException catch (e) {
      throw ApiException(_messageFromError(e));
    }
  }

  static Future<Map<String, dynamic>> delete(String path) async {
    try {
      final response = await _dio.delete(path);
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
