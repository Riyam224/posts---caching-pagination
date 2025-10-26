import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';

class DioClient {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://fakestoreapi.com', // API root
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  DioClient() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        // 🟢 Before every request
        onRequest: (options, handler) async {
          final token = await SecureStorage.get('access'); // get token
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options); // continue request
        },

        // 🔴 If error (like token expired)
        onError: (e, handler) async {
          if (e.response?.statusCode == 401) {
            final refresh = await SecureStorage.get('refresh');
            if (refresh != null) {
              try {
                // Request a new access token
                final response = await _dio.post(
                  '/token/refresh/',
                  data: {'refresh': refresh},
                );
                final newAccess = response.data['access'];
                await SecureStorage.save('access', newAccess);

                // Retry the failed request
                final req = e.requestOptions;
                req.headers['Authorization'] = 'Bearer $newAccess';
                final retryResponse = await _dio.fetch(req);
                return handler.resolve(retryResponse);
              } catch (_) {
                await SecureStorage.clear(); // force logout
              }
            }
          }
          handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
