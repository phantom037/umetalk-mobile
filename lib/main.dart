import 'package:flutter/material.dart';
import 'package:ume_talk/Screen/Splash_Screen.dart';
import 'package:ume_talk/testing/InitializeSplashScreen.dart';
import 'package:ume_talk/testing/NavigationMenu.dart';
import 'package:ume_talk/testing/Testing_SettingScreen.dart';
import 'package:ume_talk/Screen/Welcome_Screen.dart';
import 'package:ume_talk/data/repository/UmeTalkUserRepositoryImpl.dart';
import 'package:ume_talk/presentation/UmeTalkUserProvider.dart';
import 'package:ume_talk/testing/testprofile1.dart';
import 'package:ume_talk/testing/testprofile2.dart';
import 'constant/themeColor.dart';
import 'Screen/Login_Screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:new_version/new_version.dart';
import 'dart:convert';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:ume_talk/Models/themeData.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/datasource/FirebaseDataSource.dart';
import 'domain/repository/UmeTalkUserRepository.dart';


// void main() async {
//   await WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//
//   runApp(ChangeNotifierProvider(
//       create: (context) => UserThemeData(), child: MaterialApp(debugShowCheckedModeBanner: false, home: UmeTalk())));
// }

void main() async {
  // Ensure Flutter binding is initialized
  await WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Run the app with MultiProvider
  runApp(
    MultiProvider(
      providers: [
        // Provider for UserThemeData
        ChangeNotifierProvider(create: (context) => UserThemeData()),

        // Provider for AuthProvider
        ChangeNotifierProvider(
          create: (_) => UmeTalkUserProvider(
            umeTalkUserRepository: UmeTalkUserRepositoryImpl(
              dataSource: FirebaseDataSource(),
            ),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: UmeTalk(),
      ),
    ),
  );
}

class UmeTalk extends StatelessWidget {
  const UmeTalk({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyApp();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool hasInternet = true;
  late bool acceptPolicy = false;
  @override
  void initState() {
    super.initState();
    checkVersion();
    InternetConnectionChecker().onStatusChange.listen((event) {
      final hasInternet = event == InternetConnectionStatus.connected;
      setState(() {
        this.hasInternet = hasInternet;
      });
    });
    checkPrivacy();
  }

  void checkPrivacy() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    try{
      this.acceptPolicy = preferences.getBool("acceptPolicy") ?? false;
    }catch (e){
      preferences.setBool("acceptPolicy", false);
      this.acceptPolicy = false;
    }
  }

  void checkVersion() async {
    var url = Uri.parse('https://dlmocha.com/app/appUpdate.json');
    http.Response response = await http.get(url);
    var update = jsonDecode(response.body)['Ume Talk']['version'];
    var version = "2.2.1";
    // Instantiate NewVersion manager object (Using GCP Console app as example)
    final newVersion = NewVersion(
      iOSId: 'com.leotran9x.umeTalk',
      androidId: 'com.leotran9x.ume_talk',
    );
    final status = await newVersion.getVersionStatus();
    if (update != version && status != null) {
      newVersion.showUpdateDialog(
        context: context,
        versionStatus: status,
        dismissButtonText: "Skip",
        dialogTitle: 'New Version Available',
        dialogText:
            'The new app version $update is available now. Please update to have a better experience.'
            '\nIf you already updated please skip.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return hasInternet
        ?
        //Navigationmenu()
    //UserProfile()
    FutureBuilder(
            future: Firebase.initializeApp(),
            builder: (context, snapshot) {
              // Check for errors
              if (snapshot.hasError) {
                return MaterialApp(
                  title: 'Error',
                  theme: ThemeData(
                    primaryColor: Colors.lightBlueAccent,
                  ),
                  home: Container(
                    child: Center(
                      child: Text(
                        "Error",
                        style: TextStyle(fontSize: 45, color: Colors.black),
                      ),
                    ),
                  ),
                  debugShowCheckedModeBanner: false,
                );
              }
              // Once complete, show your application
              if (snapshot.connectionState == ConnectionState.done) {
                return FirebaseAuth.instance.currentUser != null
                    ? MaterialApp(
                        title: 'Ume Talk',
                        theme: ThemeData(
                          primaryColor: Colors.lightBlueAccent,
                        ),
                        home: InitializeSplashScreen(acceptPolicy: acceptPolicy,),
                        debugShowCheckedModeBanner: false,
                      )
                    : MaterialApp(
                        title: 'Ume Talk',
                        theme: ThemeData(
                          primaryColor: Colors.lightBlueAccent,
                        ),
                        home: WelcomePage(),
                        debugShowCheckedModeBanner: false,
                      );
              }

              // Otherwise, show something whilst waiting for initialization to complete
              return MaterialApp(
                title: 'Ume Talk',
                theme: ThemeData(
                  primaryColor: backgroundColor,
                ),
                  home: Container(
                    color: backgroundColor,
                    //child: Text("Hello World"),
                  ),
                debugShowCheckedModeBanner: false,
              );
            },
          )
        : MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: Colors.black54,
              body: Center(child: Lottie.asset('images/lostConnection.json')),
            ),
          );
  }
}
