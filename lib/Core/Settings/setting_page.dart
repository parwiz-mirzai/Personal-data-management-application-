// File: lib/App/View/Settings/setting_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infogurd/App/View/HomePage/home.dart';
import 'package:infogurd/Core/Settings/Controllers/language_controller.dart';
import 'package:infogurd/Core/Settings/perform_auth_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final langCtrl = Get.find<LanguageController>();

  final authSvc = AuthService();

  bool authRequired = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    // Load and apply language
    final code = prefs.getString('language') ?? 'en';
    await langCtrl.changeLanguage(code);

    // Load auth requirement
    authRequired = prefs.getBool('authRequired') ?? false;
    setState(() {});
  }

  Future<void> _onLanguageSelect(String code) async {
    await langCtrl.changeLanguage(code);
    setState(() {});
  }

  Future<void> _onApply() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('authRequired', authRequired);

    if (authRequired) {
      final ok = await authSvc.authenticate();
      if (!ok) {
        Get.snackbar(
          'Error',
          'please_select_auth'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    Get.offAll(() => DashboardPage(loggedInUserName: ''));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings_language'.tr),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() => Column(
              children: [

                const Divider(),

                // Language section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'settings_language'.tr,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                RadioListTile<String>(
                  title: Text('english'.tr),
                  value: 'en',
                  groupValue: langCtrl.currentCode.value,
                  onChanged: (v) => _onLanguageSelect(v!),
                ),
                RadioListTile<String>(
                  title: Text('persian'.tr),
                  value: 'fa',
                  groupValue: langCtrl.currentCode.value,
                  onChanged: (v) => _onLanguageSelect(v!),
                ),
                RadioListTile<String>(
                  title: Text('pashto'.tr),
                  value: 'ps',
                  groupValue: langCtrl.currentCode.value,
                  onChanged: (v) => _onLanguageSelect(v!),
                ),
                const Divider(),

                // Auth Required switch
                SwitchListTile(
                  title: Text('settings_auth_required'.tr),
                  value: authRequired,
                  onChanged: (v) => setState(() => authRequired = v),
                ),
                const Spacer(),

                ElevatedButton(
                  onPressed: _onApply,
                  child: Text('apply'.tr),
                ),
              ],
            )),
      ),
    );
  }
}
