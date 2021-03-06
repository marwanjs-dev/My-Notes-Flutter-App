import 'package:flutter/material.dart';
import 'package:mynotes/Constants/routes.dart';
import 'package:mynotes/Services/auth/auth_provider.dart';
import 'package:mynotes/Services/auth/auth_service.dart';
import 'package:mynotes/Views/home_page.dart';
import 'package:mynotes/Views/login_view.dart';
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
      VerifyEmailRoute: (context) => const VerifyEmailView()
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              if (user.isEmailVerified) {
                return const LoginView();
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
