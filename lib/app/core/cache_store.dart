import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PublicCacheStore {
  PublicCacheStore(this._prefs);

  final SharedPreferences _prefs;

  Future<void> save(String key, Map<String, dynamic> value) async {
    final payload = <String, dynamic>{
      'cachedAt': DateTime.now().toIso8601String(),
      'data': value,
    };
    await _prefs.setString(key, jsonEncode(payload));
  }

  Map<String, dynamic>? read(String key, {Duration? maxAge}) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final cachedAt = DateTime.parse(decoded['cachedAt'] as String);
    if (maxAge != null && DateTime.now().difference(cachedAt) > maxAge) {
      return null;
    }

    return decoded['data'] as Map<String, dynamic>;
  }
}

class StudentCacheStore {
  final Map<String, _CacheValue> _memory = {};

  void save(String key, Map<String, dynamic> value) {
    _memory[key] = _CacheValue(
      value: value,
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
    );
  }

  Map<String, dynamic>? read(String key) {
    final cached = _memory[key];
    if (cached == null) return null;
    if (DateTime.now().isAfter(cached.expiresAt)) {
      _memory.remove(key);
      return null;
    }

    return cached.value;
  }

  void clear() => _memory.clear();
}

class _CacheValue {
  const _CacheValue({required this.value, required this.expiresAt});

  final Map<String, dynamic> value;
  final DateTime expiresAt;
}
