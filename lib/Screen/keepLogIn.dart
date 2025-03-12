import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ume_talk/Screen/Home_Screen.dart';
import 'package:ume_talk/Screen/Login_Screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ume_talk/Screen/TermAndCondition_Screen.dart';
import 'package:provider/provider.dart';
import 'package:ume_talk/domain/entity/UmeTalkUser.dart';
import 'package:ume_talk/presentation/UmeTalkUserProvider.dart';
import 'package:ume_talk/testing/NavigationMenu.dart';


class KeepLogin extends StatefulWidget {
  // final bool acceptPolicy;
  // const KeepLogin({Key? key, required this.acceptPolicy});
  @override
  _KeepLoginState createState() => _KeepLoginState();
}

class _KeepLoginState extends State<KeepLogin> {
  // final bool acceptPolicy;
  // _KeepLoginState({Key? key, required this.acceptPolicy});
  late User user;
  late UmeTalkUser umeTalkUser;
  late SharedPreferences preference;
  bool darkMode = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
    getThemeMode();
    onRefresh(FirebaseAuth.instance.currentUser);
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

  onRefresh(userCred) {
    // if (userCred == null) {return;}
    setState(() {
      user = userCred;
    });
  }

  @override
  Widget build(BuildContext context) {
    return umeTalkUser == null ? LoginScreen() : NavigationMenu(umeTalkUser: umeTalkUser, darkMode: darkMode); //HomeScreen(currentUserId: user.uid);
  }
}
