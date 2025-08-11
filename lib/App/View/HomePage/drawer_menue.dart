import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infogurd/App/Authentication/Presentation/login_screen.dart';
import 'package:infogurd/App/View/About/about_me.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Core/Settings/Controllers/language_controller.dart';
import '../../../Core/Settings/setting_page.dart';

class DrawerMenu extends StatelessWidget {
  final String loggedInUserName;
  final LanguageController langCtrl = Get.find<LanguageController>();

 DrawerMenu({super.key, required this.loggedInUserName});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      width: 250,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ),
                CircleAvatar(
                  child: Text(
                    (loggedInUserName.isNotEmpty) ? loggedInUserName[0] : '?',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  loggedInUserName,
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ],
            ),
          ),
          _drawerItem(
            context,
            'Settings',
            null,
            () => Get.to(() => const SettingPage()),
            icon: Icons.settings,
          ),
          _drawerItem(
            context,
            'About me',
            null,
            () => Get.to(() => const AboutPage()),
            icon: Icons.info,
          ),
          const Divider(height: 1),
          _languageSwitcher(context),
          const Divider(height: 1),
          _drawerItem(
            context,
            'Logout',
            null,
            () {
              _logout(context);
            },
            icon: Icons.logout,
          ),
          const SizedBox(height: 250),
          Center(
            child: Text(
              'Version 1.0.0', // Display your app version here
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _languageSwitcher(BuildContext context) {
    return Obx(() {
      return ListTile(
        title: Text('Change Language'),
        trailing: DropdownButton<String>(
          value: langCtrl.currentCode.value,
          items: [
            DropdownMenuItem(value: 'en', child: Text('English')),
            DropdownMenuItem(value: 'fa', child: Text('Persian')),
            DropdownMenuItem(value: 'ps', child: Text('Pashto')),
          ],
          onChanged: (value) {
            if (value != null) {
              langCtrl.changeLanguage(value);
              _saveLanguage(value);
            }
          },
        ),
      );
    });
  }

  Future<void> _saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
  }

  Widget _drawerItem(
    BuildContext context,
    String key,
    String? asset,
    VoidCallback onTap, {
    IconData? icon,
  }) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    return ListTile(
      leading: asset != null
          ? Image.asset(asset, height: 25, width: 25, color: textColor)
          : Icon(icon, color: textColor),
      title: Text(key.tr, style: TextStyle(color: textColor)),
      onTap: onTap,
    );
  }

  void _logout(BuildContext context) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('username');
      Get.offAll(() => LoginScreen()); // Navigate to LoginPage
    });
  }
}