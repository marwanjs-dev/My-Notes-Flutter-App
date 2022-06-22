import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mynotes/Constants/routes.dart';
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

// class HomePage extends StatelessWidget {
//   const HomePage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: Firebase.initializeApp(
//         options: DefaultFirebaseOptions.web,
//       ),
//       builder: (context, snapshot) {
//         switch (snapshot.connectionState) {
//           case ConnectionState.done:
//             final user = FirebaseAuth.instance.currentUser;
//             if (user != null) {
//               if (user.emailVerified) {
//                 return const LoginView();
//               } else {
//                 return const VerifyEmailView();
//               }
//             } else {
//               return const LoginView();
//             }
//           default:
//             return const CircularProgressIndicator();
//         }
//       },
//     );
//   }
// }

// class NotesView extends StatefulWidget {
//   const NotesView({Key? key}) : super(key: key);

//   @override
//   State<NotesView> createState() => _NotesViewState();
// }

// class _NotesViewState extends State<NotesView> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("MainUI")),
//       body: const Text("Hello world!"),
//     );
//   }
// }
