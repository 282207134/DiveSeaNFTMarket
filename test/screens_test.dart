import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:divesea/app.dart';
import 'package:divesea/data/demo_repository.dart';
import 'package:divesea/state/app_state.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await (FontLoader('DMSans')
          ..addFont(rootBundle.load('assets/fonts/DMSans-Regular.ttf'))
          ..addFont(rootBundle.load('assets/fonts/DMSans-Bold.ttf')))
        .load();
    await (FontLoader('Poppins')
          ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'))
          ..addFont(rootBundle.load('assets/fonts/Poppins-SemiBold.ttf')))
        .load();
  });

  for (final size in [
    const Size(375, 812),
    const Size(320, 640),
    const Size(480, 900),
  ]) {
    for (final route in [
      '/onboarding',
      '/wallet',
      '/register',
      '/login',
      '/home',
      '/home?view=trending',
      '/sellers',
      '/product',
      '/detail',
      '/search',
      '/search?q=nue',
      '/notifications',
      '/notifications?empty=true',
      '/profile',
      '/profile?tab=activity',
      '/upload',
      '/edit-profile',
      '/settings',
    ]) {
      testWidgets('$route at $size', (tester) async {
        SharedPreferences.setMockInitialValues({});
        final state = AppState(await DemoRepository.open());
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(DiveSeaApp(state: state, initialRoute: route));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
}
