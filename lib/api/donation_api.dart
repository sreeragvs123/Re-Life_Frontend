import 'package:dio/dio.dart';
import '../models/donation.dart';
import '../utils/api_constants.dart';
import 'api_client.dart';

class DonationApi {
  static final Dio _dio = ApiClient.dio;

  // Create a new donation
  static Future<Donation> createDonation(Donation donation) async {
    try {
      final response = await _dio.post(
        ApiConstants.createDonation,
        data: donation.toJson(),
      );
      return Donation.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get all donations
  static Future<List<Donation>> getAllDonations() async {
    try {
      final response = await _dio.get(ApiConstants.getAllDonations);
      final List<dynamic> data = response.data;
      return data.map((json) => Donation.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get pending donations (not approved yet) - for Admin
  static Future<List<Donation>> getPendingDonations() async {
    try {
      final response = await _dio.get(ApiConstants.getPendingDonations);
      final List<dynamic> data = response.data;
      return data.map((json) => Donation.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get approved donations - for Volunteers and Users
  static Future<List<Donation>> getApprovedDonations() async {
    try {
      final response = await _dio.get(ApiConstants.getApprovedDonations);
      final List<dynamic> data = response.data;
      return data.map((json) => Donation.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Approve donation - Admin only
  static Future<Donation> approveDonation(int donationId) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.approveDonation}/$donationId',
      );
      return Donation.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Update donation status - Volunteer
  static Future<Donation> updateDonationStatus(int donationId, String status) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.updateDonationStatus}/$donationId',
        queryParameters: {'status': status},
      );
      return Donation.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Delete donation (reject) - Admin only
  static Future<void> deleteDonation(int donationId) async {
    try {
      await _dio.delete(
        ApiConstants.deleteDonation,
        queryParameters: {'id': donationId},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get donations by donor name - for User to see their own donations
  static Future<List<Donation>> getDonationsByDonor(String donorName) async {
    try {
      final response = await _dio.get(
        ApiConstants.getAllDonations,
        queryParameters: {'donorName': donorName},
      );
      final List<dynamic> data = response.data;
      return data.map((json) => Donation.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error handler
  static String _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        return e.response?.data['message'] ?? 'Server error: ${e.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      default:
        return 'Network error. Please try again.';
    }
  }
}