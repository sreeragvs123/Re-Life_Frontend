import 'package:dio/dio.dart';
import '../models/blood_request.dart';
import '../api/dio_client.dart';

class BloodRequestService {

  /// GET all blood requests
  static Future<List<BloodRequest>> fetchBloodRequests() async {
    try {
      final Response response =
      await DioClient.dio.get("/blood-requests");

      final List data = response.data;
      return data.map((e) => BloodRequest.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Failed to fetch data");
    }
  }

  /// POST blood request
  static Future<void> createBloodRequest(BloodRequest request) async {
    try {
      await DioClient.dio.post(
        "/blood-requests/post",
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Failed to create request");
    }
  }

  /// DELETE blood request
  static Future<void> deleteBloodRequest(int id) async {
    try {
      await DioClient.dio.delete(
        "/blood-requests/delete",
        queryParameters: {"id": id},
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Failed to delete request");
    }
  }
}
