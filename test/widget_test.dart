import 'package:flutter_test/flutter_test.dart';
import 'package:skill_hub_mobile_app/main.dart';

void main() {
  testWidgets('candidate bottom navigation switches screens', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Hello, Chamod!'), findsOneWidget);
    expect(find.text('AI-POWERED RECRUITMENT'), findsOneWidget);
    expect(find.text('Verified roles'), findsOneWidget);

    await tester.tap(find.text('Account'));
    await tester.pump();

    expect(find.text('Manage your digital CV and account settings.'), findsOneWidget);
  });
}
