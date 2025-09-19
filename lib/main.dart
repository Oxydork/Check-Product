import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_new/app/controllers/auth_controller.dart';
import 'package:qr_code_new/app/modules/loading/loadingscreen.dart';
import 'package:qr_code_new/firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //inisialisasi firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //inisialiasasi supabase
  await Supabase.initialize(
    url: "https://qrisvyccbwybkrmjkdcj.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFyaXN2eWNjYnd5YmtybWprZGNqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQzMTIwMTAsImV4cCI6MjA2OTg4ODAxMH0.dEaCtgWwQmXb3qDTggy5_LQXLgol2sbAxLtfPl4n39Q",
  );

  Get.put(AuthController(), permanent: true);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final firebase_auth.FirebaseAuth auth = firebase_auth.FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    // auto login -> firebase authenti
    return StreamBuilder<firebase_auth.User?>(
      stream: auth.authStateChanges(),
      builder: (context, snapAuth) {
        if (snapAuth.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        }
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Barcode",
          initialRoute: snapAuth.hasData ? Routes.HOME : Routes.LOGIN,
          getPages: AppPages.routes,
        );
      },
    );
  }
}
