import 'package:dio/dio.dart';
import '../models/shelter_model.dart';
import '../models/evacuation_route_model.dart';
import '../utils/api_constants.dart';
import 'api_client.dart';

class MapApi {
  static final Dio _dio = ApiClient.dio;

  // ═══════════════════════════════════════════════════════════════
  //  SHELTER OPERATIONS
  // ═══════════════════════════════════════════════════════════════

  /// Create a new shelter — Admin only
  static Future<Shelter> createShelter(Shelter shelter) async {
    try {
      final response = await _dio.post(
        ApiConstants.createShelter,
        data: shelter.toJson(),
      );
      return Shelter.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get all shelters — All roles
  static Future<List<Shelter>> getAllShelters() async {
    try {
      final response = await _dio.get(ApiConstants.getAllShelters);
      final List<dynamic> data = response.data;
      return data.map((json) => Shelter.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update shelter — Admin only
  static Future<Shelter> updateShelter(int shelterId, Shelter shelter) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.updateShelter}/$shelterId',
        data: shelter.toJson(),
      );
      return Shelter.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete shelter — Admin only
  static Future<void> deleteShelter(int shelterId) async {
    try {
      await _dio.delete('${ApiConstants.deleteShelter}/$shelterId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  EVACUATION ROUTE OPERATIONS
  // ═══════════════════════════════════════════════════════════════

  /// Create a new evacuation route — Admin only
  static Future<EvacuationRoute> createEvacuationRoute(
      EvacuationRoute route) async {
    try {
      final response = await _dio.post(
        ApiConstants.createEvacuationRoute,
        data: route.toJson(),
      );
      return EvacuationRoute.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get all evacuation routes with embedded shelter info — All roles
  static Future<List<EvacuationRoute>> getAllEvacuationRoutes() async {
    try {
      final response = await _dio.get(ApiConstants.getAllEvacuationRoutes);
      final List<dynamic> data = response.data;
      return data.map((json) => EvacuationRoute.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update evacuation route — Admin only
  static Future<EvacuationRoute> updateEvacuationRoute(
      int routeId, EvacuationRoute route) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.updateEvacuationRoute}/$routeId',
        data: route.toJson(),
      );
      return EvacuationRoute.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete evacuation route — Admin only
  static Future<void> deleteEvacuationRoute(int routeId) async {
    try {
      await _dio.delete('${ApiConstants.deleteEvacuationRoute}/$routeId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  ERROR HANDLER (same pattern as DonationApi)
  // ═══════════════════════════════════════════════════════════════
  static String _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        return e.response?.data['message'] ??
            'Server error: ${e.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      default:
        return 'Network error. Please try again.';
    }
  }
}