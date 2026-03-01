// lib/api/group_task_api.dart

import 'package:dio/dio.dart';
import 'api_client.dart';           // ← FIX: use authenticated DioClient
import '../utils/api_constants.dart';
import '../models/group_task.dart';

class GroupTaskApi {
  // FIX: was bare Dio() — /api/group-tasks requires ROLE_ADMIN or ROLE_VOLUNTEER
  // (WebSecurityConfig: .requestMatchers("/api/group-tasks/**").hasAnyRole("ADMIN","VOLUNTEER"))
  // Without the Bearer token every call returned 401/403 silently.
  static final Dio _dio = DioClient.dio;

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
        '${ApiConstants.getGroupTasksByPlace}/$place',
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
      await _dio.delete('${ApiConstants.deleteGroupTask}/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Error helper ───────────────────────────────────────────────────────────
  static Exception _handleError(DioException e) {
    final body = e.response?.data;
    final msg  = (body is Map ? body['message'] : null)
        ?? e.message
        ?? 'Unknown error';
    return Exception('GroupTaskApi error: $msg');
  }
}