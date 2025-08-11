import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:infogurd/App/View/HomePage/home.dart';
import 'package:intl/intl.dart';
import 'package:infogurd/App/View/Link/Data/user_data.dart';
import 'package:infogurd/App/View/Link/Presentation/create_link.dart';

import 'package:infogurd/Core/Sqlite/database.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LinkPage extends StatefulWidget {
  const LinkPage({super.key});

  @override
  State<LinkPage> createState() => _LinkPageState();
}

class _LinkPageState extends State<LinkPage> {
  late DatabaseHelper handler;
  late Future<List<LinkModel>> users;

  @override
  void initState() {
    super.initState();
    handler = DatabaseHelper();
    users = _fetchLinks(); // Load links from both SQLite and Firebase
  }

  Future<List<LinkModel>> _fetchLinks() async {
    // Load from SQLite
    List<LinkModel> localLinks = await handler.getLinks();

    // Load from Firebase
    final snapshot = await FirebaseFirestore.instance.collection('links').get();
    List<LinkModel> firebaseLinks = snapshot.docs.map((doc) {
      final data = doc.data();
      data['linkId'] = doc.id; // Set Firestore ID explicitly
      return LinkModel.fromMap(data);
    }).toList();

    // Merge lists and remove duplicates by linkId
    final Map<String, LinkModel> uniqueLinks = {};
    for (final link in [...localLinks, ...firebaseLinks]) {
      final id = link.linkId;
      if (id != null && !uniqueLinks.containsKey(id)) {
        uniqueLinks[id] = link;
      }
    }

    return uniqueLinks.values.toList();
  }

  Future<void> _refresh() async {
    if (mounted) {
      setState(() {
        users = _fetchLinks(); // Refresh the link list from both sources
      });
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url.trim());
    bool launched = false;

    // Try external browser first
    if (await canLaunchUrl(uri)) {
      launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }

    // Fallback: open inside the app
    if (!launched) {
      launched = await launchUrl(
        uri,
        mode: LaunchMode.inAppWebView,
        webViewConfiguration:
            const WebViewConfiguration(enableJavaScript: true),
      );
    }

    // Final fallback: notify user
    if (!launched) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch: $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Links".tr),
       backgroundColor: primaryColor,
               automaticallyImplyLeading: false,
          actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_forward),
          )
        ],
      ),
      body: FutureBuilder<List<LinkModel>>(
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
            return Center(child: Text("thereisnolink".tr));
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
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                CreateLink(onLinkSaved: _refresh), // Pass the _refresh function
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCard(LinkModel link) {
    final uri = Uri.tryParse(link.linkContent);
    final domain = uri?.host;
    final title = link.linkTitle;
    final description = link.linkDescription;
    final date = DateFormat.yMMMd().format(DateTime.parse(link.createdAt));
    final priority = link.priority ?? 'Medium';

    Color priorityColor;
    switch (priority.toLowerCase()) {
      case 'high':
        priorityColor = Colors.red;
        break;
      case 'medium':
        priorityColor = Colors.orange;
        break;
      default:
        priorityColor = Colors.green;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                   cardGradientStart,
                   cardGradientEnd
             
                  ],
                ),
                borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(children: [
                          const Icon(Icons.language,
                              size: 20, color: Colors.grey),
                          const SizedBox(width: 8),

                          // Clickable domain text
                          InkWell(
                            onTap: () {
                              _launchURL(link
                                  .linkContent); // Using the null assertion operator
                            },
                            child: Text(
                              domain!,
                              style: const TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),

                          const SizedBox(width: 6),

                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              SizedBox(width: 4),
                              Text('Working',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 45, 143, 21))),
                            ],
                          ),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Title
                    Text(title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),

                    // Description (not the URL)
                    Text(description, style: TextStyle(color: Colors.black54)),
                    const SizedBox(height: 12),

                    // Date added
                    Text('Added $date',
                        style: TextStyle(color: Colors.grey[600])),

                    const Divider(height: 24),

                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(
                                    ClipboardData(text: link.linkContent))
                                .then((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Link copied to clipboard!'.tr)),
                              );
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.share),
                          onPressed: () {
                            // ignore: deprecated_member_use
                            Share.share(link.linkContent,
                                subject: link.linkTitle);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showUpdateDialog(link),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text("Confirm Deletion".tr),
                                content: Text("Delete this link?".tr),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: Text("Yes".tr),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: Text("No".tr),
                                  ),
                                ],
                              ),
                            );
                            if (confirm ?? false) {
                              await handler.deleteLink(link.linkId!);
                              _refresh();
                              await FirebaseFirestore.instance
                                  .collection('links')
                                  .doc(link.linkId)
                                  .delete();
                              _refresh();
                            }
                          },
                        ),
                      ],
                    )
                  ]),
            ),
          ),

          // Priority badge on top-right corner
          Container(
            height: 20,
            color: priorityColor,
            child: badges.Badge(
              badgeContent: Text(
                priority,
                style: const TextStyle(color: Colors.black, fontSize: 10),
              ),
              badgeStyle: badges.BadgeStyle(
                badgeColor: priorityColor,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                borderRadius: BorderRadius.circular(12),
              ),
              position: badges.BadgePosition.custom(top: 20, bottom: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog(LinkModel item) {
    final titleC = TextEditingController(text: item.linkTitle);
    final contentC = TextEditingController(text: item.linkContent);
    final descriptionC = TextEditingController(text: item.linkDescription);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("update".tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleC,
              decoration: InputDecoration(labelText: "Title".tr),
            ),
            TextField(
              controller: contentC,
              decoration: InputDecoration(labelText: "Content".tr),
            ),
            TextField(
              controller: descriptionC,
              decoration: InputDecoration(labelText: "Description".tr),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // Call updateLink with the necessary parameters
              await handler.updateLink(
                titleC.text,
                contentC.text,
                descriptionC.text,
                item.linkId!,
              );
              _refresh();
              Navigator.pop(context);
              await FirebaseFirestore.instance
                  .collection('links')
                  .doc(item.linkId)
                  .update({
                'linkTitle': titleC.text,
                'linkContent': contentC.text,
                'linkDescription': descriptionC.text,
              });
              _refresh();
              Navigator.pop(context);
            },
            child: Text("update".tr),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("cancel".tr),
          ),
        ],
      ),
    );
  }
}