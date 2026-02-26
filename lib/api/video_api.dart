import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/video_model.dart';
import '../utils/api_constants.dart';
import 'api_client.dart';

class VideoApi {
  static final Dio _dio = ApiClient.dio;

  // Upload a video file — multipart POST
  // Pass either [bytes] (web) or [filePath] (mobile)
  static Future<Video> uploadVideo({
    required String title,
    required String uploader,
    Uint8List? bytes,
    String? filePath,
    String? fileName,
  }) async {
    try {
      MultipartFile file;

      if (kIsWeb && bytes != null) {
        file = MultipartFile.fromBytes(
          bytes,
          filename: fileName ?? title,
        );
      } else if (!kIsWeb && filePath != null) {
        file = await MultipartFile.fromFile(
          filePath,
          filename: fileName ?? filePath.split('/').last,
        );
      } else {
        throw Exception('No video data provided for upload');
      }

      final formData = FormData.fromMap({
        'title': title,
        'uploader': uploader,
        'file': file,
      });

      final response = await _dio.post(
        ApiConstants.uploadVideo,
        data: formData,
      );
      return Video.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get all videos — Admin
  static Future<List<Video>> getAllVideos() async {
    try {
      final response = await _dio.get(ApiConstants.getAllVideos);
      final List<dynamic> data = response.data;
      return data.map((json) => Video.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get approved videos only — User / Volunteer
  static Future<List<Video>> getApprovedVideos() async {
    try {
      final response = await _dio.get(ApiConstants.getApprovedVideos);
      final List<dynamic> data = response.data;
      return data.map((json) => Video.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Approve a video — Admin
  static Future<Video> approveVideo(int videoId) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.approveVideo}/$videoId/approve',
      );
      return Video.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Delete a video — Admin / Volunteer (own videos)
  static Future<void> deleteVideo(int videoId) async {
    try {
      await _dio.delete('${ApiConstants.deleteVideo}/$videoId');
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