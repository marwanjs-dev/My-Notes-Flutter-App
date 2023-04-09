import 'package:flutter/material.dart';
import 'package:mynotes/Constants/routes.dart';
import 'package:mynotes/Services/auth/auth_provider.dart';
import 'package:mynotes/Services/auth/auth_service.dart';
import 'package:mynotes/Views/home_page.dart';
import 'package:mynotes/Views/login_view.dart';
import 'package:mynotes/Views/note/create_update_notes_view.dart';
import 'package:mynotes/Views/register_view.dart';
import 'package:mynotes/Views/verify_email_view.dart';
import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'My App',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: const LoginView(),
    routes: {
      loginRoute: (context) => const LoginView(),
      registerRoute: (context) => const RegisterView(),
      homeRoute: (context) => const HomePage2(),
      verifyEmailRoute: (context) => const VerifyEmailView(),
      createUpdateNotesViewRoute: (context) => const CreateUpdateNotesView(),
    },
  ));
}
