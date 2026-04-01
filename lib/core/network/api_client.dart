import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import '../error/failures.dart';

/// HTTP client helper for making API calls
/// 
/// Provides a centralized way to make HTTP requests with
/// consistent error handling and timeout configuration.
class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Make a GET request with automatic error handling
  /// 
  /// Returns the decoded JSON response or throws a [Failure]
  Future<Map<String, dynamic>> get(String url) async {
    try {
      final response = await _client
          .get(
            Uri.parse(url),
            headers: ApiEndpoints.defaultHeaders,
          )
          .timeout(ApiEndpoints.connectionTimeout);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        throw NotFoundFailure(
          message: 'Resource not found (HTTP ${response.statusCode})',
          code: 'HTTP_${response.statusCode}',
        );
      } else if (response.statusCode >= 500) {
        throw ServerFailure(
          message: 'Server error (HTTP ${response.statusCode})',
          code: 'HTTP_${response.statusCode}',
        );
      } else {
        throw UnknownFailure(
          message: 'Unexpected response (HTTP ${response.statusCode})',
          code: 'HTTP_${response.statusCode}',
        );
      }
    } on TimeoutException catch (e) {
      throw NetworkFailure(
        message: ErrorMessages.timeoutError,
        originalException: e,
      );
    } on http.ClientException catch (e) {
      throw NetworkFailure(
        message: ErrorMessages.networkUnavailable,
        originalException: e,
      );
    } on FormatException catch (e) {
      throw ParseFailure(
        message: ErrorMessages.parseError,
        originalException: e,
      );
    } catch (e) {
      if (e is Failure) rethrow;
      throw UnknownFailure(
        message: ErrorMessages.genericError,
        originalException: e as Exception?,
      );
    }
  }

  /// Dispose the HTTP client
  void dispose() {
    _client.close();
  }
}
