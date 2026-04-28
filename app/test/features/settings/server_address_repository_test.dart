/// @description ServerAddressRepository 단위 테스트
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.27
/// @version 1.0.0
/// @see ServerAddressRepository
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:app/features/settings/server_address_repository.dart';

import 'server_address_repository_test.mocks.dart';

@GenerateMocks([FlutterSecureStorage])
void main() {
  group('FlutterSecureServerAddressRepository', () {
    late MockFlutterSecureStorage mockStorage;
    late FlutterSecureServerAddressRepository repository;

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
      repository = FlutterSecureServerAddressRepository(storage: mockStorage);
    });

    group('save', () {
      test('server_address 키로 주소를 저장한다', () async {
        // Arrange
        when(mockStorage.write(
          key: anyNamed('key'),
          value: anyNamed('value'),
        )).thenAnswer((_) async {});
        // Act
        await repository.save('http://nas.local:3000');
        // Assert
        final captured = verify(mockStorage.write(
          key: captureAnyNamed('key'),
          value: captureAnyNamed('value'),
        )).captured;
        expect(captured[0], 'server_address');
        expect(captured[1], 'http://nas.local:3000');
      });
    });

    group('load', () {
      test('저장된 주소를 반환한다', () async {
        // Arrange
        when(mockStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => 'http://nas.local:3000');
        // Act
        final result = await repository.load();
        // Assert
        expect(result, 'http://nas.local:3000');
        verify(mockStorage.read(key: 'server_address')).called(1);
      });

      test('저장된 값이 없으면 null을 반환한다', () async {
        // Arrange
        when(mockStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => null);
        // Act
        final result = await repository.load();
        // Assert
        expect(result, isNull);
      });
    });
  });
}
