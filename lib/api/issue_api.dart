import 'package:dio/dio.dart';
import '../models/issue_model.dart';
import '../utils/api_constants.dart';
import 'api_client.dart';

class IssueApi {
  static final Dio _dio = ApiClient.dio;

  static Future<Issue> createIssue(Issue issue) async {
    try {
      final response = await _dio.post(
        ApiConstants.createIssue,
        data: issue.toJson(),
      );
      return Issue.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<List<Issue>> getAllIssues() async {
    try {
      final response = await _dio.get(ApiConstants.getAllIssues);
      final List<dynamic> data = response.data;
      return data.map((json) => Issue.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<void> deleteIssue(int id) async {
    try {
      await _dio.delete('${ApiConstants.deleteIssue}/$id');
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