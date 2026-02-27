// lib/api/product_api.dart
//
// All product-request CRUD operations — talks to Spring Boot /api/products

import 'package:dio/dio.dart';
import '../utils/api_constants.dart';
import '../models/product_request.dart';

class ProductApi {
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

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
      await _dio.delete("${ApiConstants.deleteProduct}/$id");
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── PUT /api/products/{id} ─────────────────────────────────────────────────
  static Future<ProductRequest> updateProduct(
      int id, ProductRequest product) async {
    try {
      final response = await _dio.put(
        "${ApiConstants.updateProduct}/$id",
        data: product.toJson(),
      );
      return ProductRequest.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Error helper ───────────────────────────────────────────────────────────
  static Exception _handleError(DioException e) {
    final msg = e.response?.data?['message'] ?? e.message ?? 'Unknown error';
    return Exception('ProductApi error: $msg');
  }
}