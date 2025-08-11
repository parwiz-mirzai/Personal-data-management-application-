
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infogurd/App/Authentication/Data/user_data.dart';
import 'package:infogurd/App/Authentication/Presentation/signup_screen.dart';
import 'package:infogurd/App/View/HomePage/home.dart';
import 'package:infogurd/Core/Component/bottons.dart';
import 'package:infogurd/Core/Sqlite/database.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoginTrue = false;
  final db = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Login".tr,
                    style: const TextStyle(
                      color: Color(0xFF18014D),
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Image.asset("assets/1.png"),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                          labelText: 'Username'.tr,
                          prefixIcon: Icon(Icons.account_circle),
                          border: OutlineInputBorder()),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                        controller:passwordController ,
                      decoration: InputDecoration(
                          labelText: "Password".tr,
                          prefixIcon: Icon(Icons.visibility_off),
                          border: OutlineInputBorder()),
                      obscureText: true,
                    ),
                  ),
                  Botton(
                    label: "Login".tr,
                    press: () async {
                      await loginUser();
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Donothaveanaccount".tr,
                        style: const TextStyle(color: Colors.blueGrey),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.to(SignupScreen());
                        },
                        child: Text("Signup".tr),
                      ),
                    ],
                  ),
                  isLoginTrue
                      ? Text(
                          "usernameorpasswordisincorrect".tr,
                          style: const TextStyle(color: Colors.redAccent),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> loginUser() async {
    final user = await db.authenticate(Users(
      name: usernameController.text.trim(),
      password: passwordController.text.trim(),
    ));

    if (user) {
      Get.to(DashboardPage(
          loggedInUserName:
              usernameController.text.trim())); // Pass username to Dashboard
    } else {
      setState(() {
        isLoginTrue = true; // Show error message
      });
    }
  }
}