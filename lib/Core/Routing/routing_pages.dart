
// ignore_for_file: non_constant_identifier_names

import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:infogurd/App/View/Finance/Presentation/finance_page.dart';
import 'package:infogurd/App/View/Image/Presentation/full_screen_image.dart';
import 'package:infogurd/App/View/Image/Presentation/photo_page.dart';
import 'package:infogurd/App/View/Image/Presentation/photo_show.dart';
import 'package:infogurd/App/View/Khaterat/Presentation/create_khaterat.dart';
import 'package:infogurd/App/View/Khaterat/Presentation/show_khaterat.dart';
import 'package:infogurd/App/View/Link/Presentation/create_link.dart';
import 'package:infogurd/App/View/Link/Presentation/link_page.dart';
import 'package:infogurd/App/View/Password/Presentation/create_password.dart';
import 'package:infogurd/App/View/Password/Presentation/password_page.dart';
import 'package:infogurd/App/View/HomePage/home.dart';
import 'package:infogurd/App/Onbording/onbording_veiw.dart';
import 'package:infogurd/Core/Settings/setting_page.dart';


class RoutingPages {
  // ignore: prefer_typing_uninitialized_variables

  static String onbording_veiw = '/OnbordingView';
  static String home = '/HomePage';
  static String create_khaterat = '/CreateKhaterat';
  static String show_khaterat = '/KhateratPage';
  static String create_link = '/CreateLink';
  static String link_page = '/LinkePage';
  static String create_password = '/CreatePassword';
  static String password_page = '/PasswordPage';
  static String full_screen_image = '/FullScreenImage';
  static String photo_page = '/PhotoPage';
  static String photo_show = '/PhotoShowPage';
  static String conting_page= '/CountingPage';
  static String finance_page= '/FinancePage';
  static String slavery_page= '/SlaveryPage';
  static String language_page= '/LanguagePage';
  static String setting_page= '/SettingPage';
 

  static List<GetPage> routes = [
    GetPage(name: RoutingPages.onbording_veiw, page: ()=> const OnbordingView()),
    
    GetPage(name: RoutingPages.home, page: ()=> DashboardPage(loggedInUserName: '',)),
    GetPage(name: RoutingPages.create_khaterat, page: ()=> const CreateKhaterat()),
    GetPage(name: RoutingPages.show_khaterat, page: ()=> const ShowKhateratPage()),
    GetPage(name: RoutingPages.create_link, page: ()=>  CreateLink(onLinkSaved: () {  },)),
    GetPage(name: RoutingPages.link_page, page: ()=> const LinkPage()),
    GetPage(name: RoutingPages.create_password, page: ()=> const CreatePassword()),
    GetPage(name: RoutingPages.password_page, page: ()=> const PasswordPage()),
    GetPage(name: RoutingPages.full_screen_image, page: ()=> FullScreenImage(imagePath:imagePath,)),
    GetPage(name: RoutingPages.photo_page, page: ()=> const PhotoPage()),
    GetPage(name: RoutingPages.photo_show, page: ()=> const PhotoShowPage()),
 
    GetPage(name: RoutingPages.finance_page, page: ()=>  FinancePage()),

    GetPage(name: RoutingPages.setting_page, page: ()=> const SettingPage()),
    
  ];
  
  static get imagePath => null;
  

  
  
  

}
