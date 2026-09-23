import 'package:dio/dio.dart';

class ApiClient {
  static const String defaultBaseUrl = 'http://localhost:8000/api/v1';

  final Dio dio;

  ApiClient({String baseUrl = defaultBaseUrl})
      : dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );
}
