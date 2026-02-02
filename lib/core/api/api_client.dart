import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioClient {
  static const String baseUrl = 'http://127.0.0.1:5003/api';

  static Dio createDio({bool withAuthInterceptor = false, FirebaseAuth? firebaseAuth}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(PrettyDioLogger(
      requestBody: true,
      error: true,
      request: true,
      requestHeader: true,
      responseHeader: true,
      responseBody: true,
    ));

    if (withAuthInterceptor && firebaseAuth != null) {
      dio.interceptors.add(AuthInterceptor(firebaseAuth));
    }

    return dio;
  }
}

class AuthInterceptor extends Interceptor {
  final FirebaseAuth firebaseAuth;

  AuthInterceptor(this.firebaseAuth);

  @override
  Future<void> onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user != null) {
        final token = await user.getIdToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      }
      handler.next(options);
    } catch (e) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: 'Failed to get auth token: $e',
        ),
      );
    }
  }

}