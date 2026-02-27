// lib/api/auth_api.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../utils/api_constants.dart';
import '../models/auth_models.dart';

class AuthApi {
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

  // ── POST /api/auth/login ───────────────────────────────────────────────────
  static Future<LoginResponse> login(LoginRequest request) async {
    try {
      debugPrint('🔐 LOGIN → ${ApiConstants.login}');
      debugPrint('   body: ${request.toJson()}');

      final response = await _dio.post(
        ApiConstants.login,
        data: request.toJson(),
      );

      debugPrint('✅ LOGIN response: ${response.data}');
      final loginResp = LoginResponse.fromJson(response.data);
      await _saveSession(loginResp);
      return loginResp;
    } on DioException catch (e) {
      debugPrint('❌ LOGIN error: status=${e.response?.statusCode} body=${e.response?.data}');
      throw _handleError(e);
    }
  }

  // ── POST /api/auth/signUp ──────────────────────────────────────────────────
  static Future<void> signUp(SignUpRequest request) async {
    try {
      debugPrint('📝 SIGNUP → ${ApiConstants.signUp}');
      debugPrint('   body: ${request.toJson()}');

      final response = await _dio.post(
        ApiConstants.signUp,
        data: request.toJson(),
      );

      debugPrint('✅ SIGNUP response: status=${response.statusCode} body=${response.data}');
    } on DioException catch (e) {
      debugPrint('❌ SIGNUP error: status=${e.response?.statusCode} body=${e.response?.data} msg=${e.message}');
      throw _handleError(e);
    }
  }

  // ── POST /api/auth/refresh ─────────────────────────────────────────────────
  static Future<String> refreshToken() async {
    final box          = Hive.box('authBox');
    final refreshToken = box.get('refreshToken') as String?;
    if (refreshToken == null) throw Exception('No refresh token stored');

    try {
      final response = await _dio.post(
        ApiConstants.refresh,
        data: {'refreshToken': refreshToken},
      );
      final newAccess = response.data['accessToken'] as String;
      await box.put('accessToken', newAccess);
      return newAccess;
    } on DioException catch (e) {
      debugPrint('❌ REFRESH error: status=${e.response?.statusCode} body=${e.response?.data}');
      throw _handleError(e);
    }
  }

  // ── Sign out ───────────────────────────────────────────────────────────────
  static Future<void> signOut() async {
    final box = Hive.box('authBox');
    await box.put('isLoggedIn',   false);
    await box.put('role',         null);
    await box.delete('accessToken');
    await box.delete('refreshToken');
    await box.delete('email');
    await box.delete('name');
    await box.delete('place');
    await box.delete('userId');
    debugPrint('👋 Signed out — session cleared');
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  static Future<void> _saveSession(LoginResponse resp) async {
    final box = Hive.box('authBox');
    await box.put('isLoggedIn',   true);
    await box.put('accessToken',  resp.accessToken);
    await box.put('refreshToken', resp.refreshToken);
    await box.put('role',         resp.role);
    await box.put('email',        resp.email);
    await box.put('name',         resp.name);
    await box.put('userId',       resp.id);
    await box.put('place',        resp.place ?? '');
  }

  static Exception _handleError(DioException e) {
    final status = e.response?.statusCode;
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return Exception('Cannot reach server. Check your network or server IP.');
    }
    if (status == 401 || status == 403) {
      return Exception('Invalid email or password');
    }
    if (status == 409) {
      return Exception('Email already registered');
    }
    // Try to get message from backend error response body
    final body = e.response?.data;
    if (body is Map) {
      final msg = body['message'] ?? body['error'] ?? body.toString();
      return Exception(msg.toString());
    }
    return Exception(e.message ?? 'Unknown error');
  }
}