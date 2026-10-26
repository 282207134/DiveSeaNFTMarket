import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'state/app_state.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/wallet/wallet_screen.dart';
import 'features/auth/auth_screen.dart';
import 'features/market/home_screen.dart';
import 'features/market/sellers_screen.dart';
import 'features/market/detail_screen.dart';
import 'features/discover/search_screen.dart';
import 'features/activity/notifications_screen.dart';
import 'features/create/upload_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/profile/edit_profile_screen.dart';
import 'features/profile/settings_screen.dart';

class DiveSeaApp extends StatelessWidget {
  const DiveSeaApp({
    super.key,
    required this.state,
    this.navigatorKey,
    this.initialRoute,
  });
  final AppState state;
  final GlobalKey<NavigatorState>? navigatorKey;
  final String? initialRoute;
  @override
  Widget build(BuildContext context) => AppScope(
    state: state,
    child: MaterialApp(
      title: 'DiveSea',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      navigatorKey: navigatorKey,
      initialRoute:
          initialRoute ??
          (state.signedIn
              ? '/home'
              : state.onboarded
              ? '/login'
              : '/onboarding'),
      builder: (context, child) => ColoredBox(
        color: const Color(0xFFE6E8EC),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ClipRect(child: child!),
          ),
        ),
      ),
      onGenerateInitialRoutes: (route) => [_route(RouteSettings(name: route))],
      onGenerateRoute: _route,
    ),
  );
  Route<dynamic> _route(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? '/home'), q = uri.queryParameters;
    final page = switch (uri.path) {
      '/onboarding' => OnboardingScreen(
        step: (int.tryParse(q['step'] ?? '0') ?? 0).clamp(0, 3),
      ),
      '/wallet' => WalletScreen(
        prompt: q['prompt'] == 'true',
        returnAfter: q['return'] == 'true',
      ),
      '/register' => AuthScreen(filled: q['filled'] == 'true'),
      '/login' => AuthScreen(login: true, filled: q['filled'] == 'true'),
      '/home' => HomeScreen(
        trending: q['view'] == 'trending',
        add: q['add'] == 'true',
      ),
      '/sellers' => const SellersScreen(),
      '/product' => ProductScreen(id: q['id'] ?? 'sun'),
      '/detail' => DetailScreen(id: q['id'] ?? 'sun', sheet: q['sheet']),
      '/search' => SearchScreen(query: q['q'] ?? ''),
      '/notifications' => NotificationsScreen(
        empty: q['empty'] == 'true',
        loading: q['loading'] == 'true',
      ),
      '/upload' => UploadScreen(multiple: q['multiple'] == 'true'),
      '/profile' => ProfileScreen(
        activity: q['tab'] == 'activity',
        menu: q['menu'],
        favorites: q['favorites'] == 'true',
      ),
      '/edit-profile' => const EditProfileScreen(),
      '/settings' => const SettingsScreen(),
      _ => const HomeScreen(),
    };
    return MaterialPageRoute<dynamic>(settings: settings, builder: (_) => page);
  }
}
