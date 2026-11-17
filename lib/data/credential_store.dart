import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../domain/image_item.dart';
import '../core/app_exception.dart';

class CredentialStore {
  final FlutterSecureStorage storage;
  CredentialStore({FlutterSecureStorage? storage}) : storage = storage ?? const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true));
  Future<String> read(String key) async => await storage.read(key: key) ?? '';
  Future<void> write(String key, String value) async {
    if (value.trim().isEmpty) { await storage.delete(key: key); }
    else { await storage.write(key: key, value: value.trim()); }
  }
  Future<String> requireKey(SourceId source) async {
    final value = await read(source.name);
    if (value.isEmpty) throw const AppException(FailureKind.missingKey);
    return value;
  }
}
