// lib/api/dio_client.dart
//
// Single authenticated Dio instance used by ALL api classes.
// • Attaches Bearer access token from Hive on every request
// • On 401: reads refreshToken from Hive, sends in request BODY to /auth/refresh
//   (FIX: was sending to cookie endpoint — cookies don't work in Flutter mobile)
// • If refresh succeeds: retries original request with new access token
// • If refresh fails: signs out → goes to LoginPage

import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import '../utils/api_constants.dart';

class DioClient {
  static final Dio dio = _build();

  static Dio _build() {
    final d = Dio(BaseOptions(
      baseUrl:        ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    d.interceptors.add(
      InterceptorsWrapper(

        // ── Attach access token to every request ────────────────────────────
        onRequest: (options, handler) {
          final token = Hive.box('authBox').get('accessToken') as String?;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },

        // ── On 401: try to refresh, then retry the original request ─────────
        onError: (DioException error, handler) async {
          if (error.response?.statusCode != 401) {
            return handler.next(error);
          }

          final box         = Hive.box('authBox');
          final refreshToken = box.get('refreshToken') as String?;

          // No refresh token stored → sign out immediately
          if (refreshToken == null || refreshToken.isEmpty) {
            await _signOut(box);
            return handler.next(error);
          }

          try {
            // FIX: Send refreshToken in JSON body — NOT as a cookie.
            // The /auth/refresh endpoint now reads from request body.
            final refreshResponse = await Dio().post(
              '${ApiConstants.baseUrl}/auth/refresh',
              data:    {'refreshToken': refreshToken},
              options: Options(headers: {'Content-Type': 'application/json'}),
            );

            final newAccessToken = refreshResponse.data['accessToken'] as String?;
            final newRefreshToken = refreshResponse.data['refreshToken'] as String?;

            if (newAccessToken == null) {
              await _signOut(box);
              return handler.next(error);
            }

            // Save new tokens
            await box.put('accessToken',  newAccessToken);
            if (newRefreshToken != null) {
              await box.put('refreshToken', newRefreshToken);
            }

            // Retry the original failed request with the new token
            final retryOptions = error.requestOptions;
            retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            final retryResponse = await dio.fetch(retryOptions);
            return handler.resolve(retryResponse);

          } catch (_) {
            // Refresh failed (token invalid/expired) → force re-login
            await _signOut(box);
            return handler.next(error);
          }
        },
      ),
    );

    return d;
  }

  // ── Clear session (called when refresh fails) ──────────────────────────────
  // Note: does NOT navigate — navigation happens in the UI layer when it
  // catches the 401 error from the API call.
  static Future<void> _signOut(Box box) async {
    await box.put('isLoggedIn',   false);
    await box.put('role',         null);
    await box.delete('accessToken');
    await box.delete('refreshToken');
    await box.delete('email');
    await box.delete('name');
    await box.delete('place');
    await box.delete('userId');
  }
}

// Alias so existing files that import ApiClient.dio also compile
typedef ApiClient = DioClient;