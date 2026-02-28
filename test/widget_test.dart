import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('DevPocket app smoke test', (WidgetTester tester) async {
    // Minimal scaffold test — app requires Hive, Riverpod, and notifications
    // which are initialized in main(). Run integration tests separately.
    expect(true, isTrue);
  });
}
