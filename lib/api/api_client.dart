import 'package:dio/dio.dart';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://192.168.0.135:8080/api",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        "Content-Type": "application/json",
      },
    ),
  );
}
