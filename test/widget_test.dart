import 'package:flutter_test/flutter_test.dart';
import 'package:d_calc/main.dart';

void main() {
  testWidgets('App starts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MyDDayApp());
    // '생일 관리' 탭 레이블이 있는지 확인 (BottomNavigationBar)
    expect(find.text('생일 관리'), findsOneWidget);
  });
}
