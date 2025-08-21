//lib\core\network\api_client.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../errors/exceptions.dart';
import '../../shared/services/storage_service.dart';

class ApiClient {
  final http.Client _client = http.Client();
  final StorageService _storageService = StorageService();

  Future<Map<String, String>> _getHeaders({bool requiresAuth = false}) async {
    final headers = Map<String, String>.from(ApiConstants.defaultHeaders);

    if (requiresAuth) {
      final token = await _storageService.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<dynamic> get(
    String url, {
    bool requiresAuth = false,
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse(url).replace(queryParameters: queryParams);
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      final response = await _client.get(uri, headers: headers);

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('No internet connection');
    } catch (e) {
      throw ServerException('Something went wrong');
    }
  }

  Future<dynamic> post(
    String url,
    Map<String, dynamic> body, {
    bool requiresAuth = false,
  }) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      final response = await _client.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('No internet connection');
    } catch (e) {
      throw ServerException('Something went wrong');
    }
  }

  Future<dynamic> postMultipart(
    String url,
    Map<String, String> fields, {
    Map<String, File>? files,
    bool requiresAuth = false,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add headers
      if (requiresAuth) {
        final token = await _storageService.getToken();
        if (token != null) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      }

      // Add fields
      request.fields.addAll(fields);

      // Add files
      if (files != null) {
        for (final entry in files.entries) {
          request.files.add(
            await http.MultipartFile.fromPath(entry.key, entry.value.path),
          );
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('No internet connection');
    } catch (e) {
      throw ServerException('Something went wrong');
    }
  }

  Future<dynamic> put(
    String url,
    Map<String, dynamic> body, {
    bool requiresAuth = false,
  }) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      final response = await _client.put(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('No internet connection');
    } catch (e) {
      throw ServerException('Something went wrong');
    }
  }

  Future<dynamic> delete(String url, {bool requiresAuth = false}) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      final response = await _client.delete(Uri.parse(url), headers: headers);

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('No internet connection');
    } catch (e) {
      throw ServerException('Something went wrong');
    }
  }

  dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        try {
          return json.decode(response.body);
        } catch (e) {
          return response.body;
        }
      case 400:
        throw BadRequestException('Bad request');
      case 401:
        throw UnauthorizedException('Unauthorized');
      case 403:
        throw ForbiddenException('Forbidden');
      case 404:
        throw NotFoundException('Not found');
      case 500:
        throw ServerException('Internal server error');
      default:
        throw ServerException('Something went wrong');
    }
  }

  void dispose() {
    _client.close();
  }
}
