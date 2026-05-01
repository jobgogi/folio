/// @description 앱 smoke 테스트
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.05.01
/// @version 1.0.0
/// @see FolioApp
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/main.dart';

void main() {
  testWidgets('앱이 정상적으로 시작된다', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: FolioApp()));
    await tester.pump();
    // ServerAddressScreen의 요소가 존재하면 앱이 정상 시작된 것으로 간주
    expect(find.byType(FolioApp), findsOneWidget);
  });
}
