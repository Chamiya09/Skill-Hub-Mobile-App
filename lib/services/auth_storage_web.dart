// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import 'auth_storage.dart';

AuthStorage createAuthStorage() => _WebAuthStorage();

class _WebAuthStorage implements AuthStorage {
  @override
  Future<String?> read(String key) async =>
      html.window.localStorage[key];

  @override
  Future<void> write(String key, String? value) async {
    if (value == null) {
      html.window.localStorage.remove(key);
    } else {
      html.window.localStorage[key] = value;
    }
  }

  @override
  Future<void> delete(String key) async {
    html.window.localStorage.remove(key);
  }
}
