import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/cupertino.dart' show User;
import 'package:flutter/foundation.dart';
import 'package:test/expect.dart';

@immutable
class AuthUser {
  final String? email;
  final bool isEmailVerified;
  const AuthUser({required this.email, required this.isEmailVerified});

  factory AuthUser.fromFirebase(User user) =>
      AuthUser(email: user.email, isEmailVerified: user.emailVerified);
}
