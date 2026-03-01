// lib/api/auth_api.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../utils/api_constants.dart';
import '../models/auth_models.dart';

class AuthApi {
  // Use a plain Dio for auth calls (no interceptor loop)
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

  // ── POST /api/auth/login ───────────────────────────────────────────────────
  static Future<LoginResponse> login(LoginRequest request) async {
    try {
      debugPrint('🔐 LOGIN → ${ApiConstants.login}');
      final response = await _dio.post(
        ApiConstants.login,
        data: request.toJson(),
      );
      debugPrint('✅ LOGIN response: ${response.data}');
      final loginResp = LoginResponse.fromJson(response.data);
      await _saveSession(loginResp);
      return loginResp;
    } on DioException catch (e) {
      debugPrint('❌ LOGIN error: ${e.response?.statusCode} ${e.response?.data}');
      throw _handleError(e);
    }
  }

  // ── POST /api/auth/signUp ──────────────────────────────────────────────────
  static Future<void> signUp(SignUpRequest request) async {
    try {
      debugPrint('📝 SIGNUP → ${ApiConstants.signUp}');
      await _dio.post(ApiConstants.signUp, data: request.toJson());
    } on DioException catch (e) {
      debugPrint('❌ SIGNUP error: ${e.response?.statusCode} ${e.response?.data}');
      throw _handleError(e);
    }
  }

  // ── POST /api/auth/refresh ─────────────────────────────────────────────────
  // FIX: Sends refreshToken in JSON body — NOT in a cookie.
  // Cookies are a browser mechanism and don't work in Flutter mobile.
  static Future<String> refreshToken() async {
    final box          = Hive.box('authBox');
    final refreshToken = box.get('refreshToken') as String?;
    if (refreshToken == null) throw Exception('No refresh token stored');

    try {
      final response = await _dio.post(
        ApiConstants.refresh,
        data: {'refreshToken': refreshToken},   // ← body, not cookie
      );

      final newAccessToken  = response.data['accessToken']  as String;
      final newRefreshToken = response.data['refreshToken'] as String?;

      await box.put('accessToken', newAccessToken);
      if (newRefreshToken != null) {
        await box.put('refreshToken', newRefreshToken);
      }

      return newAccessToken;
    } on DioException catch (e) {
      debugPrint('❌ REFRESH error: ${e.response?.statusCode} ${e.response?.data}');
      throw _handleError(e);
    }
  }

  // ── Sign out — clear all session data from Hive ───────────────────────────
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

  // ── Save session to Hive after successful login ───────────────────────────
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
    debugPrint('✅ Session saved — role=${resp.role} email=${resp.email}');
  }

  // ── Error handler ──────────────────────────────────────────────────────────
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
    final body = e.response?.data;
    if (body is Map) {
      final msg = body['message'] ?? body['error'] ?? body.toString();
      return Exception(msg.toString());
    }
    return Exception(e.message ?? 'Unknown error');
  }
}