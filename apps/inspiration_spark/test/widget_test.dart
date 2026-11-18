import 'package:flutter_test/flutter_test.dart';
import 'package:inspiration_spark/main.dart';

void main() {
  testWidgets('home shows brand and panels', (tester) async {
    await tester.pumpWidget(const InspirationSparkApp());
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('灵感火花'), findsWidgets);
    expect(find.text('灵感'), findsOneWidget);
    expect(find.text('记事'), findsOneWidget);
    expect(find.textContaining('一键设置桌面快捷键'), findsOneWidget);
  });
}
