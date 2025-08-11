import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infogurd/App/View/HomePage/home.dart';
import 'package:infogurd/Core/Sqlite/database.dart';
import 'package:infogurd/App/View/Link/Data/user_data.dart';
import 'package:metadata_fetch/metadata_fetch.dart';

class CreateLink extends StatefulWidget {
  final VoidCallback onLinkSaved;

  const CreateLink({super.key, required this.onLinkSaved});

  @override
  State<CreateLink> createState() => _CreateLinkState();
}

class _CreateLinkState extends State<CreateLink> {
  final urlCtrl = TextEditingController();
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final db = DatabaseHelper();

  String importance = 'Medium';

  Future<void> _saveLink() async {
    if (!formKey.currentState!.validate()) return;

    final newDocRef = FirebaseFirestore.instance.collection('links').doc();

    var linkModel = LinkModel(
      linkId: newDocRef.id,
      linkTitle: titleCtrl.text,
      linkContent: urlCtrl.text,
      linkDescription: descCtrl.text,
      createdAt: DateTime.now().toIso8601String(),
      priority: importance,
    );

    // Check for duplicates in Firestore
    final snapshot = await FirebaseFirestore.instance
        .collection('links')
        .where('linkTitle', isEqualTo: linkModel.linkTitle)
        .where('linkContent', isEqualTo: linkModel.linkContent)
        .get();
    if (snapshot.docs.isNotEmpty) {
      if (mounted) {
        Get.snackbar('Error', 'This link already exists in Firestore.');
      }
      return;
    }

    // Save to local SQLite
    await db.createLink(linkModel);
    if (mounted) {
      Navigator.pop(context, true);
      Get.snackbar('Success', 'Link saved.');
      widget.onLinkSaved(); // Call the callback to refresh LinkPage
    }

    // Save to Firestore
    await newDocRef.set(linkModel.toMap());

    if (mounted) {
      Navigator.pop(context, true);
      Get.snackbar('Success', 'Link saved.');
      widget.onLinkSaved(); // Call the callback to refresh LinkPage
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("savethelink".tr),
        backgroundColor: primaryColor,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Add New Link'.tr, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),

            // URL field + refresh button
            Row(children: [
              Expanded(
                child: _buildField(urlCtrl, 'URL *', 
                  prefix: Icons.link,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a URL.';
                    }
                    Uri? uri = Uri.tryParse(value);
                    if (uri == null || !(uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https'))) {
                      return 'Invalid URL format.';
                    }
                    return null;
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () async {
                  String inputUrl = urlCtrl.text.trim();

                  // Ensure the URL has a proper prefix
                  if (!inputUrl.startsWith('http://') && !inputUrl.startsWith('https://')) {
                    inputUrl = 'https://$inputUrl';
                  }

                  final uri = Uri.tryParse(inputUrl);
                  if (uri == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Invalid URL format'.tr)),
                    );
                    return;
                  }

                  // Fetch metadata and fill in fields
                  final data = await MetadataFetch.extract(inputUrl);

                  if (data != null) {
                    setState(() {
                      titleCtrl.text = data.title ?? titleCtrl.text;
                      descCtrl.text = data.description ?? descCtrl.text;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Metadata fetched'.tr)),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not fetch metadata'.tr)),
                    );
                  }
                },
              ),
            ]),
            const SizedBox(height: 12),

            // Title and description
            _buildField(titleCtrl, 'Title *'.tr, 
              prefix: Icons.text_fields,
              validator: (value) {
                if (value!.isEmpty || value.length < 10) {
                  return 'Title is required and should be at least 10 characters.';
                }
                return null;
              },
              maxLength: 50, // Adjusted for a reasonable title length
            ),
            const SizedBox(height: 12),
            _buildField(descCtrl, 'Description'.tr,
              prefix: Icons.description, 
              maxLines: 6,
              maxLength: 300,
              validator: (value) {
                if (value!.length < 10) {
                  return 'The length should be more than ten characters.'.tr;
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Importance dropdown
            Text('Importance Level'.tr,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: importance,
              items: ['High'.tr, 'Medium'.tr, 'Low'.tr]
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ))
                  .toList(),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.circle, size: 12),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (v) => setState(() => importance = v!),
            ),

            const SizedBox(height: 30),

            // Buttons
            Row(children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: primaryColor,
                  ),
                  child: TextButton(
                    child: Text(
                      'Cancel'.tr,
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: primaryColor,
                ),
                child: TextButton(
                  child: Text(
                    'Save Link'.tr,
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: _saveLink,
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label, {
    IconData? prefix,
    int maxLines = 1,
    int? maxLength,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      validator: validator,
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: InputDecoration(
        prefixIcon: prefix != null ? Icon(prefix) : null,
        labelText: label.tr,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}