import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:support_hub/app.dart';
import 'package:support_hub/features/splash/presentation/splash_screen.dart';

void main() {
  testWidgets('renders the support hub shell', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SupportHubApp()));
    await tester.pump();

    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
