import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:ume_talk/Screen/keepLogIn.dart';
import 'package:page_transition/page_transition.dart';
import 'package:lottie/lottie.dart';
import 'package:ume_talk/testing/NavigationMenu.dart';
import '../constant/themeColor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:ume_talk/presentation/UmeTalkUserProvider.dart';
import '../domain/entity/UmeTalkUser.dart';

class InitializeSplashScreen extends StatefulWidget {
  final bool acceptPolicy;
  const InitializeSplashScreen({Key? key, required this.acceptPolicy}) : super(key: key);

  @override
  State<InitializeSplashScreen> createState() => _InitializeSplashScreenState(acceptPolicy: acceptPolicy);
}

class _InitializeSplashScreenState extends State<InitializeSplashScreen> {
  final bool acceptPolicy;
  _InitializeSplashScreenState({Key? key, required this.acceptPolicy});
  UmeTalkUser umeTalkUser = UmeTalkUser(id: "id", name: "name", photoUrl: "photoUrl", createdAt: "createdAt");
  late SharedPreferences preference;
  bool darkMode = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
    getThemeMode();
  }

  void getThemeMode() async {
    preference = await SharedPreferences.getInstance();
    try{
      setState(() {
        darkMode = preference.getBool('darkMode') ??
            false; // set a default value of true if it hasn't been set before
      });
    }on Exception catch (e){
      darkMode = false;
    }
  }

  Future loadUserData() async{
    final userProvider = Provider.of<UmeTalkUserProvider>(context, listen: false);
    await userProvider.loadCurrentUser();
    umeTalkUser = userProvider.user!;
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Lottie.asset('images/splashScreen.json'),
      splashIconSize: 250,
      //duration: 3000,
      backgroundColor: backgroundColor,
      pageTransitionType: PageTransitionType.topToBottom,
      nextScreen: NavigationMenu(umeTalkUser: umeTalkUser, darkMode: darkMode),
    );
  }
}
