import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_swiper/flutter_swiper.dart';
import 'dart:developer' as devtools show log;

import 'package:mynotes/Constants/routes.dart';

class HomePage2 extends StatefulWidget {
  const HomePage2({Key? key}) : super(key: key);

  @override
  State<HomePage2> createState() => _HomePage2State();
}

enum MenuAction { logout }

class _HomePage2State extends State<HomePage2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          actions: [
            PopupMenuButton<MenuAction>(onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogOut = await showLogOutConfirmation(context);
                  print(await shouldLogOut);
                  if (shouldLogOut) {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(loginRoute, (_) => false);
                  }
              }
              devtools.log(value.toString());
            }, itemBuilder: (context) {
              return const [
                PopupMenuItem(
                  value: MenuAction.logout,
                  child: Text('Logout'),
                )
              ];
            })
          ],
        ),
        body: Column(
          children: [
            Container(
              constraints: const BoxConstraints.expand(height: 200),
              child: imageSlider(context),
            ),
          ],
        ));
  }
}

Swiper imageSlider(Context) {
  return Swiper(
    autoplay: true,
    itemBuilder: (BuildContext context, int index) {
      return Image.network(
        "data:image/jpeg;base64,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",
        fit: BoxFit.fitHeight,
      );
    },
    itemCount: 10,
    viewportFraction: 0.8,
    scale: 0.9,
  );
}

Future<bool> showLogOutConfirmation(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("log out"),
        content: const Text("Are you sure you want to log out"),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("log out")),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("cancel"))
        ],
      );
    },
  ).then((value) => value ?? false);
}
