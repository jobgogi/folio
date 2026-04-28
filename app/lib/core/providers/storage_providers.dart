/// @description 로컬 저장소 공통 Provider 모음
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.28
/// @version 1.0.0
/// @see ServerAddressRepository
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// @description flutter_secure_storage에서 저장된 서버 주소를 읽어 반환한다.
/// @returns [String] 저장된 서버 주소, 없으면 빈 문자열
final savedServerAddressProvider = FutureProvider<String>((ref) async {
  const storage = FlutterSecureStorage();
  return await storage.read(key: 'server_address') ?? '';
});
