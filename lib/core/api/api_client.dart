import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

// Ganti dengan URL backend Flask Anda
const String kBaseUrl = 'http://10.34.58.64:5000/'; // ← sesuaikan

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

    // Logger (hanya di debug mode)
    assert(() {
      _dio.interceptors.add(PrettyDioLogger(
        requestHeader: false,
        requestBody: false,
        responseBody: true,
        error: true,
        compact: true,
      ));
      return true;
    }());

    // Interceptor: unwrap envelope { status, data, message }
    _dio.interceptors.add(InterceptorsWrapper(
      onResponse: (response, handler) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['status'] == 'success') {
          response.data = data['data'] ?? data;
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

// ── Helper untuk GET publik ───────────────────────────────────────────────────
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
    final res = await _dio
        .get('/api/public/riwayat-sensor', queryParameters: {'jam': jam});
    return res.data as Map<String, dynamic>;
  }
}
