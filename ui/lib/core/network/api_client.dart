import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'api_exception.dart';

typedef AccessTokenProvider = Future<String?> Function();
typedef UnauthorizedTokenRefresher = Future<String?> Function();

class ApiClient {
  ApiClient({
    http.Client? httpClient,
    String? baseUrl,
    Duration timeout = ApiConfig.requestTimeout,
    AccessTokenProvider? accessTokenProvider,
    UnauthorizedTokenRefresher? unauthorizedTokenRefresher,
  }) : _httpClient = httpClient ?? http.Client(),
       _baseUrl = baseUrl ?? ApiConfig.baseUrl,
       _timeout = timeout,
       _accessTokenProvider = accessTokenProvider,
       _unauthorizedTokenRefresher = unauthorizedTokenRefresher;

  final http.Client _httpClient;
  final String _baseUrl;
  final Duration _timeout;
  final AccessTokenProvider? _accessTokenProvider;
  final UnauthorizedTokenRefresher? _unauthorizedTokenRefresher;
  Future<String?>? _refreshingToken;

  Future<Map<String, dynamic>> get(String path, {String? accessToken}) async {
    return _send('GET', path, accessToken: accessToken);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    String? accessToken,
  }) async {
    return _send('POST', path, body: body, accessToken: accessToken);
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
    String? accessToken,
  }) async {
    return _send('PATCH', path, body: body, accessToken: accessToken);
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, dynamic>? body,
    String? accessToken,
  }) async {
    return _send('DELETE', path, body: body, accessToken: accessToken);
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    String? accessToken,
  }) async {
    final Uri uri = _buildUri(path);
    final Map<String, String> headers = await _buildHeaders(accessToken);
    final Object? encodedBody = body == null ? null : jsonEncode(body);

    try {
      final http.Response response = await _dispatch(
        method,
        uri,
        headers,
        encodedBody,
      );

      if (_shouldRetryUnauthorized(response, path, headers)) {
        final String? refreshedToken = await _refreshAccessToken();
        if (refreshedToken != null && refreshedToken.isNotEmpty) {
          final Map<String, String> retryHeaders = await _buildHeaders(
            refreshedToken,
          );
          final http.Response retryResponse = await _dispatch(
            method,
            uri,
            retryHeaders,
            encodedBody,
          );
          return _handleResponse(retryResponse);
        }
      }

      return _handleResponse(response);
    } on TimeoutException {
      throw const ApiException(message: 'Request timed out');
    } on http.ClientException {
      throw const ApiException(message: 'No internet connection');
    } on FormatException {
      throw const ApiException(message: 'Invalid server response');
    }
  }

  Future<http.Response> _dispatch(
    String method,
    Uri uri,
    Map<String, String> headers,
    Object? encodedBody,
  ) {
    return switch (method) {
      'GET' => _httpClient.get(uri, headers: headers).timeout(_timeout),
      'POST' =>
        _httpClient
            .post(uri, headers: headers, body: encodedBody)
            .timeout(_timeout),
      'PATCH' =>
        _httpClient
            .patch(uri, headers: headers, body: encodedBody)
            .timeout(_timeout),
      'DELETE' =>
        _httpClient
            .delete(uri, headers: headers, body: encodedBody)
            .timeout(_timeout),
      _ => Future<http.Response>.error(
        StateError('Unsupported method: $method'),
      ),
    };
  }

  Future<Map<String, String>> _buildHeaders(String? accessToken) async {
    final String? token = accessToken ?? await _accessTokenProvider?.call();
    return <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Uri _buildUri(String path) {
    final String base = _baseUrl.endsWith('/')
        ? _baseUrl.substring(0, _baseUrl.length - 1)
        : _baseUrl;
    final String normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$normalizedPath');
  }

  bool _shouldRetryUnauthorized(
    http.Response response,
    String path,
    Map<String, String> headers,
  ) {
    return response.statusCode == 401 &&
        _unauthorizedTokenRefresher != null &&
        headers.containsKey('Authorization') &&
        path != '/api/auth/token/refresh/';
  }

  Future<String?> _refreshAccessToken() {
    final Future<String?>? inFlight = _refreshingToken;
    if (inFlight != null) {
      return inFlight;
    }

    final Future<String?> future = _unauthorizedTokenRefresher!();
    _refreshingToken = future.whenComplete(() {
      _refreshingToken = null;
    });
    return _refreshingToken!;
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final Object? decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body);

    final Map<String, dynamic> payload = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{'data': decoded};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return payload;
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: _extractErrorMessage(payload),
      details: payload,
    );
  }

  String _extractErrorMessage(Map<String, dynamic> payload) {
    final Object? message =
        payload['message'] ?? payload['error'] ?? payload['detail'];
    final String? extracted =
        _firstErrorText(message) ?? _firstErrorText(payload);
    return extracted ?? 'Something went wrong';
  }

  String? _firstErrorText(Object? value) {
    if (value is String) {
      final String text = value.trim();
      return text.isEmpty ? null : text;
    }

    if (value is List) {
      for (final Object? item in value) {
        final String? text = _firstErrorText(item);
        if (text != null) {
          return text;
        }
      }
    }

    if (value is Map) {
      for (final Object? item in value.values) {
        final String? text = _firstErrorText(item);
        if (text != null) {
          return text;
        }
      }
    }

    return null;
  }
}
