import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Core/Routing/routing_pages.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      _navigateToNextScreen();
    });
  }

  void _navigateToNextScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final onbording = prefs.getBool("onbording") ?? false;

    if (onbording) {
      Get.offAllNamed(RoutingPages.home); // به صفحه اصلی هدایت کنید
    } else {
      Get.offAllNamed(
          RoutingPages.onbording_veiw); // به صفحه onboarding هدایت کنید
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 243, 243, 243),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/R.png",
              height: 220,
            ),
            const SizedBox(height: 20),
             Text(
              'My App'.tr,
              style: TextStyle(fontSize: 25),
            ),
            const SizedBox(height: 25),
            if (defaultTargetPlatform == TargetPlatform.android)
              const CupertinoActivityIndicator(
                color: Color.fromARGB(255, 180, 158, 158),
                radius: 20,
              )
            else
              const CircularProgressIndicator(
                color: Color.fromARGB(255, 43, 41, 41),
              )
          ],
        ),
      ),
    );
  }
}