// lib/api/product_api.dart

import 'package:dio/dio.dart';
import 'api_client.dart';          // ← FIX: use authenticated DioClient
import '../utils/api_constants.dart';
import '../models/product_request.dart';

class ProductApi {
  // FIX: was creating a bare Dio() with no auth headers.
  // /api/products requires a valid JWT (WebSecurityConfig: anyRequest().authenticated())
  // so all calls were returning 401 silently.
  // DioClient.dio automatically attaches "Authorization: Bearer <token>" from Hive.
  static final Dio _dio = DioClient.dio;

  // ── GET /api/products ──────────────────────────────────────────────────────
  static Future<List<ProductRequest>> getAllProducts() async {
    try {
      final response = await _dio.get(ApiConstants.getAllProducts);
      final List data = response.data as List;
      return data.map((e) => ProductRequest.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── POST /api/products ─────────────────────────────────────────────────────
  static Future<ProductRequest> addProduct(ProductRequest product) async {
    try {
      final response = await _dio.post(
        ApiConstants.createProduct,
        data: product.toJson(),
      );
      return ProductRequest.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── DELETE /api/products/{id} ──────────────────────────────────────────────
  static Future<void> deleteProduct(int id) async {
    try {
      await _dio.delete('${ApiConstants.deleteProduct}/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── PUT /api/products/{id} ─────────────────────────────────────────────────
  static Future<ProductRequest> updateProduct(
      int id, ProductRequest product) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.updateProduct}/$id',
        data: product.toJson(),
      );
      return ProductRequest.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Error helper ───────────────────────────────────────────────────────────
  static Exception _handleError(DioException e) {
    final body = e.response?.data;
    final msg  = (body is Map ? body['message'] : null)
        ?? e.message
        ?? 'Unknown error';
    return Exception('ProductApi error: $msg');
  }
}