import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ume_talk/Widgets/alert.dart';
import 'package:ume_talk/constant/themeColor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ume_talk/Screen/TermAndCondition_Screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../presentation/UmeTalkUserProvider.dart';
import 'Home_Screen.dart';
import 'package:provider/provider.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  bool showSpin = false, isVerified = false;
  String email = "", password = "", errorMessage = "";
  late SharedPreferences preferences;
  late User currentUser;
  Timer? timer;

  @override
  void dispose() async{
    final userProvider = Provider.of<UmeTalkUserProvider>(context, listen: false);
    //await userProvider.logout();
    await userProvider.clearUserInfo();
    super.dispose();
  }

  void verifyEmail(User? user) async{
    if (!(user!.emailVerified)) {
      final userProvider = Provider.of<UmeTalkUserProvider>(context, listen: false);
      //await userProvider.logout();
      await userProvider.clearUserInfo();
      user.sendEmailVerification();
      timer = Timer.periodic(Duration(seconds: 3), (_) => checkEmailVerified(user));
      setState(() {
        errorMessage = "Check email to verify!";
      });
    }
  }

  Future checkEmailVerified(User? user) async {
    setState(() {
      user!.reload();
      isVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false; //user!.emailVerified;
    });
    //String link = FirebaseAuth.instance.currentUser?.getIdToken() as String;

    if (isVerified) {
      timer?.cancel();
      setState(() {
        showSpin = false;
      });
      final userProvider = Provider.of<UmeTalkUserProvider>(context, listen: false);
      await userProvider.loginWithEmail(email, password);
      Navigator.push(context, MaterialPageRoute(builder: (context) {
          return HomeScreen(
              currentUserId: user!.uid);
        }));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UmeTalkUserProvider>(context);
    var textSize = MediaQuery.of(context).textScaleFactor;
    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
        color: backgroundColor,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios_new),
              color: Colors.black,
              splashRadius: 0.1, // Set a small value to disable the ripple effect
              highlightColor: Colors.transparent, // Disable the highlight color
              hoverColor: Colors.transparent, // Disable the hover color
            ),
            backgroundColor: Colors.transparent,
            elevation: 0.0,
          ),

            body: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Center(
                      child: Text(
                        "Create yours",
                        style: TextStyle(
                            fontSize: 30.0 / textSize,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic),
                      ),
                    ),
                    const SizedBox(
                      height: 48.0,
                    ),
                    TextField(
                      keyboardType: TextInputType.emailAddress,
                      textAlign: TextAlign.start,
                      onChanged: (value) {
                        email = value;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Email',
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 20.0),
                        border: const OutlineInputBorder(
                          borderRadius: const BorderRadius.all(Radius.circular(19.0)),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.black38, width: 1.0),
                          borderRadius: const BorderRadius.all(Radius.circular(19.0)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.black45, width: 2.0),
                          borderRadius: const BorderRadius.all(Radius.circular(19.0)),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    TextField(
                      obscureText: true,
                      textAlign: TextAlign.start,
                      onChanged: (value) {
                        password = value;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Password',
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 20.0),
                        border: const OutlineInputBorder(
                          borderRadius: const BorderRadius.all(Radius.circular(19.0)),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.black38, width: 1.0),
                          borderRadius: const BorderRadius.all(Radius.circular(19.0)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.black45, width: 2.0),
                          borderRadius: const BorderRadius.all(Radius.circular(19.0)),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 24.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Material(
                        borderRadius: const BorderRadius.all(Radius.circular(19.0)),
                        elevation: 5.0,
                        child: Ink(
                          decoration: BoxDecoration(
                            color: buttonColor,
                            borderRadius: BorderRadius.circular(19.0),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(19.0),
                            onTap: () async {
                              setState(() {
                                showSpin = true;
                              });
                              await userProvider.register(email, password);
                              if(userProvider.user != null){
                                verifyEmail(firebaseAuth.currentUser);
                              }
                              // setState(() {
                              //   //Fluttertoast.showToast(msg: "Fail to register. Please try again.");
                              //   showSpin = false;
                              // });
                              // Navigator.push(context, MaterialPageRoute(builder: (context) {
                              //   return HomeScreen(
                              //       currentUserId: userProvider.user!.id);
                              // }));
                            },
                            child: Container(
                              width: 200.0,
                              height: 60.0,
                              alignment: Alignment.center,
                              child: const Text(
                                'Register',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 5.0,
                    ),
                    showAlert(errorMessage),

                    ///Todo add circular progress process registration
                    /*
                    Padding(
                      padding: EdgeInsets.all(1.0),
                      child: showSpin ? circularProgress() : Container(),
                    ),

                     */
                  ],
              ),
          ),
                ),
                Positioned(
                    left: 0,
                    right: 0,
                    bottom: 25,
                    child: Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text("By continue you agree with", style: TextStyle(fontSize: 12, color: Colors.black45),),
                      const SizedBox(
                        width: 3,
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        child: GestureDetector(
                            child: const Text(
                              "terms & condition",
                              style: TextStyle(
                                color: Colors.black45,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onTap: () {
                              launch("https://dlmocha.com/app/UmeTalk-privacy");
                            }),
                      ),
                    ],),
                ))
            ]),
        ),
      ),
    );
  }
}
