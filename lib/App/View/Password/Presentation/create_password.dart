import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infogurd/Core/Sqlite/database.dart';
import 'package:infogurd/App/View/Password/Data/user_data.dart';
import 'package:infogurd/Core/Component/bottons.dart';
import '../../HomePage/home.dart';

class CreatePassword extends StatefulWidget {
  const CreatePassword({super.key});

  @override
  State<CreatePassword> createState() => _CreatePasswordState();
}

class _CreatePasswordState extends State<CreatePassword> {
  final title = TextEditingController();
  final content = TextEditingController();
  final passwordController = TextEditingController();
  final formkey = GlobalKey<FormState>();
  final db = DatabaseHelper();
  String priority = 'Medium';
  String passwordStrength = '';

  Future<void> _savePassword() async {
    if (!formkey.currentState!.validate()) return;

    final priorityValue = priority == 'High'
        ? 1
        : priority == 'Low'
            ? 3
            : 2;

    final newDocRef = FirebaseFirestore.instance
        .collection('passwords')
        .doc(); // generate ID first

    var passwordModel = PasswordsModel(
      passwordId: newDocRef.id, // assign this early
      passwordTitle: title.text,
      passwordContent: content.text,
      password: passwordController.text,
      createdAt: DateTime.now().toIso8601String(),
      priority: priorityValue,
    );

    // Check for duplicates in Firebase
    final snapshot = await FirebaseFirestore.instance
        .collection('passwords')
        .where('passwordTitle', isEqualTo: passwordModel.passwordTitle)
        .where('password', isEqualTo: passwordModel.password)
        .get();
    if (snapshot.docs.isNotEmpty) {
      if (mounted) {
        Get.snackbar(
            'Error'.tr, 'This password already exists in Firestore.'.tr);
      }
      return;
    }

    // Save to local SQLite with proper ID
    await db.createPassword(passwordModel);
    if (mounted) {
      Navigator.pop(context, true);
      Get.snackbar('Success'.tr, 'Password saved.'.tr);
    }

    // Save to Firestore with same ID
    await newDocRef.set(passwordModel.toMap());
    if (mounted) {
      Get.snackbar('Success'.tr, 'Password saved.'.tr);
    }
  }

  String _evaluatePasswordStrength(String password) {
    if (password.length < 6) {
      return 'Weak';
    } else if (password.length < 10) {
      return 'Medium';
    } else {
      bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
      bool hasDigits = password.contains(RegExp(r'[0-9]'));
      bool hasSpecialCharacters = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

      if (hasUppercase && hasDigits && hasSpecialCharacters) {
        return 'Strong';
      }
      return 'Medium';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("savepassword".tr),
        backgroundColor: primaryColor,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_forward),
          )
        ],
      ),
      body: Form(
        key: formkey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(
                  controller: title,
                  label: "Title".tr,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Titleisrequired".tr; 
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: passwordController,
                  validator: (value){
                     if (value!.length <= 8){
                       return 'The password lenght should be at least 8';
                      }
                  },
                  label: "Password".tr,
                  onChanged: (value) {
                    setState(() {
                      passwordStrength = _evaluatePasswordStrength(value);
                    
                    });
                     
                  },
                ),
                Text(
                  'Password Strength: $passwordStrength',
                  style: TextStyle(
                    color: passwordStrength == 'Strong'
                        ? Colors.green
                        : passwordStrength == 'Weak'
                            ? Colors.red
                            : Colors.orange,
                  ),
                ),
                _buildTextField(
                  controller: content,
                  label: "Contentisrequired".tr,
                  maxLines: 5,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Contentisrequired".tr;
                    }
                    return null;
                  },
                ),
                Text('Importance Level'.tr,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: priority,
                  items: ['High', 'Medium', 'Low']
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e.tr),
                          ))
                      .toList(),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.circle, size: 12),
                    filled: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (v) => setState(() => priority = v!),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Botton(
                    label: "Save".tr,
                    press: _savePassword,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    bool obscureText = false,
    String? Function(String?)? validator,
    Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            obscureText: obscureText,
            validator: validator,
            onChanged: onChanged, // Handle changes
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: label,
              labelStyle: TextStyle(color: Colors.black54),
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }
}