import 'package:web/web.dart' as web;

import 'auth_storage.dart';

AuthStorage createAuthStorage() => _WebAuthStorage();

class _WebAuthStorage implements AuthStorage {
  @override
  Future<String?> read(String key) async =>
      web.window.localStorage.getItem(key);

  @override
  Future<void> write(String key, String? value) async {
    if (value == null) {
      web.window.localStorage.removeItem(key);
    } else {
      web.window.localStorage.setItem(key, value);
    }
  }

  @override
  Future<void> delete(String key) async {
    web.window.localStorage.removeItem(key);
  }
}
