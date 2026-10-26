import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:divesea/data/demo_repository.dart';
import 'package:divesea/domain/models.dart';
import 'package:divesea/state/app_state.dart';

void main() {
  late AppState state;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    state = AppState(await DemoRepository.open());
  });
  test(
    'bid validation rejects invalid amounts without changing balance',
    () async {
      for (final amount in [double.nan, double.infinity, -1.0, 1.75, 100.0]) {
        await expectLater(
          state.placeBid(nfts.first, amount),
          throwsArgumentError,
        );
      }
      expect(state.balance, 32.06);
      expect(state.bids, isEmpty);
    },
  );
  test('rebidding only reserves the increase and persists history', () async {
    await state.placeBid(nfts.first, 2.0);
    expect(state.balance, 30.06);
    await state.updateProfile('Renamed Collector', state.email, null);
    await state.placeBid(nfts.first, 2.1);
    expect(state.balance, 29.96);
    expect(state.history(nfts.first).first.amount, 2.1);
    final reloaded = AppState(await DemoRepository.open());
    expect(reloaded.balance, 29.96);
    expect(reloaded.currentBid(nfts.first), 2.1);
    expect(reloaded.notices.first.title, contains('Bid placed'));
  });
  test('profile, follows, favorites and wallet survive a restart', () async {
    await state.updateProfile('Test Collector', 'test@example.com', null);
    await state.toggleFavorite('nu');
    await state.toggleFollow('Alexy');
    await state.connectWallet('Metamask');
    await state.signIn('test@example.com');
    final reloaded = AppState(await DemoRepository.open());
    expect(reloaded.name, 'Test Collector');
    expect(reloaded.favorites, contains('nu'));
    expect(reloaded.following, contains('Alexy'));
    expect(reloaded.wallet, 'Metamask');
    expect(reloaded.signedIn, isTrue);
    await reloaded.signOut();
    expect(reloaded.signedIn, isFalse);
    expect(reloaded.wallet, isNull);
  });
  test(
    'published images and notification clearing survive a restart',
    () async {
      await state.publish('Local Artwork', 1.2, Uint8List.fromList([1, 2, 3]));
      final reloaded = AppState(await DemoRepository.open());
      expect(reloaded.uploads.single.name, 'Local Artwork');
      expect(reloaded.uploads.single.bytes, [1, 2, 3]);
      await reloaded.clearNotices();
      expect(AppState(await DemoRepository.open()).notices, isEmpty);
    },
  );
}
