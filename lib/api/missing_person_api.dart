import 'package:dio/dio.dart';
import '../models/missing_person.dart';
import 'api_client.dart';

class MissingPersonApi {
  final Dio _dio = ApiClient.dio;

  // Create new missing person
  Future<MissingPerson> create(MissingPerson person) async {
    final response = await _dio.post(
      "/missing-persons/post",
      data: person.toJson(),
    );

    return MissingPerson.fromJson(response.data);
  }

  // Get all missing persons
  Future<List<MissingPerson>> getAll() async {
    final response = await _dio.get("/missing-persons");

    return (response.data as List)
        .map((e) => MissingPerson.fromJson(e))
        .toList();
  }

  // Update found status
  Future<MissingPerson> updateStatus(int id, bool isFound) async {
    final response = await _dio.put(
      "/missing-persons/update",
      queryParameters: {"id": id},
      data: {"isFound": isFound},
    );

    return MissingPerson.fromJson(response.data);
  }

  // Delete (optional)
  Future<void> delete(int id) async {
    await _dio.delete(
      "/missing-persons/delete",
      queryParameters: {"id": id},
    );
  }
}
