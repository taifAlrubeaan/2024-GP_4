import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sleepwell/screens/splash screen/onboarding_data.dart';
import 'package:sleepwell/screens/splash screen/welcoming_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  static String RouteScreen = 'onboarding_screen';
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = OnboardingData();
  final pageController = PageController();
  bool isLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF004AAD), Color(0xFF040E3B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                onPageChanged: (index) => setState(
                    () => isLastPage = controller.items.length - 1 == index),
                itemCount: controller.items.length,
                controller: pageController,
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        controller.items[index].image,
                        height: 300,
                      ),
                      const SizedBox(height: 50),
                      Text(
                        controller.items[index].title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          controller.items[index].descriptions,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 17),
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: isLastPage
                  ? getStarted()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Skip Button
                        TextButton(
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            prefs.setBool("onboarding", true);

                            if (!mounted) return;
                            // Navigator.pushReplacement(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: (context) => welcome()),
                            // );
                            Get.offAll(const welcome());
                          },
                          child: Text(
                            "Skip".tr,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        // Indicator
                        SmoothPageIndicator(
                          controller: pageController,
                          count: controller.items.length,
                          onDotClicked: (index) => pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          ),
                          effect: const WormEffect(
                            dotHeight: 12,
                            dotWidth: 12,
                            activeDotColor: Colors.white,
                          ),
                        ),

                        // Next Button
                        TextButton(
                          onPressed: () => pageController.nextPage(
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeIn,
                          ),
                          child: Text(
                            "Next".tr,
                            style: const TextStyle(color: Colors.white),
                          ),
                        )
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getStarted() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xffd5defe),
      ),
      width: MediaQuery.of(context).size.width * .9,
      height: 45,
      child: TextButton(
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          prefs.setBool("onboarding", true);

          if (!mounted) return;
          // Navigator.pushReplacement(
          //     context, MaterialPageRoute(builder: (context) => welcome()));
          Get.offAll(const welcome());
        },
        child: Text("Get Started".tr,
            style: const TextStyle(color: Color(0xFF040E3B), fontSize: 20)),
      ),
    );
  }
}
