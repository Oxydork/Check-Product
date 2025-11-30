import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  String? uid;
  late FirebaseAuth auth;

  Future<Map<String, dynamic>> login(String email, String pass) async {
    try {
      print("🔐 AuthController: Attempting login...");

      // JANGAN simpan hasil signInWithEmailAndPassword
      // Langsung await tanpa menyimpan ke variable
      await auth.signInWithEmailAndPassword(email: email, password: pass);

      print("✅ Firebase login berhasil!");

      // Tunggu auth state update
      await Future.delayed(Duration(milliseconds: 500));

      // Verifikasi user sudah login
      if (auth.currentUser != null) {
        print("✅ Current user: ${auth.currentUser!.uid}");
        return {
          "error": false,
          "message": "Berhasil Login",
        };
      } else {
        return {
          "error": true,
          "message": "Login gagal, user tidak ditemukan",
        };
      }
    } on FirebaseAuthException catch (e) {
      print("❌ FirebaseAuthException: ${e.code}");

      String message = "";
      switch (e.code) {
        case 'user-not-found':
          message = 'Email tidak terdaftar';
          break;
        case 'wrong-password':
          message = 'Password salah';
          break;
        case 'invalid-email':
          message = 'Format email tidak valid';
          break;
        case 'user-disabled':
          message = 'Akun dinonaktifkan';
          break;
        case 'too-many-requests':
          message = 'Terlalu banyak percobaan login. Coba lagi nanti';
          break;
        case 'invalid-credential':
          message = 'Email atau password salah';
          break;
        default:
          message = e.message ?? 'Gagal login';
      }

      return {
        "error": true,
        "message": message,
      };
    } catch (e) {
      print("❌ General Exception: $e");

      // Cek apakah sebenarnya user sudah login meskipun ada exception
      if (auth.currentUser != null) {
        print("⚠️ Exception terjadi tapi user sudah login!");
        return {
          "error": false,
          "message": "Berhasil Login",
        };
      }

      return {
        "error": true,
        "message": "Terjadi kesalahan saat login",
      };
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      await auth.signOut();
      uid = null;
      return {
        "error": false,
        "message": "Berhasil Logout",
      };
    } on FirebaseAuthException catch (e) {
      return {
        "error": true,
        "message": "${e.message}",
      };
    } catch (e) {
      return {
        "error": true,
        "message": "Tidak dapat logout",
      };
    }
  }

  @override
  void onInit() {
    print("🚀 AuthController: onInit called");
    auth = FirebaseAuth.instance;
    auth.authStateChanges().listen((event) {
      uid = event?.uid;
      print("👤 Auth state changed: ${uid ?? 'null'}");
    });
    super.onInit();
  }
}
