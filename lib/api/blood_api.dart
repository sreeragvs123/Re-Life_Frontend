import 'package:dio/dio.dart';
import '../models/blood_request.dart';
import 'api_client.dart';

class BloodApi {
  final Dio _dio = ApiClient.dio;

  Future<BloodRequest> create(BloodRequest request) async {
    final response = await _dio.post(
      "/blood-requests/post",
      data: request.toJson(),
    );

    return BloodRequest.fromJson(response.data);
  }

  Future<List<BloodRequest>> getAll() async {
    final response = await _dio.get("/blood-requests");

    return (response.data as List)
        .map((e) => BloodRequest.fromJson(e))
        .toList();
  }

  Future<void> delete(int id) async {
    await _dio.delete(
      "/blood-requests/delete",
      queryParameters: {"id": id},
    );
  }
}
