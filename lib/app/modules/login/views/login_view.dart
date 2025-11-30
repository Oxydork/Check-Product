import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_new/app/controllers/auth_controller.dart';
import 'package:qr_code_new/app/routes/app_pages.dart';

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  final TextEditingController emailC = TextEditingController();
  //text: "admin1@gmail.com"
  final TextEditingController passC = TextEditingController();
  //text: "admin123321"
  final AuthController authC = Get.find<AuthController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                //logo
                const Icon(
                  Icons.lock,
                  size: 100,
                ),
                const SizedBox(
                  height: 50,
                ),
                //welcomeback, you,ve been missed
                Text(
                  "Welcome back, you've been missed!",
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                //username textfield
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: TextField(
                    controller: emailC,
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                //paswword textfiel
                Obx(
                  () => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: TextField(
                      controller: passC,
                      decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        fillColor: Colors.grey.shade200,
                        filled: true,
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          onPressed: () {
                            controller.isHidden.toggle();
                          },
                          icon: Icon(controller.isHidden.value
                              ? Icons.remove_red_eye
                              : Icons.remove_red_eye_outlined),
                        ),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                      ),
                      obscureText: controller.isHidden.value,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                //forgot password
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.grey[600]),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                //sign in button
                GestureDetector(
                  onTap: () async {
                    if (controller.isLoading.isFalse) {
                      if (emailC.text.isNotEmpty && passC.text.isNotEmpty) {
                        print("=== LOGIN START ===");
                        print("Email : ${emailC.text}");
                        print("Pass : ${passC.text}");

                        controller.isLoading(true);
                        Map<String, dynamic> hasil =
                            await authC.login(emailC.text, passC.text);
                        controller.isLoading(false);

                        print("=== LOGIN RESPONSE ===");
                        print("Hasil lengkap: $hasil");
                        print("hasil['error'] = ${hasil["error"]}");
                        print("hasil['message'] = ${hasil["message"]}");
                        print("Tipe data error: ${hasil["error"].runtimeType}");
                        print("Hasil error == true? ${hasil["error"] == true}");

                        if (hasil["error"] == true) {
                          print(">>> MASUK KE BLOK ERROR");
                          Get.snackbar("Error", hasil["message"]);
                        } else {
                          print(">>> MASUK KE BLOK SUCCESS");
                          print("Navigasi ke HOME...");
                          Get.offAllNamed(Routes.HOME);
                        }
                      } else {
                        Get.snackbar("Error", "Email & Password Wajib Diisi");
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    margin: const EdgeInsets.symmetric(horizontal: 25),
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8)),
                    child: Center(
                      child: Obx(
                        () => Text(
                          controller.isLoading.isFalse
                              ? "Login"
                              : "Loading....",
                          style: TextStyle(
                              color: controller.isLoading.isFalse
                                  ? Colors.white
                                  : Colors.white30,
                              fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ),
                //forgot password
                //or continue with
                //google + apple sign in buttons
                //not a member? register now
              ],
            ),
          ),
        ),
      ),
    );
  }
}
