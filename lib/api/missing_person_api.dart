// lib/api/missing_person_api.dart

import 'package:dio/dio.dart';
import '../models/missing_person.dart';
import 'api_client.dart';
import '../utils/api_constants.dart';

class MissingPersonApi {

  static Future<List<MissingPerson>> getAll() async {
    try {
      final response = await DioClient.dio.get(ApiConstants.getAllMissingPersons);
      return (response.data as List)
          .map((e) => MissingPerson.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Failed to fetch missing persons');
    }
  }

  static Future<MissingPerson> create(MissingPerson person) async {
    try {
      final response = await DioClient.dio.post(
        ApiConstants.createMissingPerson,
        data: person.toJson(),
      );
      return MissingPerson.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Failed to create missing person');
    }
  }

  static Future<MissingPerson> updateStatus(int id, bool isFound) async {
    try {
      final response = await DioClient.dio.put(
        ApiConstants.updateMissingPerson,
        queryParameters: {'id': id},
        data: {'isFound': isFound},
      );
      return MissingPerson.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Failed to update missing person');
    }
  }

  static Future<void> delete(int id) async {
    try {
      await DioClient.dio.delete(
        ApiConstants.deleteMissingPerson,
        queryParameters: {'id': id},
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Failed to delete missing person');
    }
  }
}