import 'package:flutter_test/flutter_test.dart';
import 'package:smart_agri_price_tracker/main.dart';

void main() {
  testWidgets('Home page loads test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SmartAgriPriceTracker());

    // Verify that the title is present.
    expect(find.text('SAPT Mobile'), findsOneWidget);
  });
}
