import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../data/demo_repository.dart';
import '../domain/models.dart';

class AppState extends ChangeNotifier {
  AppState(this.repository) {
    final d = repository.read();
    name = d['name'] as String? ?? 'Alex Ca.';
    email = d['email'] as String? ?? 'alex@divesea.app';
    onboarded = d['onboarded'] as bool? ?? false;
    signedIn = d['signedIn'] as bool? ?? false;
    wallet = d['wallet'] as String?;
    balance = (d['balance'] as num?)?.toDouble() ?? 32.06;
    favorites = Set<String>.from(d['favorites'] as List? ?? []);
    following = Set<String>.from(
      d['following'] as List? ?? ['TrevorP', 'KayaZ'],
    );
    coverVisible = d['coverVisible'] as bool? ?? true;
    for (final entry in (d['bids'] as Map<String, dynamic>? ?? {}).entries) {
      bids[entry.key] = (entry.value as List)
          .map((e) => Bid.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    if (d.containsKey('notices')) {
      notices = (d['notices'] as List)
          .map(
            (e) => MarketNotice.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    }
    for (final item in d['uploads'] as List? ?? []) {
      final m = Map<String, dynamic>.from(item as Map);
      uploads.add(
        Nft(
          id: m['id'],
          name: m['name'],
          creator: m['creator'],
          image: 'sun-glass',
          price: (m['price'] as num).toDouble(),
          bytes: base64Decode(m['bytes']),
        ),
      );
    }
    if (d['avatar'] != null) avatar = base64Decode(d['avatar'] as String);
    if (d['cover'] != null) cover = base64Decode(d['cover'] as String);
  }
  final DemoRepository repository;
  late String name, email;
  late bool onboarded, signedIn, coverVisible;
  late double balance;
  String? wallet;
  Uint8List? avatar, cover;
  late Set<String> favorites, following;
  final Map<String, List<Bid>> bids = {};
  final List<Nft> uploads = [];
  List<MarketNotice> notices = [
    MarketNotice(
      'ETH received',
      '1.25 ETH received',
      DateTime(2026, 10, 26, 23, 30),
    ),
    MarketNotice(
      'New bid · Space shipp...',
      '0.002 ETH',
      DateTime(2026, 10, 26, 22, 30),
      nftId: 'nu',
    ),
    MarketNotice(
      'ETH received',
      '0.81 ETH received',
      DateTime(2026, 10, 25, 21, 30),
    ),
    MarketNotice(
      'New bid · Rotation',
      '0.002 ETH',
      DateTime(2026, 10, 25, 23, 44),
      nftId: 'rotation',
    ),
    MarketNotice(
      'New bid · Routine',
      '0.002 ETH',
      DateTime(2026, 10, 24, 14, 17),
      nftId: 'orbit',
    ),
  ];
  List<Nft> get allNfts => [...uploads, ...nfts];
  Nft nft(String? id) =>
      allNfts.firstWhere((n) => n.id == id, orElse: () => nfts.first);
  double currentBid(Nft nft) => bids[nft.id]?.first.amount ?? nft.price;
  double minimumBid(Nft nft) => ((currentBid(nft) * 100).round() + 1) / 100;
  List<Bid> history(Nft nft) =>
      bids[nft.id] ??
      [
        Bid('Repo', 'seller-7', 1.55, DateTime(2026, 10, 25, 12, 8)),
        Bid('Travo', 'seller-2', 1.40, DateTime(2026, 10, 24, 12, 8)),
        Bid('Jennifer', 'seller-4', 1.30, DateTime(2026, 10, 24, 6, 8)),
      ];
  Future<void> _commit() async {
    notifyListeners();
    await repository.save({
      'name': name,
      'email': email,
      'onboarded': onboarded,
      'signedIn': signedIn,
      'wallet': wallet,
      'balance': balance,
      'favorites': favorites.toList(),
      'following': following.toList(),
      'coverVisible': coverVisible,
      'avatar': avatar == null ? null : base64Encode(avatar!),
      'cover': cover == null ? null : base64Encode(cover!),
      'bids': bids.map(
        (k, v) => MapEntry(k, v.map((b) => b.toJson()).toList()),
      ),
      'notices': notices.map((n) => n.toJson()).toList(),
      'uploads': uploads
          .map(
            (n) => {
              'id': n.id,
              'name': n.name,
              'creator': n.creator,
              'price': n.price,
              'bytes': base64Encode(n.bytes!),
            },
          )
          .toList(),
    });
  }

  Future<void> finishOnboarding() async {
    onboarded = true;
    await _commit();
  }

  Future<void> signIn(String value, {String? fullName}) async {
    email = value.trim();
    if (fullName != null) name = fullName.trim();
    signedIn = true;
    await _commit();
  }

  Future<void> signOut() async {
    signedIn = false;
    wallet = null;
    await _commit();
  }

  Future<void> connectWallet(String value) async {
    wallet = value;
    await _commit();
  }

  Future<void> updateProfile(
    String fullName,
    String value,
    Uint8List? image,
  ) async {
    name = fullName.trim();
    email = value.trim();
    avatar = image;
    await _commit();
  }

  Future<void> toggleFavorite(String id) async {
    if (!favorites.add(id)) favorites.remove(id);
    await _commit();
  }

  Future<void> toggleFollow(String handle) async {
    if (!following.add(handle)) following.remove(handle);
    await _commit();
  }

  Future<void> setCoverVisible(bool visible) async {
    coverVisible = visible;
    await _commit();
  }

  Future<void> replaceCover(Uint8List bytes) async {
    cover = bytes;
    coverVisible = true;
    await _commit();
  }

  Future<void> clearNotices() async {
    notices.clear();
    await _commit();
  }

  Future<void> placeBid(Nft nft, double amount) async {
    if (!amount.isFinite || amount < minimumBid(nft)) {
      throw ArgumentError(
        'Minimum bid is ${minimumBid(nft).toStringAsFixed(2)} ETH.',
      );
    }
    final previous = bids[nft.id]?.first;
    final refund = previous?.mine == true ? previous!.amount : 0.0;
    if (amount > balance + refund) {
      throw ArgumentError('Insufficient demo balance.');
    }
    balance = double.parse((balance + refund - amount).toStringAsFixed(2));
    bids[nft.id] = [
      Bid(name, 'seller-1', amount, DateTime.now(), mine: true),
      ...history(nft),
    ];
    notices.insert(
      0,
      MarketNotice(
        'Bid placed · ${nft.name}',
        '${amount.toStringAsFixed(2)} ETH reserved',
        DateTime.now(),
        nftId: nft.id,
      ),
    );
    await _commit();
  }

  Future<void> publish(String title, double price, Uint8List bytes) async {
    final nft = Nft(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      name: title.trim(),
      creator: name,
      image: 'sun-glass',
      price: price,
      bytes: bytes,
    );
    uploads.insert(0, nft);
    notices.insert(
      0,
      MarketNotice(
        'Published · ${nft.name}',
        'Added to your collection',
        DateTime.now(),
        nftId: nft.id,
      ),
    );
    await _commit();
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);
  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
