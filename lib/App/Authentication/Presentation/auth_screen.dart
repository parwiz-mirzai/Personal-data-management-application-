import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infogurd/App/Authentication/Presentation/login_screen.dart';
import 'package:infogurd/App/Authentication/Presentation/signup_screen.dart';
import 'package:infogurd/Core/Component/bottons.dart';


class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
               "Authentication".tr,
                style: const TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF18014D)),
              ),
               Text(
                "authenticate to access your information".tr,
                style: TextStyle(color: Colors.blueGrey),
              ),
              Expanded(child: Image.asset("assets/2.png")),
              Botton(
                label:"Login".tr,
                press: () {
                  Get.to(LoginScreen());
                },
              ),
              Botton(
                label:"Signup".tr,
                press: () {
                  Get.to(SignupScreen());
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
