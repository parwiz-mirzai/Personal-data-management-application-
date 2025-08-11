
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infogurd/App/Authentication/Data/user_data.dart';
import 'package:infogurd/App/Authentication/Presentation/login_screen.dart';
import 'package:infogurd/Core/Component/bottons.dart';
import 'package:infogurd/Core/Sqlite/database.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isUserExist = false;
  final db = DatabaseHelper();

  signUp() async {
    bool usrExist = await db.checkUserExist(nameController.text);
    if (usrExist) {
      var res = await db.createUser(Users(
        name: nameController.text,
        password: passwordController.text,
      ));
      if (res > 0) {
        Get.to(const LoginScreen());
      }
    } else {
      setState(() {
        isUserExist = true; // Show existing user message
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                   "RegisterNewAccount".tr,
                    style: TextStyle(
              
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                  decoration: InputDecoration(
                    labelText:   'Username'.tr,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.account_circle,)
                  ),
                    controller: nameController,
                  
                   
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                  decoration: InputDecoration(
                    labelText:   "Password".tr,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.visibility_off,)
                  ),
                    controller: passwordController,
                    obscureText: true,
                   
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                  decoration: InputDecoration(
                    labelText:   "Reenterpassword".tr,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.visibility_off,)
                  ),
                    controller: confirmPasswordController,
                    obscureText: true,
                   
                  ),
                ),
             
                const SizedBox(height: 10),
                Botton(
                  label:"Signup".tr,
                  press: signUp,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                     "Alreadyhaveanaccount".tr,
                      style: const TextStyle(color: Colors.blueGrey),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.to(const LoginScreen());
                      },
                      child: Text("Login".tr),
                    ),
                  ],
                ),
                isUserExist
                    ? Text(
                       "useralreadyexistspleaseenternewuser".tr,
                        style: const TextStyle(color: Colors.red),
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}