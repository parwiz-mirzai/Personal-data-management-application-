// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infogurd/App/View/Finance/Presentation/finance_page.dart';
import 'package:infogurd/App/View/HomePage/drawer_menue.dart';
import 'package:infogurd/App/View/Image/Presentation/photo_show.dart';
import 'package:infogurd/App/View/Khaterat/Presentation/show_khaterat.dart';
import 'package:infogurd/App/View/Link/Presentation/link_page.dart';
import 'package:infogurd/App/View/Password/Presentation/password_page.dart';
import 'package:infogurd/Core/Settings/setting_page.dart';
import 'package:local_auth/local_auth.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../Core/Sqlite/database.dart';

const _fadeDuration = Duration(milliseconds: 600);
const _recentToggleDuration = Duration(milliseconds: 400);
const _cardTapDuration = Duration(milliseconds: 200);

const Color primaryColor = Color(0xFF4CAF50); // Green 500
const Color secondaryColor = Color(0xFFF1F8E9); // Light Green 50
const Color accentColor = Color(0xFFFFA726); // Orange 400
const Color cardGradientStart = secondaryColor;
const Color cardGradientEnd = primaryColor;
const Color cardTextColor = Colors.black87;
const Color countBackgroundColor = accentColor;
const Color countTextColor = Colors.white;
const Map<String, String> cardImages = {
  'Link': 'assets/download (1).png',
  'Memory': 'assets/imagesss.png',
  'Password': 'assets/image.png',
  'Photos': 'assets/download.png',
};

class DashboardPage extends StatefulWidget {
  final String? loggedInUserName;
  const DashboardPage({Key? key, required this.loggedInUserName})
      : super(key: key);
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _recentController;
  final auth = LocalAuthentication();
  late DatabaseHelper dbHelper;
  Map<String, int> counts = {
    'Link': 0,
    'Memory': 0,
    'Password': 0,
    'Photos': 0,
  
  
  };
  List<Map<String, dynamic>> recent = [];
  bool _isRecentActivityVisible = true;
  final List<String> items = ['Link', 'Memory', 'Password', 'Photos',];
  int _selectedIndex = 0;
  String? _tappedCard;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _fadeDuration);
    _recentController =
        AnimationController(vsync: this, duration: _recentToggleDuration);
    dbHelper = DatabaseHelper();
    _reloadData().then((_) => _controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    _recentController.dispose();
    super.dispose();
  }

  Future<void> _reloadData() async {
    counts['Link'] = (await dbHelper.getLinks()).length;
    counts['Memory'] = (await dbHelper.getKhaterah()).length;
    counts['Password'] = (await dbHelper.getPasswords()).length;
    counts['Photos'] = (await dbHelper.getPhotos()).length;
    recent = await dbHelper.getRecentActivities();
    if (mounted) setState(() {});
  }

  Future<void> _logActivity(String type, String title) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    await dbHelper.createActivity(type, title, timestamp);
  }

  void _onItemTap(String type) async {
    setState(() => _tappedCard = type);
    await Future.delayed(_cardTapDuration);
    Widget page;
    switch (type) {
      case 'Link':
        page = LinkPage();
        break;
      case 'Memory':
        page = ShowKhateratPage();
        break;
      case 'Photos':
        page = PhotoShowPage();
        break;
      case 'Password':
        page = PasswordPage();
        break;
      default:
        return;
    }
    await Get.to(() => page);
    await _logActivity(type, type);
    await _reloadData();
    if (mounted) {
      _controller.reset();
      _controller.forward();
      setState(() => _tappedCard = null);
    }
  }

  void _deleteActivity(int id) async {
    await dbHelper.deleteActivity(id);
    await _reloadData();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (_selectedIndex == 1)
      content = FinancePage();
    else if (_selectedIndex == 2)
      content = SettingPage();
    else
      content = _buildDashboardContent();

    return FadeTransition(
      opacity: CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      child: Scaffold(
        drawer: DrawerMenu(loggedInUserName: widget.loggedInUserName!),
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: Text('Home Page'.tr, style: TextStyle(color: cardTextColor)),
        ),
        body: content,
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: accentColor,
          unselectedItemColor: cardTextColor.withOpacity(0.6),
          backgroundColor: primaryColor,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'.tr),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_balance), label: 'Finance'.tr),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: 'Settings'.tr),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  Widget _buildDashboardContent() => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final type = items[index];
                  return AnimatedScale(
                    duration: _cardTapDuration,
                    scale: _tappedCard == type ? 1.5 : 1.0,
                    child:
                        _buildCard(type, counts[type]!, () => _onItemTap(type)),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: GestureDetector(
              onTap: () {
                setState(
                    () => _isRecentActivityVisible = !_isRecentActivityVisible);
                _isRecentActivityVisible
                    ? _recentController.forward()
                    : _recentController.reverse();
              },
              child: Row(
                children: [
                  Text('Recent Activity'.tr,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor)),
                  Icon(
                      _isRecentActivityVisible
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down,
                      color: primaryColor),
                ],
              ),
            ),
          ),
          Divider(color: primaryColor),
          Expanded(
            child: SizeTransition(
              sizeFactor: _recentController,
              axisAlignment: -1,
              child: _isRecentActivityVisible ? _buildList() : _buildGrid(),
            ),
          ),
        ],
      );

  Widget _buildList() => ListView.builder(
        itemCount: recent.length,
        itemBuilder: (_, i) {
          final a = recent[i];
          return Dismissible(
            key: Key(a['id'].toString()),
            background: Container(
                color: Colors.red,
                child: Icon(Icons.delete, color: Colors.white)),
            onDismissed: (_) => _deleteActivity(a['id']),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient:
                      LinearGradient(colors: [secondaryColor, primaryColor]),
                ),
                child: ListTile(
                  leading: Icon(_iconFor(a['type'.tr]), color: cardTextColor),
                  title: Text(a['title'.tr],
                      style: TextStyle(color: cardTextColor)),
                  subtitle: Text(
                      timeago.format(DateTime.fromMillisecondsSinceEpoch(
                          a['timestamp'.tr])),
                      style: TextStyle(color: cardTextColor.withOpacity(0.8))),
                ),
              ),
            ),
          );
        },
      );

  Widget _buildGrid() => Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.9 / 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final type = items[index];
            return _buildCard(type, counts[type]!, () => _onItemTap(type));
          },
        ),
      );

  Widget _buildCard(String type, int count, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 150,
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: AssetImage(cardImages[type]!),
              fit: BoxFit.none,
            ),
          ),
          padding: EdgeInsets.all(16),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(_iconFor(type), size: 40, color: cardTextColor),
            SizedBox(height: 8),
            Text(type.tr,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: countTextColor)),
            SizedBox(height: 8),
            CircleAvatar(
                backgroundColor: countBackgroundColor,
                child:
                    Text('$count'.tr, style: TextStyle(color: countTextColor))),
          ]),
        ),
      );

  IconData _iconFor(String t) => t == 'Password'
      ? Icons.password
      : t == 'Link'
          ? Icons.link
          : t == 'Memory'
              ? Icons.note_alt
              : Icons.photo;
}
