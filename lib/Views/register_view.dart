import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/Constants/routes.dart';
import 'package:mynotes/utilities/show_error_dialog.dart';
import 'dart:developer' as devtools show log;

import '../firebase_options.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
      appBar: AppBar(
        leading: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            BackButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(loginRoute, (route) => false);
              },
            )
          ],
        ),
        title: const Text("Register page"),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: "Enter your email address",
            ),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: "Enter your password",
            ),
          ),
          TextButton(
              onPressed: () async {
                await Firebase.initializeApp(
                    options: DefaultFirebaseOptions.currentPlatform);

                final email = _email.text;
                final password = _password.text;
                try {
                  final userCredential = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                          email: email, password: password);
                  final user = FirebaseAuth.instance.currentUser;
                  await user?.sendEmailVerification();
                  Navigator.of(context).pushNamed(VerifyEmailRoute);
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'weak-password') {
                    showErrorDialog(context, "weak password");
                  } else if (e.code == 'email-already-in-use') {
                    showErrorDialog(context, "email already in use");
                  } else if (e.code == 'invalid-email') {
                    showErrorDialog(context, "invalid email");
                  } else {
                    showErrorDialog(context, "${e.code}");
                  }
                }
              },
              child: const Text("Register")),
        ],
      ),
    );
  }
}
