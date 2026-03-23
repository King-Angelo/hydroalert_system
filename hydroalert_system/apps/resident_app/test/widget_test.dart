import 'package:flutter_test/flutter_test.dart';

import 'package:resident_app/main.dart';

void main() {
  testWidgets('Resident stub smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ResidentApp());
    expect(find.text('HydroAlert Resident'), findsOneWidget);
  });
}
