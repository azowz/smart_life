
import 'package:final_project/CreateAccForm/ForgetPasswordPage.dart';
import 'package:final_project/CreateAccForm/HomePage.dart';
import 'package:final_project/CreateAccForm/SignInPage.dart';
import 'package:final_project/CreateAccForm/SignUpPage.dart';
import 'package:final_project/HomePage1/homePage1/HomaPageFirst.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore package
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();  

  // Enable Firestore settings
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true, // Enables offline persistence
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED, // Set cache size to unlimited
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life-Organizer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/signin': (context) => const SignInPage(),
        '/signup': (context) => const SignUpPage(),
        '/homePageC': (context) => const HomePageFirst(),
        '/forgetpassword': (context) => const ForgetPasswordPage(),

      },
    );
  }
}
