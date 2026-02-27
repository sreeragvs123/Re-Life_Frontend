// lib/api/dio_client.dart
//
// Single authenticated Dio instance used by ALL api classes.
// • baseUrl = ApiConstants.baseUrl  → relative paths like "/blood-requests" work
// • Attaches Bearer token from Hive on every request
// • Auto-refreshes token on 401, signs out if refresh also fails
//
// Export BOTH names so existing files that import either
// DioClient.dio or ApiClient.dio both compile without changes.

import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'auth_api.dart';
import '../utils/api_constants.dart';

class DioClient {
  static final Dio dio = _build();

  static Dio _build() {
    final d = Dio(BaseOptions(
      baseUrl:        ApiConstants.baseUrl,   // ← REQUIRED for relative paths
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    d.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = Hive.box('authBox').get('accessToken') as String?;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        if (error.response?.statusCode == 401) {
          try {
            final newToken = await AuthApi.refreshToken();
            final opts = error.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newToken';
            final response = await dio.fetch(opts);
            return handler.resolve(response);
          } catch (_) {
            await AuthApi.signOut();
          }
        }
        return handler.next(error);
      },
    ));

    return d;
  }
}

// Alias so files importing ApiClient.dio also compile without any changes
typedef ApiClient = DioClient;