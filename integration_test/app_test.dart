import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:divesea/app.dart';
import 'package:divesea/data/demo_repository.dart';
import 'package:divesea/domain/models.dart';
import 'package:divesea/state/app_state.dart';
import 'package:divesea/features/discover/search_screen.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('capture 30 Pixso states and verify marketplace flows', (
    tester,
  ) async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SharedPreferences.setMockInitialValues({});
    final state = AppState(await DemoRepository.open());
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      DiveSeaApp(
        state: state,
        navigatorKey: navigator,
        initialRoute: '/onboarding',
      ),
    );
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    const screens = {
      '1-onboarding-01': '/onboarding?step=0',
      '2-onboarding-02': '/onboarding?step=1',
      '3-onboarding-03': '/onboarding?step=2',
      '4-get-started': '/onboarding?step=3',
      '5-choose-wallet': '/wallet',
      '6-open-wallet': '/wallet?prompt=true',
      '7-create-account': '/register',
      '8-create-account-active': '/register?filled=true',
      '9-login-account': '/login',
      '10-login-account-active': '/login?filled=true',
      '11-home': '/home',
      '12-home-v2': '/home?view=trending',
      '13-best-sellers': '/sellers',
      '14-product': '/product',
      '15-detail': '/detail',
      '16-bid': '/detail?sheet=menu',
      '17-place-bid': '/detail?sheet=bid',
      '18-search': '/search',
      '19-search-active': '/search?q=nue',
      '20-notification': '/notifications?loading=true',
      '21-notification': '/notifications',
      '22-no-recents': '/notifications?empty=true',
      '23-profile-collection': '/profile',
      '24-profile-activity': '/profile?tab=activity',
      '25-side-profile-options': '/profile?menu=cover',
      '27-side-profile-options-v2': '/profile?menu=account',
      '28-add': '/home?add=true',
      '29-upload': '/upload',
      '30-edit-profile': '/edit-profile',
      '31-setting': '/settings',
    };
    Future<void> open(String route, {bool loading = false}) async {
      navigator.currentState!.pushNamedAndRemoveUntil(route, (_) => false);
      // Progress indicator is intentionally animated in the loading reference.
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 150));
      }
      if (!loading) await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: route);
    }

    if (const bool.fromEnvironment('CAPTURE', defaultValue: true)) {
      for (final entry in screens.entries) {
        await open(entry.value, loading: entry.key == '20-notification');
        await binding.takeScreenshot(entry.key);
      }
    }
    await open('/register');
    tester.testTextInput.register();
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
    expect(find.text('Enter your full name'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'Demo Collector');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'collector@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(2), 'DiveSea2026!');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Register'));
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
    expect(state.signedIn, isTrue);
    await open('/sellers');
    await tester.tap(find.text('Follow').first);
    await tester.pumpAndSettle();
    expect(state.following, contains('Alexy'));
    await open('/search');
    await tester.enterText(find.byKey(const Key('search-input')), 'NuEvey');
    await tester.pumpAndSettle();
    expect(find.byType(SearchResult), findsOneWidget);
    expect(find.text('Sun-Glass'), findsNothing);
    await tester.tap(
      find.descendant(
        of: find.byType(SearchResult),
        matching: find.text('NuEvey'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Favorite'));
    await tester.pumpAndSettle();
    expect(state.favorites, contains('nu'));
    await open('/detail?sheet=bid');
    await tester.enterText(find.byKey(const Key('bid-amount')), '0.5');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    expect(find.text('Minimum bid is 1.76 ETH.'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('bid-amount')), '2.0');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    expect(state.balance, 30.06);
    expect(state.currentBid(nfts.first), 2.0);
    await open('/edit-profile');
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Updated Collector',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.ensureVisible(find.text('Save Changes'));
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
    expect(state.name, 'Updated Collector');
    final data = await rootBundle.load('assets/images/onboarding-3.png');
    await state.publish('Emulator Art', 1.3, data.buffer.asUint8List());
    await open('/profile');
    expect(find.text('Emulator Art'), findsOneWidget);
    expect(state.notices.first.title, contains('Published'));
    expect(tester.takeException(), isNull);
  });
}
