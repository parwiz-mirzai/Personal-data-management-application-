// lib/App/View/Image/Presentation/photo_show.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infogurd/App/View/HomePage/home.dart';
import 'package:intl/intl.dart';
import 'package:infogurd/Core/Sqlite/database.dart';
import 'package:infogurd/App/View/Image/Data/user_data.dart';
import 'package:infogurd/App/View/Image/Presentation/full_screen_image.dart';
import 'photo_page.dart';

class PhotoShowPage extends StatefulWidget {
  const PhotoShowPage({Key? key}) : super(key: key);

  @override
  _PhotoShowPageState createState() => _PhotoShowPageState();
}

class _PhotoShowPageState extends State<PhotoShowPage> {
  final handler = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('Photos'.tr),
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
        backgroundColor:primaryColor,
        onPressed: () => Get.to(const PhotoPage())?.then((_) => setState(() {})),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<PhotoModel>>(
        future: handler.getPhotos(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data!.isEmpty) {
            return  Center(child: Text('There is no photo'.tr));
          }
          final items = snap.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: items.length,
            itemBuilder: (ctx, i) {
              final item = items[i];
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FullScreenImage(imagePath: item.photoName),
                  ),
                ),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child:
                            Image.file(File(item.photoName), fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: _badgeColor(item.importanceLevel),
                          child: Text(
                            item.importanceLevel[0],
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(item.photoTitle,
                                  style: const TextStyle(color: Colors.white)),
                              Text(
                                DateFormat.yMMMd()
                                    .format(DateTime.parse(item.createdAt)),
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 118,
                        left: 110,
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title:  Text('Delete Photo'.tr),
                                content:  Text(
                                    'Are you sure you want to delete this photo?'.tr),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child:  Text('Cancel'.tr),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child:  Text('Delete'.tr),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await _deletePhoto(item);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _badgeColor(String lvl) {
    switch (lvl) {
      case 'High':
        return Colors.red;
      case 'Low':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  Future<void> _deletePhoto(PhotoModel photo) async {
    // 1) delete local file
    final file = File(photo.photoName);
    if (await file.exists()) {
      await file.delete();
    }

    // 2) delete from SQLite
    if (photo.photoId != null) {
      await handler.deletePhoto(photo.photoId!);
        setState(() {});
    Get.snackbar('Deleted'.tr, 'Photo removed.'.tr);
    }

    // 3) delete from Firestore by matching createdAt + title
    final qs = await FirebaseFirestore.instance
        .collection('photos')
        .where('photoTitle', isEqualTo: photo.photoTitle)
        .where('createdAt', isEqualTo: photo.createdAt)
        .get();
    for (var doc in qs.docs) {
      await doc.reference.delete();
    }

    // 4) refresh UI
    setState(() {});
    Get.snackbar('Deleted'.tr, 'Photo removed.'.tr);
  }
}
