import 'package:flutter/material.dart';
import 'package:mynotes/Constants/routes.dart';
import 'package:mynotes/Services/auth/auth_exceptions.dart';
import 'package:mynotes/Services/auth/auth_service.dart';
import 'dart:developer' as devtoools show log;

import 'package:mynotes/firebase_options.dart';
import 'package:mynotes/utilities/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  //late means that the variable will have a value later in the code but for now it is null
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login Page")),
      body: Column(
        children: [
          TextField(
            controller: _email,
            decoration: const InputDecoration(
              hintText: "Enter your email address",
            ),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: "Enter your password",
            ),
          ),
          TextButton(
              onPressed: () async {
                final password = _password.text;
                final email = _email.text;
                await AuthService.firebase().initialize();
                try {
                  final userCredentials = await AuthService.firebase().logIn(
                    email: email,
                    password: password,
                  );
                  // devtoools.log(userCredentials.toString());
                  final user = AuthService.firebase().currentUser;
                  if (user?.isEmailVerified ?? false) {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(homeRoute, (route) => false);
                  } else {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        VerifyEmailRoute, (route) => false);
                  }
                } on UserNotFoundAuthException {
                  // ignore: use_build_context_synchronously
                  await showErrorDialog(
                    context,
                    "User not found",
                  );
                } on WrongPasswordAuthException {
                  // ignore: use_build_context_synchronously
                  await showErrorDialog(
                    context,
                    "invalid password",
                  );
                } on GenericAuthException {
                  // ignore: use_build_context_synchronously
                  await showErrorDialog(
                    context,
                    "Authentication Error",
                  );
                }
              },
              child: const Text("Login")),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(registerRoute, (route) => false);
              },
              child: const Text("Not Registered Yet? Register Here "))
        ],
      ),
    );
  }
}
