import 'package:flutter_test/flutter_test.dart';
import 'package:skill_hub_mobile_app/screens/login_screen.dart';

void main() {
  test('validates email addresses', () {
    expect(validateEmail('hr@company.com'), isNull);
    expect(validateEmail('not-an-email'), isNotNull);
    expect(validateEmail(''), isNotNull);
  });
}
