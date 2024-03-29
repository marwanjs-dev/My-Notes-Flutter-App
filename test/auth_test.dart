// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:mynotes/Services/auth/auth_exceptions.dart';
// import 'package:mynotes/Services/auth/auth_provider.dart';
// import 'package:mynotes/Services/auth/auth_user.dart';
// import 'package:test/test.dart';

// void main() {
//   group('Mock Authentication', () {
//     final testProvider = MockAuthProvider();
//     test("shouldn't be initialized to begin with", () {
//       expect(testProvider.isInitialized, false);
//     });

//     test("cannot log out if not initialized", () {
//       expect(testProvider.logOut(),
//           throwsA(const TypeMatcher<NotInitializationException>()));
//     });

//     test("shall be able to initialize", () async {
//       await testProvider.initialize();
//       expect(testProvider.isInitialized, true);
//     });

//     test("User should be Null after initialization", () {
//       expect(testProvider.currentUser, null);
//     });

//     test(
//       "should not be able to initialize in less than 2 seconds",
//       () async {
//         await testProvider.initialize();
//         expect(testProvider.isInitialized, true);
//       },
//       timeout: const Timeout(Duration(seconds: 2)),
//     );

//     test("createUser should delegate to logIn function", () async {
//       final badEmailUser =
//           testProvider.createUser(email: "foo@bar.com", password: "foobar");
//       expect(badEmailUser,
//           throwsA(const TypeMatcher<UserNotFoundAuthException>()));

//       final badPasswordUser = testProvider.createUser(
//           email: "mirocc4@gmail.com", password: "anypassword");

//       expect(badPasswordUser,
//           throwsA(const TypeMatcher<WrongPasswordAuthException>()));

//       final user = await testProvider.createUser(email: "foo", password: "bar");

//       expect(testProvider.currentUser, user);
//       expect(user.isEmailVerified, false);
//     });

//     test("Logged in user should be able to get verified", () {
//       testProvider.sendEmailVerification();
//       final user = testProvider.currentUser;
//       expect(user, isNotNull);
//       expect(user?.isEmailVerified, true);
//     });

//     test("should be able to log out and log in", () async {
//       await testProvider.logOut();
//       await testProvider.logIn(
//           email: "mirocc4@gmail.com", password: "maro55555");
//       final user = testProvider.currentUser;
//       expect(user, isNotNull);
//     });
//   });
// }

// class NotInitializationException implements Exception {}

// class MockAuthProvider implements AuthProvider {
//   AuthUser? _user;
//   var _isInitialized = false;
//   bool get isInitialized => _isInitialized;

//   @override
//   Future<AuthUser> createUser({
//     required String email,
//     required String password,
//   }) async {
//     if (!isInitialized) throw NotInitializationException();
//     await Future.delayed(const Duration(seconds: 2));
//     return logIn(
//       email: email,
//       password: password,
//     );
//   }

//   @override
//   // TODO: implement currentUser
//   AuthUser? get currentUser => _user;

//   @override
//   Future<void> initialize() async {
//     await Future.delayed(const Duration(seconds: 1));
//     _isInitialized = true;
//   }

//   // @override
//   // Future<AuthUser> logIn({
//   //   required String email,
//   //   required String password,
//   // }) {
//   //   if (!isInitialized) throw NotInitializationException();
//   //   if (email == "foo@bar.com") throw UserNotFoundAuthException();
//   //   if (password == "anypassword") throw WrongPasswordAuthException();
//   //   // const user = AuthUser(isEmailVerified: false);
//   //   // _user = user;
//   //   // return Future.value(user);
//   // }

//   @override
//   Future<void> logOut() async {
//     if (!isInitialized) throw NotInitializationException();
//     if (_user == null) throw UserNotFoundAuthException();
//     await Future.delayed(const Duration(seconds: 1));
//     _user = null;
//   }

//   // @override
//   // Future<void> sendEmailVerification() async {
//   //   if (!isInitialized) throw NotInitializationException();
//   //   final user = _user;
//   //   if (user == null) throw UserNotFoundAuthException();
//   //   const newUser = AuthUser(isEmailVerified: true);
//   //   _user = newUser;
//   // }
// }
