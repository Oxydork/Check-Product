import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';


class AuthController extends GetxController {
  String? uid; // ada auth atau tidak

  late FirebaseAuth auth;

  Future<Map<String, dynamic>> login(String email, String pass) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: pass);
      return {
        "error": false,
        "message": "Berhasil Login",
      };
    } on FirebaseAuthException catch (e) {
      return {
        //error firebase
        "error": true,
        "message": "${e.message}",
      };
    } catch (e) {
      return {
        //error general
        "error": true,
        "message": "Tidak Dapat Login",
      };
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      await auth.signOut();
      return {
        "error": false,
        "message": "Berhasil Logout",
      };
    } on FirebaseAuthException catch (e) {
      return {
        //error firebase
        "error": true,
        "message": "${e.message}",
      };
    } catch (e) {
      return {
        //error general
        "error": true,
        "message": "Tidak Dapat logout",
      };
    }
  }

  @override
  void onInit() {
    auth = FirebaseAuth.instance;
    auth.authStateChanges().listen((event) {
      uid = event?.uid;
    });
    super.onInit();
  }

  
}
