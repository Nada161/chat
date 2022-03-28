import 'package:chat/screens/chat_screen.dart';
import 'package:chat/screens/registration_screen.dart';
import 'package:chat/screens/sigin_screen.dart';
import 'package:chat/screens/welcom_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MessageMe app',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
     initialRoute: _auth.currentUser!= null?ChatScreen.screenRoute:WelcomeScreen.screenRoute,
     routes: {
       WelcomeScreen.screenRoute:(context)=>WelcomeScreen(),
       ChatScreen.screenRoute:(context)=>ChatScreen(),
      SignInScreen.screenRoute:(context)=>SignInScreen(),
       RegistrationScreen.screenRoute:(context)=>RegistrationScreen(),
     },
    );

  }
}