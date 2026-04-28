import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ointment_flutter_mvp/main.dart';

void main() {
  testWidgets('Ointment Care opens home screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const OintmentCareApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Ointment Care'), findsOneWidget);
    expect(find.text('今日の軟膏使用量'), findsOneWidget);
    expect(find.text('記録する'), findsOneWidget);
  });
}
