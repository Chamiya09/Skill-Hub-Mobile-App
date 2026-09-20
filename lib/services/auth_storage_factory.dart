import 'auth_storage.dart';
import 'auth_storage_native.dart'
    if (dart.library.html) 'auth_storage_web.dart'
    as implementation;

AuthStorage createAuthStorage() => implementation.createAuthStorage();
