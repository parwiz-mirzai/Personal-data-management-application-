import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infogurd/App/Authentication/Presentation/auth_screen.dart';
import 'package:infogurd/App/Onbording/onbording_item.dart';
import 'package:infogurd/App/View/HomePage/home.dart';



import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnbordingView extends StatefulWidget {
  const OnbordingView({super.key});

  @override
  State<OnbordingView> createState() => _OnbordingViewState();
}

class _OnbordingViewState extends State<OnbordingView> {
  final controller = OnbordingItems();
  final pageController = PageController(); 
  bool isLastPage = false;
  @override  
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: isLastPage
            ? getStarted()
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip button
                  TextButton(
                    onPressed: () =>
                        pageController.jumpToPage(controller.items.length - 1),
                    child:  Text('skip'.tr),
                  ),
                  // Indicator
                  SmoothPageIndicator(
                    controller: pageController,
                    count: controller.items.length,
                    onDotClicked: (index) => pageController.animateToPage(index,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeIn),
                    effect: const WormEffect(dotHeight: 12, dotWidth: 12),
                  ),
                  // Next button
                  TextButton(
                    onPressed: () => pageController.nextPage(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeIn),
                    child:  Text("next".tr),
                  ),
                ],
              ),
      ),
      body: PageView.builder(
        onPageChanged: (index) =>
            setState(() => isLastPage = controller.items.length - 1 == index),
        itemCount: controller.items.length,
        controller: pageController,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(controller.items[index].image),
                const SizedBox(
                  height: 15,
                ),
              
                const SizedBox(
                  height: 15,
                ),
                Text(
                  controller.items[index].description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 17),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget getStarted() {
    return Container(
      decoration: BoxDecoration(
        color:primaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      width: MediaQuery.of(context).size.width * 9,
      height: 55,
      child: TextButton(
        onPressed: () async {
          final pres = await SharedPreferences.getInstance();
          pres.setBool("onbording", true);
          // ignore: use_build_context_synchronously
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AuthScreen(),
            ),
          );
        },
        child:  Text(
          "getstarted".tr,
          style:const  TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
