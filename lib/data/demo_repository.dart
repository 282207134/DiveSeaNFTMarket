import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Stores one local snapshot. Credentials and private keys are never stored.
class DemoRepository {
  DemoRepository(this.preferences);
  final SharedPreferences preferences;
  static const key = 'divesea.v1';
  static Future<DemoRepository> open() async =>
      DemoRepository(await SharedPreferences.getInstance());
  Map<String, dynamic> read() {
    final raw = preferences.getString(key);
    if (raw == null) return {};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } on FormatException {
      return {};
    }
  }

  Future<void> save(Map<String, dynamic> snapshot) async {
    if (!await preferences.setString(key, jsonEncode(snapshot))) {
      throw StateError('Your changes could not be saved.');
    }
  }
}
