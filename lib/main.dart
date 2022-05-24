import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mynotes/Views/login_view.dart';
import 'package:mynotes/Views/register_view.dart';
import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'My App',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: const HomePage(),
    routes: {
      '/login/': (context) => const LoginView(),
      '/register/': (context) => const RegisterView(),
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.ios,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            // final user = FirebaseAuth.instance.currentUser;
            // final emailverified = user?.emailVerified ?? false;
            // if (emailverified) {
            //   return const VerifyEmailView();
            // } else {
            //   Navigator.of(context).push(MaterialPageRoute(
            //       builder: (context) => const VerifyEmailView()));
            // }
            // return Text("Done");
            return const LoginView();
          default:
            return CircularProgressIndicator();
        }
      },
    );
  }
}
