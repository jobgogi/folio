/// @description 서버 주소를 flutter_secure_storage에 저장·조회하는 저장소
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.27
/// @version 1.0.0
/// @see ServerAddressNotifier
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class ServerAddressRepository {
  /// @description 서버 주소를 저장한다.
  /// @param address 서버 주소 (예: http://nas.local:3000)
  Future<void> save(String address);

  /// @description 저장된 서버 주소를 반환한다.
  /// @returns [String?] 저장된 주소, 없으면 null
  Future<String?> load();
}

class FlutterSecureServerAddressRepository implements ServerAddressRepository {
  FlutterSecureServerAddressRepository({required FlutterSecureStorage storage})
      : _storage = storage;

  final FlutterSecureStorage _storage;
  static const _key = 'server_address';

  @override
  Future<void> save(String address) =>
      _storage.write(key: _key, value: address);

  @override
  Future<String?> load() => _storage.read(key: _key);
}
