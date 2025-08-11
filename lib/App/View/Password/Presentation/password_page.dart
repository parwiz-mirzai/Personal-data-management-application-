import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infogurd/App/View/HomePage/home.dart';
import 'package:infogurd/App/View/Password/Data/user_data.dart';
import 'package:infogurd/App/View/Password/Presentation/create_password.dart';
import 'package:infogurd/Core/Sqlite/database.dart';
import 'package:intl/intl.dart';

class PasswordPage extends StatefulWidget {
  const PasswordPage({super.key});

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  late DatabaseHelper handler;
  late Future<List<PasswordsModel>> users;

  // State variable to manage password visibility
  Map<String, bool> passwordVisibility = {};

  @override
  void initState() {
    super.initState();
    handler = DatabaseHelper();
    users = _fetchPasswords(); // Load passwords from both SQLite and Firebase
  }

  Future<List<PasswordsModel>> _fetchPasswords() async {
    // Load from SQLite
    List<PasswordsModel> localPasswords = await handler.getPasswords();

    // Load from Firebase
    final snapshot = await FirebaseFirestore.instance.collection('passwords').get();
    List<PasswordsModel> firebasePasswords = snapshot.docs.map((doc) {
      final data = doc.data();
      data['passwordId'] = doc.id; // Set Firestore ID explicitly
      return PasswordsModel.fromMap(data);
    }).toList();

    // Merge lists and remove duplicates by passwordId
    final Map<String, PasswordsModel> uniquePasswords = {};

    for (final pass in [...localPasswords, ...firebasePasswords]) {
      final id = pass.passwordId;
      if (id != null && !uniquePasswords.containsKey(id)) {
        uniquePasswords[id] = pass;
      }
    }

    return uniquePasswords.values.toList();
  }

  Future<void> _refresh() async {
    setState(() {
      users = _fetchPasswords();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Passwords'.tr),
        backgroundColor: primaryColor,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_forward),
          )
        ],
      ),
      body: FutureBuilder<List<PasswordsModel>>(
        future: users,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text(snap.error.toString()));
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return Center(child: Text('There are no passwords saved.'.tr));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              itemBuilder: (ctx, i) => _buildCard(items[i]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          Get.to(CreatePassword())?.then((value) {
            if (value == true) {
              _refresh();
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCard(PasswordsModel password) {
    final date = DateFormat.yMMMd().format(DateTime.parse(password.createdAt));
    final int priority = password.priority ?? 2; // Default to Medium

    Color priorityColor;
    String priorityText;

    switch (priority) {
      case 1:
        priorityColor = Colors.red;
        priorityText = 'High'.tr;
        break;
      case 2:
        priorityColor = Colors.orange;
        priorityText = 'Medium'.tr;
        break;
      case 3:
        priorityColor = Colors.green;
        priorityText = 'Low'.tr;
        break;
      default:
        priorityColor = Colors.grey;
        priorityText = 'Unknown'.tr;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(colors: [
                  cardGradientStart,
                  cardGradientEnd,
                ]),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 25,left: 10,right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(password.passwordTitle ?? 'No Title'.tr,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(password.passwordContent ?? 'No Content'.tr,
                        style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 6),
                    _buildPasswordField(password.password ?? 'No Password'.tr, password.passwordId!),
                    const SizedBox(height: 6),
                    Text('Created on: $date'.tr,
                        style: TextStyle(color: Colors.grey[600])),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.copy, color: Colors.blue),
                          onPressed: () {
                            Clipboard.setData(
                                    ClipboardData(text: password.password!))
                                .then((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Password copied to clipboard!'.tr)));
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showUpdateDialog(password),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text('Confirm Deletion'.tr),
                                content: Text('Delete this password?'.tr),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: Text('Yes'.tr),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: Text('No'.tr),
                                  ),
                                ],
                              ),
                            );

                            if (confirm ?? false) {
                              if (mounted) {
                                _refresh();
                              }

                              // Delete from local SQLite database
                              await handler.deletePassword(password.passwordId!);
                              if (mounted) {
                                _refresh();
                              }

                              // Delete from Firebase
                              await FirebaseFirestore.instance
                                  .collection('passwords')
                                  .doc(password.passwordId)
                                  .delete();

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Password is deleted'.tr)),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: priorityColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(priorityText,
                  style: const TextStyle(color: Colors.white, fontSize: 10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String password, String passwordId) {
    // Initialize visibility state for each password
    passwordVisibility[passwordId] = passwordVisibility[passwordId] ?? false;

    return Row(
      children: [
        Expanded(
          child: Text(
            passwordVisibility[passwordId]! ? password : '●●●●●●●●', // Show obscured text
            style: const TextStyle(fontSize: 16),
          ),
        ),
        IconButton(
          icon: Icon(
            passwordVisibility[passwordId]! ? Icons.visibility : Icons.visibility_off,
            color: Colors.blue,
          ),
          onPressed: () {
            setState(() {
              passwordVisibility[passwordId] = !passwordVisibility[passwordId]!; // Toggle visibility
            });
          },
        ),
      ],
    );
  }

  void _showUpdateDialog(PasswordsModel password) {
    final titleC = TextEditingController(text: password.passwordTitle);
    final contentC = TextEditingController(text: password.passwordContent);
    final passwordC = TextEditingController(text: password.password);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Update Password'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: titleC,
                decoration: InputDecoration(labelText: 'Title'.tr)),
            TextField(
                controller: contentC,
                decoration: InputDecoration(labelText: 'Content'.tr)),
            TextField(
                controller: passwordC,
                decoration: InputDecoration(labelText: "Password".tr),
                obscureText: true), // Keeping the new password field obscured
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              PasswordsModel updatedPassword = PasswordsModel(
                passwordId: password.passwordId,
                passwordTitle: titleC.text,
                passwordContent: contentC.text,
                password: passwordC.text,
                createdAt: password.createdAt,
                priority: password.priority,
              );
              await handler.updatePassword(titleC.text, contentC.text,
                  passwordC.text, password.passwordId!);
              Navigator.pop(context, true);
              _refresh();

              // Update in Firebase
              await FirebaseFirestore.instance
                  .collection('passwords')
                  .doc(password.passwordId)
                  .update(updatedPassword.toMap());

              if (mounted) {
                _refresh(); // Refresh after update
              }
            },
            child: Text('Update'.tr),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'.tr),
          ),
        ],
      ),
    );
  }
}