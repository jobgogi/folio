/// @description 로컬 저장소 및 공유 HTTP 클라이언트 Provider 모음
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.28
/// @version 1.0.0
/// @see ServerAddressRepository, DioClient
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// @description flutter_secure_storage에서 저장된 서버 주소를 읽어 반환한다.
/// @returns [String] 저장된 서버 주소, 없으면 빈 문자열
final savedServerAddressProvider = FutureProvider<String>((ref) async {
  const storage = FlutterSecureStorage();
  return await storage.read(key: 'server_address') ?? '';
});

/// @description 앱 전역에서 공유하는 CookieJar — 네이티브 플랫폼 전용.
/// @returns [CookieJar]
final cookieJarProvider = Provider<CookieJar>((_) => CookieJar());

/// @description 공유 Dio 인스턴스를 반환한다.
/// Web: 브라우저가 쿠키를 관리하므로 withCredentials만 설정.
/// Native: CookieJar + CookieManager로 쿠키를 직접 관리.
/// @returns [Dio]
final sharedDioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  if (kIsWeb) {
    dio.options.extra['withCredentials'] = true;
  } else {
    final jar = ref.watch(cookieJarProvider);
    dio.interceptors.add(CookieManager(jar));
  }
  return dio;
});
