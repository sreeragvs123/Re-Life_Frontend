// lib/api/group_task_api.dart
//
// Group task CRUD — talks to Spring Boot /api/group-tasks

import 'package:dio/dio.dart';
import '../utils/api_constants.dart';
import '../models/group_task.dart';

class GroupTaskApi {
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

  // ── GET /api/group-tasks ───────────────────────────────────────────────────
  static Future<List<GroupTask>> getAllGroupTasks() async {
    try {
      final response = await _dio.get(ApiConstants.getAllGroupTasks);
      final List data = response.data as List;
      return data.map((e) => GroupTask.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── GET /api/group-tasks/place/{place} ─────────────────────────────────────
  static Future<List<GroupTask>> getTasksByPlace(String place) async {
    try {
      final response = await _dio.get(
        "${ApiConstants.getGroupTasksByPlace}/$place",
      );
      final List data = response.data as List;
      return data.map((e) => GroupTask.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── POST /api/group-tasks ──────────────────────────────────────────────────
  static Future<GroupTask> createGroupTask(GroupTask groupTask) async {
    try {
      final response = await _dio.post(
        ApiConstants.createGroupTask,
        data: groupTask.toJson(),
      );
      return GroupTask.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── DELETE /api/group-tasks/{id} ───────────────────────────────────────────
  static Future<void> deleteGroupTask(int id) async {
    try {
      await _dio.delete("${ApiConstants.deleteGroupTask}/$id");
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Error helper ───────────────────────────────────────────────────────────
  static Exception _handleError(DioException e) {
    final msg = e.response?.data?['message'] ?? e.message ?? 'Unknown error';
    return Exception('GroupTaskApi error: $msg');
  }
}