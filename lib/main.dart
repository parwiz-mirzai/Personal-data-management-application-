// File: lib/main.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:infogurd/App/Onbording/spalsh_screen.dart';
import 'package:infogurd/Core/Routing/routing_pages.dart';
import 'package:infogurd/Core/Settings/Controllers/language_controller.dart';
import 'package:infogurd/Core/Settings/perform_auth_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Load saved preferences
  final prefs = await SharedPreferences.getInstance();
  final savedLangCode = prefs.getString('language') ?? 'en';
  final authRequired = prefs.getBool('authRequired') ?? false;

  // Initialize controllers
  final languageController = LanguageController();
  // Set initial language using saved code
  await languageController.changeLanguage(savedLangCode);
  Get.put<LanguageController>(languageController);



  // Handle authentication if required
  if (authRequired) {
    final authService = AuthService();
    final ok = await authService.authenticate();
    if (!ok) {
      Get.snackbar(
        'Authentication Failed',
        'Please authenticate to continue.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    final languageCtrl = Get.find<LanguageController>();

    return Obx(() => GetMaterialApp(
          debugShowCheckedModeBanner: false,
       
          getPages: RoutingPages.routes,
          home: const SplashScreen(),
          translations: Get.find<LanguageController>(),
          locale: Locale(languageCtrl.currentCode.value),
        ));
  }
}
