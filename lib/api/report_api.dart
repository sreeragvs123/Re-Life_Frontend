import 'package:dio/dio.dart';
import '../models/report_model.dart';
import '../utils/api_constants.dart';
import 'api_client.dart';

class ReportApi {
  static final Dio _dio = ApiClient.dio;

  static Future<Report> createReport(Report report) async {
    try {
      final response = await _dio.post(
        ApiConstants.createReport,
        data: report.toJson(),
      );
      return Report.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<List<Report>> getAllReports() async {
    try {
      final response = await _dio.get(ApiConstants.getAllReports);
      final List<dynamic> data = response.data;
      return data.map((json) => Report.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<List<Report>> getReportsByVolunteer(String volunteerName) async {
    try {
      final response = await _dio.get(
        ApiConstants.getReportsByVolunteer,
        queryParameters: {'volunteerName': volunteerName},
      );
      final List<dynamic> data = response.data;
      return data.map((json) => Report.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static String _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Check your internet connection.';
      case DioExceptionType.badResponse:
        return e.response?.data['message'] ??
            'Server error: ${e.response?.statusCode}';
      default:
        return 'Network error. Please try again.';
    }
  }
}