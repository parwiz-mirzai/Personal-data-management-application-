import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../HomePage/home.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('About the Developer'.tr),
        centerTitle: true,
         backgroundColor: primaryColor,
     
               automaticallyImplyLeading: false,
          actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_forward),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
       
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/myself.png'), 
              ),
              const SizedBox(height: 16),
               Text(
                'Parwiz Mirzai'.tr,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
               SizedBox(height: 8),
               Text(
                'Flutter Developer'.tr,
                style: TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
              ),
               SizedBox(height: 16),
               Text(
                'About Me:'.tr,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
      
                 textAlign: TextAlign.justify,
              ),
               SizedBox(height: 8),
               Text(
                'I am a passionate Flutter developer with experience in building beautiful and functional mobile applications. '
                'I enjoy creating user-friendly interfaces and implementing the latest technologies to enhance user experience.'.tr,
                style: TextStyle(fontSize: 16), textAlign: TextAlign.justify,
              ),
               SizedBox(height: 16),
               Text(
                'Contact Me:'.tr,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ), textAlign: TextAlign.justify,
              ),
               SizedBox(height: 8),
               Text(
                'Email: mirzai.edc@gmail.com'.tr,
                style: TextStyle(fontSize: 16), textAlign: TextAlign.justify,
              ),
               Text(
                'LinkedIn: https://af.linkedin.com/in/parwiz-mirzai-34526b337'.tr,
                style: TextStyle(fontSize: 16), textAlign: TextAlign.justify,
              ),
               Text(
                'GitHub: https://github.com/parwiz-mirzai'.tr,
                style: TextStyle(fontSize: 16), textAlign: TextAlign.justify,
              ),
               Text(
                'Phone: 0796203265'.tr,
                style: TextStyle(fontSize: 16), textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}