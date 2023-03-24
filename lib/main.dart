import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:un_poco_eco/screens/homeScreen.dart';
import './login_register/landingPage.dart';
import './screens/login.dart';
import './screens/register.dart';
import './utilities/utils.dart';
import './screens/addPostScreen.dart';
import './screens/event_screen.dart';
import './screens/addEventScreen.dart';
import './screens/globalNewsScreen.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: Utils.messengerKey,
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: Colors.green,
        accentColor: Colors.amber[50],
        fontFamily: 'TenorSans',
      ),
      home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Home();
            } else {
              return LandingPage();
            }
          }),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/landing': (context) => LandingPage(),
        '/home': (context) => Home(),
        '/addpost': (context) => AddPost(),
        '/eventScreen': (context) => EventScreen(),
        '/addEvent': (context) => AddEventScreen(),
        '/globalNews': (context) => GlobalNews(),
      },
    );
  }
}
