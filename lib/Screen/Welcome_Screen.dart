import 'package:flutter/material.dart';
import 'package:ume_talk/Screen/Login_Screen.dart';
import '../constant/themeColor.dart';
import 'Registration_Screen.dart';
import 'package:url_launcher/url_launcher.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Container(
              color: backgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                //crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: 50,),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30), // Adjust as needed
                      border: Border.all(
                        color: Colors.transparent, // Border color
                        width: 3.0, // Border width
                      ),
                    ),
                    width: 180,
                    height: 180,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30), // Same as outer container
                      child: Image.asset(
                        "images/UmeTalk.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 40.0,
                  ),
                  const Text("Welcome to UmeTalk", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        "By continue you agree with",
                        style: TextStyle(fontSize: 15, color: Colors.black45),
                      ),
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
                              fontSize: 15.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          onTap: () {
                            launch("https://dlmocha.com/app/UmeTalk-privacy");
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  const SizedBox(height: 350.0),
                  const SizedBox(
                    height: 20.0,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 100,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
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
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                                return LoginScreen();
                              }));
                        },
                        child: Container(
                          width: 400.0,
                          height: 60.0,
                          alignment: Alignment.center,
                          child: const Text(
                            'Log In',
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
                const SizedBox(height: 5,),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2),
                  child: Material(
                    borderRadius: const BorderRadius.all(Radius.circular(19.0)),
                    elevation: 5.0,
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(19.0),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(19.0),
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                                return RegistrationScreen();
                              }));
                        },
                        child: Container(
                          width: 400.0,
                          height: 60.0,
                          alignment: Alignment.center,
                          child: const Text(
                            'Sign Up',
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
