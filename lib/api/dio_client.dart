import 'package:dio/dio.dart';
import '../utils/api_constants.dart';

class DioClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        "Content-Type": "application/json",
      },
    ),
  );
}
