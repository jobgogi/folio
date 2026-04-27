/// @description Dio HTTP 클라이언트 설정 — 쿠키 관리 및 401 인터셉터 포함
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.27
/// @version 1.0.0
/// @see NasApiClient
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

class DioClient {
  DioClient({
    required Dio dio,
    required String baseUrl,
    required CookieJar cookieJar,
    void Function()? onUnauthorized,
  }) : _dio = dio {
    dio.options.baseUrl = baseUrl;
    dio.options.extra['withCredentials'] = true;

    dio.interceptors.add(CookieManager(cookieJar));

    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );
  }

  final Dio _dio;

  /// @description 설정된 Dio 인스턴스를 반환한다.
  /// @returns [Dio] 쿠키·401 인터셉터가 적용된 Dio 인스턴스
  Dio get dio => _dio;

  /// @description CookieManager 인터셉터 등록 여부를 반환한다.
  /// @returns [bool] CookieManager 등록 시 true
  bool get hasCookieInterceptor =>
      _dio.interceptors.any((i) => i is CookieManager);
}
