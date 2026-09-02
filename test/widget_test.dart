import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jalan_hidup_wni/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: JalanHidupApp()),
    );
    expect(find.text('Jalan Hidup WNI'), findsOneWidget);
  });
}
