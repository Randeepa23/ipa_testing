import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:support_hub/core/providers.dart';

void main() {
  test('validates email and password inputs', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final controller = container.read(loginControllerProvider.notifier);

    expect(controller.validateEmail(''), 'Username is required');
    expect(controller.validateEmail('sr'), isNull);

    expect(controller.validatePassword(''), 'Password is required');
    expect(controller.validatePassword('Support@123'), isNull);
  });
}
