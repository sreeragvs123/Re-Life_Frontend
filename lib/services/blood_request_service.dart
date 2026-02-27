// lib/api/blood_request_service.dart

import 'package:dio/dio.dart';
import '../models/blood_request.dart';
import '../api/api_client.dart';
import '../utils/api_constants.dart';

class BloodRequestService {

  static Future<List<BloodRequest>> fetchBloodRequests() async {
    try {
      final response = await DioClient.dio.get(ApiConstants.getAllBloodRequests);
      return (response.data as List)
          .map((e) => BloodRequest.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Failed to fetch blood requests');
    }
  }

  static Future<void> createBloodRequest(BloodRequest request) async {
    try {
      await DioClient.dio.post(
        ApiConstants.createBloodRequest,
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Failed to create blood request');
    }
  }

  static Future<void> deleteBloodRequest(int id) async {
    try {
      await DioClient.dio.delete(
        ApiConstants.deleteBloodRequest,
        queryParameters: {'id': id},
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Failed to delete blood request');
    }
  }
}