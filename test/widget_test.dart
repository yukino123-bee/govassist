import 'package:flutter_test/flutter_test.dart';
import 'package:govassist/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GovAssistApp());
    
    // Verify that the app builds without throwing exceptions
    expect(find.byType(GovAssistApp), findsOneWidget);
  });
}
