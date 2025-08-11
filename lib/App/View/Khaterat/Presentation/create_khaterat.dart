// lib/App/View/Khaterat/Presentation/create_khaterat.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:infogurd/Core/Component/bottons.dart';
import 'package:infogurd/Core/Sqlite/database.dart';
import 'package:infogurd/App/View/HomePage/home.dart';
import '../Data/user_data.dart';
import 'package:video_player/video_player.dart';

class CreateKhaterat extends StatefulWidget {
  const CreateKhaterat({super.key});

  @override
  State<CreateKhaterat> createState() => _CreateKhateratState();
}

class _CreateKhateratState extends State<CreateKhaterat> {
  final title = TextEditingController();
  final content = TextEditingController();
  final formkey = GlobalKey<FormState>();
  final db = DatabaseHelper();

  String selectedLevel = 'Medium'; // Default level
  File? videoFile;
  File? textFile;
  VideoPlayerController? _videoController;

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _pickVideo(ImageSource source) async {
    final pickedFile = await ImagePicker().pickVideo(source: source);
    if (pickedFile != null) {
      setState(() {
        videoFile = File(pickedFile.path);
        _videoController = VideoPlayerController.file(videoFile!)
          ..initialize().then((_) => setState(() {}));
      });
    }
  }

  Future<void> _pickTextFile() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['txt']);
    if (result != null && result.files.single.path != null) {
      setState(() => textFile = File(result.files.single.path!));
    }
  }

  Widget _buildPreview() {
    if (_videoController != null && _videoController!.value.isInitialized) {
      return AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: VideoPlayer(_videoController!),
      );
    }
    return const SizedBox();
  }

  Future<void> _saveKhaterah() async {
    if (!formkey.currentState!.validate()) return;

    final now = DateTime.now().toIso8601String();
    // prepare local model
    final model = KhateratModel(
      khaterahTitle: title.text,
      khaterahContent: content.text,
      level: selectedLevel,
      createdAt: now,
      videoPath: videoFile?.path,
      filePath: textFile?.path,
    );

    // 1) Check duplicates in Firestore
    final snapshot = await FirebaseFirestore.instance
        .collection('khaterat')
        .where('khaterahTitle', isEqualTo: model.khaterahTitle)
        .where('createdAt', isEqualTo: model.createdAt)
        .get();
    if (snapshot.docs.isNotEmpty) {
      Get.snackbar('Error'.tr, 'This memory already exists in Firestore.'.tr);
      return;
    }

    // 2) Save to local SQLite
    await db.insertKhaterah(model);
       if (mounted){   Navigator.of(context).pop(true);
    Get.snackbar('Success'.tr, 'Memory saved.'.tr);}
 

    // 3) Save to Firestore
    final docRef =
        FirebaseFirestore.instance.collection('khaterat').doc(); // auto‐ID
    await docRef.set({
      'firebaseId': docRef.id,
      ...model.toMap(),
    });

    if (mounted){   Navigator.of(context).pop(true);
    Get.snackbar('Success'.tr, 'Memory saved.'.tr);}
 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("savememories".tr),
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
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // -- Title, Content, Level dropdown, Video/Text buttons, preview --
                _buildTextField(
                  controller: title,
                  label: "Title".tr,
                  maxLength: 20,
                  height: 70,
                  validator: (v) =>
                      v!.isEmpty ? "Titleisrequired".tr : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: content,
                  label: "Content",
                  maxLength: 500,
                  maxLines: 6,
                  height: 250,
                  validator: (v) {
                    if (v!.isEmpty) return "Contentisrequired".tr;
                    if (v.length > 500) return 'Content too long (max 500)';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedLevel,
                  items: const [
                    DropdownMenuItem(
                        value: 'High',
                        child: Text('High', style: TextStyle(color: Colors.red))),
                    DropdownMenuItem(
                        value: 'Medium',
                        child:
                            Text('Medium', style: TextStyle(color: Colors.orange))),
                    DropdownMenuItem(
                        value: 'Low',
                        child:
                            Text('Low', style: TextStyle(color: Colors.green))),
                  ],
                  onChanged: (v) => setState(() => selectedLevel = v!),
                  decoration: InputDecoration(
                    labelText: "Select Level",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _uploadButton("Camera Video", () => _pickVideo(ImageSource.camera)),
                    _uploadButton("Gallery Video", () => _pickVideo(ImageSource.gallery)),
                  ],
                ),
                const SizedBox(height: 12),
                _uploadButton("Upload Text File", _pickTextFile),
                const SizedBox(height: 12),
                _buildPreview(),
                const SizedBox(height: 24),
                Botton(label: 'save'.tr, press: _saveKhaterah),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _uploadButton(String label, VoidCallback onTap) {
    return Container(
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(10), color: primaryColor),
      child: TextButton(onPressed: onTap, child: Text(label,style: TextStyle(color: Colors.white),)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int? maxLength,
    required double height,
    required String? Function(String?)? validator,
    int maxLines = 1,
  }) =>
      TextFormField(
        controller: controller,
        maxLength: maxLength,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        ),
      );
}
