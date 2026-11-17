import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive/hive.dart';

class ApiCache {
  final Box<String> box;
  ApiCache(this.box);
  String key(String url, Map<String, dynamic> query, String scope) => sha256.convert(
    utf8.encode(jsonEncode([url, query, scope]))).toString();
  Map<String, dynamic>? get(String key) {
    final value = box.get(key);
    if (value == null) return null;
    try {
      final j = jsonDecode(value) as Map;
      final expires = DateTime.parse(j['expires'] as String);
      if (DateTime.now().isAfter(expires)) return null;
      return Map<String, dynamic>.from(j['data'] as Map);
    } catch (_) { return null; }
  }
  Future<void> put(String key, Map<String, dynamic> data) async {
    await box.put(key, jsonEncode({'expires': DateTime.now().add(const Duration(hours: 24))
      .toIso8601String(), 'data': data}));
    while (box.length > 250) { await box.deleteAt(0); }
  }
}
