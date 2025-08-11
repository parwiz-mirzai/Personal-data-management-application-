// lib/App/View/Image/Presentation/photo_page.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:infogurd/App/View/HomePage/home.dart';
import 'package:path_provider/path_provider.dart';
import 'package:infogurd/Core/Sqlite/database.dart';
import 'package:infogurd/App/View/Image/Data/user_data.dart';


class PhotoPage extends StatefulWidget {
  const PhotoPage({Key? key}) : super(key: key);

  @override
  State<PhotoPage> createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _titleCtrl = TextEditingController();
  String importance = 'Medium';
  XFile? _image;
  final DatabaseHelper db = DatabaseHelper();

  Future<void> _getImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked == null) return;
    setState(() => _image = picked);
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title:  Text('Gallery'.tr),
            onTap: () {
              Navigator.pop(context);
              _getImage(ImageSource.gallery);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title:  Text('Camera'.tr),
            onTap: () {
              Navigator.pop(context);
              _getImage(ImageSource.camera);
            },
          ),
        ]),
      ),
    );
  }

  Future<String> _saveImageToFile(XFile img) async {
    final dir = await getApplicationDocumentsDirectory();
    final path =
        '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File(path);
    await file.writeAsBytes(await img.readAsBytes());
    return path;
  }

  Future<void> _save() async {
    if (_image == null || _titleCtrl.text.trim().isEmpty) return;

    final newPath = await _saveImageToFile(_image!);
    final createdAt = DateTime.now().toIso8601String();

    final photo = PhotoModel(
      photoName: newPath,
      photoTitle: _titleCtrl.text.trim(),
      createdAt: createdAt,
      importanceLevel: importance,
    );

    // ————————— Firestore duplicate check —————————
    final dup = await FirebaseFirestore.instance
        .collection('photos')
        .where('photoTitle', isEqualTo: photo.photoTitle)
        .where('createdAt', isEqualTo: createdAt)
        .get();
    if (dup.docs.isNotEmpty) {
      Get.snackbar('Error'.tr, 'This photo already exists in Firestore.'.tr);
      return;
    }

    // ————————— Save to local SQLite —————————
    await db.createPhoto(photo);
       if (mounted) {
    Navigator.pop(context);
      Get.snackbar('Success'.tr, 'Photo saved.'.tr);
    }

    // ————————— Save to Firestore —————————
    final docRef =
        FirebaseFirestore.instance.collection('photos').doc();
    await docRef.set({
      'firebaseId': docRef.id,
      ...photo.toMap(),
    });

    // Navigate back and refresh
    if (mounted) {
    Navigator.pop(context);
      Get.snackbar('Success'.tr, 'Photo saved.'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('Add New Image'.tr),
        backgroundColor: primaryColor,
               automaticallyImplyLeading: false,
          actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_forward),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(
            onTap: _showPickerOptions,
            child: Container(
              height: 350,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _image == null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children:  [
                          Icon(Icons.camera_alt,
                              size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Tap to add image'.tr,
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(File(_image!.path),
                          fit: BoxFit.cover, width: double.infinity),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleCtrl,
            maxLength: 20,
            
            decoration:  InputDecoration(
              
                labelText: 'Title'.tr, border: OutlineInputBorder()),
                
          ),
          const SizedBox(height: 16),
           Text('Importance Level'.tr,
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['High'.tr, 'Medium'.tr, 'Low'.tr].map((lvl) {
              final isSelected = importance == lvl;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected
                        ? const Color.fromARGB(255, 179, 210, 241)
                        : Colors.white,
                  ),
                  onPressed: () => setState(() => importance = lvl),
                  child: Text(lvl),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: _save,
              child:
                   Text('Save'.tr, style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(150, 48),
                  backgroundColor:primaryColor),
            ),
          ),
        ]),
      ),
    );
  }
}
