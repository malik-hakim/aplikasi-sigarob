import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

const String kBaseUrl = 'http://10.34.58.64:5000/';

class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;

  ApiClient._() {
    _dio = Dio(BaseOptions(
      baseUrl: kBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    assert(() {
      _dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        error: true,
        compact: false,
      ));
      return true;
    }());

    _dio.interceptors.add(InterceptorsWrapper(
      onResponse: (response, handler) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['status'] == 'success') {
          // Unwrap envelope: kembalikan isi 'data' saja
          // Jika 'data' null, kembalikan map kosong bukan null
          response.data = data['data'] ?? <String, dynamic>{};
        }
        handler.next(response);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ));
  }

  static ApiClient get instance => _instance ??= ApiClient._();
  Dio get dio => _dio;
}

class PublicApi {
  static final _dio = ApiClient.instance.dio;

  static Future<Map<String, dynamic>> getStatus() async {
    final res = await _dio.get('/api/public/status');
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getPrakiraan() async {
    final res = await _dio.get('/api/public/prakiraan');
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getRiwayat({
    int page = 1,
    int perPage = 10,
    String? level,
  }) async {
    final res = await _dio.get('/api/public/riwayat', queryParameters: {
      'page': page,
      'per_page': perPage,
      if (level != null && level.isNotEmpty) 'level': level,
    });
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getPanduan() async {
    final res = await _dio.get('/api/public/panduan');
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getRiwayatSensor({int jam = 24}) async {
    final res = await _dio.get(
      '/api/public/riwayat-sensor',
      queryParameters: {'jam': jam},
    );
    return res.data as Map<String, dynamic>;
  }
}