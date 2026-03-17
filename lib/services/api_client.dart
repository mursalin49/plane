import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

typedef JsonMap = Map<String, dynamic>;

class ApiException implements Exception {
  ApiException({
    required this.message,
    required this.statusCode,
    this.code,
    this.details,
  });

  final String message;
  final int statusCode;
  final String? code;
  final dynamic details;

  @override
  String toString() => message;
}

class ApiEnvelope {
  ApiEnvelope({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.data,
    required this.raw,
  });

  final bool success;
  final int statusCode;
  final String message;
  final dynamic data;
  final JsonMap raw;
}

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _definedBaseUrl = String.fromEnvironment('API_BASE_URL');

  String get baseUrl {
    if (_definedBaseUrl.isNotEmpty) {
      return _normalizeBaseUrl(_definedBaseUrl);
    }

    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    }

    return 'http://localhost:3000/api';
  }

  Future<ApiEnvelope> get(
    String path, {
    String? accessToken,
    Map<String, String>? queryParameters,
  }) {
    return _request(
      'GET',
      path,
      accessToken: accessToken,
      queryParameters: queryParameters,
    );
  }

  Future<ApiEnvelope> post(String path, {String? accessToken, Object? body}) {
    return _request('POST', path, accessToken: accessToken, body: body);
  }

  Future<ApiEnvelope> _request(
    String method,
    String path, {
    String? accessToken,
    Map<String, String>? queryParameters,
    Object? body,
  }) async {
    final uri = Uri.parse(
      '${_normalizeBaseUrl(baseUrl)}/${path.replaceFirst(RegExp(r'^/+'), '')}',
    ).replace(queryParameters: queryParameters);
    final headers = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
      if (accessToken != null && accessToken.isNotEmpty)
        'Authorization': 'Bearer $accessToken',
    };

    late final http.Response response;
    try {
      switch (method) {
        case 'GET':
          response = await _client.get(uri, headers: headers);
          break;
        case 'POST':
          response = await _client.post(
            uri,
            headers: headers,
            body: body == null ? null : jsonEncode(body),
          );
          break;
        default:
          throw UnsupportedError('Unsupported method: $method');
      }
    } catch (_) {
      throw ApiException(
        message:
            'Unable to reach the server. Check the backend URL and network access.',
        statusCode: 0,
      );
    }

    final decoded = _decodeBody(response.body);
    final map = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{'message': 'Unexpected response format'};
    final success =
        map['success'] != false &&
        response.statusCode >= 200 &&
        response.statusCode < 300;

    if (!success) {
      throw ApiException(
        message: _extractMessage(map, fallback: 'Request failed'),
        statusCode: response.statusCode,
        code: map['code']?.toString(),
        details: map['details'],
      );
    }

    return ApiEnvelope(
      success: true,
      statusCode: response.statusCode,
      message: _extractMessage(map),
      data: map.containsKey('data') ? map['data'] : map,
      raw: map,
    );
  }

  dynamic _decodeBody(String body) {
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    try {
      return jsonDecode(body);
    } catch (_) {
      return <String, dynamic>{'message': body};
    }
  }

  String _extractMessage(JsonMap map, {String fallback = 'Success'}) {
    final message = map['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }
    return fallback;
  }

  String _normalizeBaseUrl(String value) {
    return value.replaceFirst(RegExp(r'/+$'), '');
  }
}
