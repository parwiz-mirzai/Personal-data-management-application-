// lib/App/View/Khaterat/Presentation/show_khaterat_page.dart

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infogurd/Core/Sqlite/database.dart';
import 'package:infogurd/App/View/Khaterat/Presentation/create_khaterat.dart';
import 'package:infogurd/App/View/HomePage/home.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:video_player/video_player.dart';
import '../Data/user_data.dart';

class ShowKhateratPage extends StatefulWidget {
  const ShowKhateratPage({Key? key}) : super(key: key);

  @override
  State<ShowKhateratPage> createState() => _ShowKhateratPageState();
}

class _ShowKhateratPageState extends State<ShowKhateratPage> {
  final db = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('Show Memories'.tr),
        backgroundColor: primaryColor,
     
               automaticallyImplyLeading: false,
          actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_forward),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: const Icon(Icons.add),
        onPressed: () =>
            Get.to(const CreateKhaterat())!.then((_) => setState(() {})),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('khaterat')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'.tr));
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return  Center(child: Text("No memories found.".tr));
          }

          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: docs.length,
              itemBuilder: (_, i) {
                final doc = docs[i];
                final data = doc.data()! as Map<String, dynamic>;
                final item = KhateratModel.fromMap(data);
                return _buildCard(item, firestoreDocId: doc.id);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(KhateratModel item, {required String firestoreDocId}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient:
              LinearGradient(colors: [cardGradientStart, cardGradientEnd]),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _titleRow(item),
              const SizedBox(height: 8),
              Text(
                item.khaterahContent ?? '',
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                'Date: ${DateFormat.yMMMd().format(DateTime.parse(item.createdAt))}'.tr,
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 8),
              _actionRow(item, firestoreDocId),
            ],
          ),
        ),
      ),
    );
  }

  Widget _titleRow(KhateratModel item) {
    return Row(
      children: [
        Expanded(
          child: Text(
            item.khaterahTitle ?? '',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _getLevelColor(item.level),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(item.level, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _actionRow(KhateratModel item, String firestoreDocId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Play / Open buttons...
        Row(
          children: [
            if (item.videoPath != null && item.videoPath!.isNotEmpty)
              ElevatedButton.icon(
                icon: const Icon(Icons.play_circle_filled),
                label:  Text("Play Video".tr),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        VideoPlayerScreen(videoPath: item.videoPath!),
                  ),
                ),
              ),
            if (item.filePath != null && item.filePath!.isNotEmpty)
              ElevatedButton.icon(
                icon: const Icon(Icons.insert_drive_file),
                label:  Text("Open File".tr),
                onPressed: () => OpenFile.open(item.filePath),
              ),
          ],
        ),

        // Edit & Delete
        Row(
          children: [
            // ————— Update Button —————
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.black),
              onPressed: () => _showUpdateDialog(item, firestoreDocId),
            ),

            // ————— Delete Button —————
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title:  Text('Delete Memory'.tr),
                        content:  Text(
                            'Are you sure you want to delete this memory?'.tr),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(_, true),
                              child:  Text('Yes'.tr)),
                          TextButton(
                              onPressed: () => Navigator.pop(_, false),
                              child:  Text('No'.tr)),
                        ],
                      ),
                    ) ??
                    false;
                if (confirm) {
                  // 1) Firestore delete
                  await FirebaseFirestore.instance
                      .collection('khaterat')
                      .doc(firestoreDocId)
                      .delete();
                  // 2) SQLite delete
                  if (item.khaterahId != null) {
                    await db.deleteKhaterah(item.khaterahId!);
                  }
                  setState(() {});
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  /// Opens an AlertDialog to edit title, content, and level.
  void _showUpdateDialog(KhateratModel item, String firestoreDocId) {
    final titleCtrl = TextEditingController(text: item.khaterahTitle);
    final contentCtrl = TextEditingController(text: item.khaterahContent);
    String level = item.level;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title:  Text('Update Memory'.tr),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: titleCtrl,
                decoration:  InputDecoration(labelText: 'Title'.tr),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: contentCtrl,
                maxLines: 4,
                decoration:  InputDecoration(labelText: 'Content'.tr),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: level,
                items:  [
                  DropdownMenuItem(value: 'High'.tr, child: Text('High'.tr)),
                  DropdownMenuItem(value: 'Medium'.tr, child: Text('Medium'.tr)),
                  DropdownMenuItem(value: 'Low'.tr, child: Text('Low'.tr)),
                ],
                decoration:  InputDecoration(labelText: 'Level'.tr),
                onChanged: (v) => level = v ?? level,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
                    Navigator.pop(context);

              Get.snackbar('Success'.tr, 'Memory updated.'.tr);
              final newTitle = titleCtrl.text.trim();
              final newContent = contentCtrl.text.trim();
              if (newTitle.isEmpty || newContent.isEmpty) return;

              // 1) Update Firestore
              await FirebaseFirestore.instance
                  .collection('khaterat')
                  .doc(firestoreDocId)
                  .update({
                'khaterahTitle': newTitle,
                'khaterahContent': newContent,
                'level': level,
              });

           

              // 2) Update local SQLite
              if (item.khaterahId != null) {
                await db.updateKhaterah(
                  newTitle,
                  newContent,
                  level,
                  item.khaterahId!,
                );
          
              }
        
     
      
              
            },
            child:  Text('Update'.tr),
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;

  const VideoPlayerScreen({Key? key, required this.videoPath})
      : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() => _isInitialized = true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text("Video Player".tr),
        backgroundColor: const Color(0xFF80DEEA),
      ),
      body: Center(
        child: _isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
