import 'package:dio/dio.dart';
import '../models/payment.dart';
import '../utils/api_constants.dart';
import 'api_client.dart';

class PaymentApi {
  static final Dio _dio = ApiClient.dio;

  // Save a successful payment record to the backend
  static Future<Payment> createPayment(Payment payment) async {
    try {
      final response = await _dio.post(
        ApiConstants.createPayment,
        data: payment.toJson(),
      );
      return Payment.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get all payment records — Admin
  static Future<List<Payment>> getAllPayments() async {
    try {
      final response = await _dio.get(ApiConstants.getAllPayments);
      final List<dynamic> data = response.data;
      return data.map((json) => Payment.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

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