import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ume_talk/Models/screenTransition.dart';
import 'package:ume_talk/constant/themeColor.dart';
import 'package:ume_talk/Screen/Chat_Screen.dart';
import 'package:ume_talk/Screen/Setting_Screen.dart';
import 'package:ume_talk/Widgets/ChatWithProfile_Widget.dart';
import 'package:ume_talk/Widgets/Progress_Widget.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:new_version/new_version.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ume_talk/testing/settingScreen.dart';
import '../Models/themeData.dart';
import '../data/datasource/FirebaseDataSource.dart';
import '../domain/entity/UmeTalkUser.dart';
import '../presentation/UmeTalkUserProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessageListScreen extends StatefulWidget {
  @override
  State<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends State<MessageListScreen> {

  bool darkMode = false;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  TextEditingController searchTextEditingController = TextEditingController();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  String searchName = "";
  late bool hasAlreadyChatWithSomeone = false;
  late SharedPreferences preference;

  List<ProfileChatWith> profileChatWithList = [];

  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    // TODO: implement initState
    FlutterAppBadger.removeBadge();
    super.initState();
    checkChatList();
    ErrorWidget.builder = (FlutterErrorDetails details) => Container();
    //NotificationAPI.init();
    registerNotification();
    configureLocalNotification();
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

  /*
  void listenNotifications() =>
      NotificationAPI.onNotification.stream.listen(onClickedNotification);

  void onClickedNotification(String? payload) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return SettingsScreen();
      }));

   */

  ///Add async
  void registerNotification() async {
    await firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        //Show notification
        showNotification(message.notification!);
      }
      return;
    });
    /// TODO: For android
    // try{
    //   firebaseMessaging.getToken().then((token) {
    //     if (token != null) {
    //       FirebaseFirestore.instance
    //           .collection("user")
    //           .doc(currentUserId)
    //           .update({
    //         "token": token,
    //       }).catchError((error) {
    //         Fluttertoast.showToast(
    //             msg: "Error from firebaseMessaging" + error.toString());
    //       });
    //     }
    //   });
    // } on FirebaseException catch (e){
    //
    // }
    //for ios
    try{
      firebaseMessaging.getAPNSToken().then((token) {
        if (token != null) {
          FirebaseFirestore.instance
              .collection("user")
              .doc(currentUserId)
              .update({
            "token": token,
          }).catchError((error) {
            Fluttertoast.showToast(
                msg: "Error from firebaseMessaging" + error.toString());
          });
        }
      });
    } on Exception catch (e){

    }
  }

  void configureLocalNotification() {
    final iosSetting = IOSInitializationSettings();
    final androidSetting = AndroidInitializationSettings('app_icon');
    final settings =
    InitializationSettings(android: androidSetting, iOS: iosSetting);
    flutterLocalNotificationsPlugin.initialize(settings);
  }

  void showNotification(RemoteNotification remoteNotification) async {
    FlutterAppBadger.updateBadgeCount(1);
    AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails('com.leotran9x.ume_talk', 'Ume Talk',
        playSound: true,
        enableVibration: true,
        importance: Importance.max,
        channelShowBadge: true,
        icon: '@mipmap/app_icon'
    );
    IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();
    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: iosNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      remoteNotification.title,
      remoteNotification.body,
      notificationDetails,
      payload: null,
    );
  }

  void checkChatList() async {
    var snapshot = await FirebaseFirestore.instance
        .collection("user")
        .doc(currentUserId)
        .get();

    if (snapshot["chatWith"] != null) {
      setState(() {
        hasAlreadyChatWithSomeone = true;
      });
    }

    // Get the Firebase ID token (JWT)
    String? idToken = await FirebaseAuth.instance.currentUser?.getIdToken(false);
    if (idToken == null) {
      print("Failed to get Firebase ID token.");
      return;
    }else{
      await Clipboard.setData(ClipboardData(text: idToken));
      print("JWT copied to clipboard!");
    }
  }

  /// Todo: Instead of calling snapshot to get the current chatlist,
  /// desgin a model to store this data since init method will call
  /// checkChatList() function, then just delete from the model and
  /// send the update to firestore
  void deleteChat(String chattedUserId) async {
    var senderSnapshot = await FirebaseFirestore.instance
        .collection("user")
        .doc(currentUserId)
        .get();
    var currentUserChattedList = [];
    for (var user in senderSnapshot["chatWith"]) {
      currentUserChattedList.add(user);
    }
    currentUserChattedList.remove(chattedUserId);
    await FirebaseFirestore.instance
        .collection("user")
        .doc(currentUserId)
        .update({"chatWith": currentUserChattedList});

    await FirebaseFirestore.instance
        .collection("user")
        .doc(currentUserId)
        .update({"updateNewChatList": true});
  }

  Header() {
    return AppBar(
      backgroundColor: themeColor,
      title: Container(
        margin: const EdgeInsets.only(bottom: 4.0),
        child: TextFormField(
          style: const TextStyle(color: Colors.black, fontSize: 18.0),
          controller: searchTextEditingController,
          decoration: InputDecoration(
            hintText: "Find user",
            hintStyle: const TextStyle(color: Colors.black),
            enabledBorder: const UnderlineInputBorder(
                borderSide: const BorderSide(color: Colors.black54)),
            focusedBorder: const UnderlineInputBorder(
                borderSide: const BorderSide(color: Colors.black87)),
            filled: true,
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Colors.black,
              size: 30.0,
            ),
            suffixIcon: IconButton(
                icon: const Icon(
                  Icons.clear,
                  color: Colors.black,
                ),
                onPressed: () {
                  searchTextEditingController.clear();
                  setState(() {
                    hasAlreadyChatWithSomeone = hasAlreadyChatWithSomeone;
                    searchName = "";
                  });
                }),
          ),
          onChanged: (value) {
            setState(() {
              searchName = value;
            });
          },
        ),
      ),
      automaticallyImplyLeading: false,
      actions: <Widget>[
        IconButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return Settings1();
            }));
          },
          icon: const Icon(
            Icons.settings,
            size: 30.0,
            color: Colors.black,
          ),
          splashRadius: 0.1, // Set a small value to disable the ripple effect
          highlightColor: Colors.transparent, // Disable the highlight color
          hoverColor: Colors.transparent,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userThemeData = Provider.of<UserThemeData>(context);
    darkMode = userThemeData.updatedValue;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: darkMode ? Colors.black : backgroundColor,
        appBar: Header(),
        body: searchName == ""
        //futureSearchResult == null
            ? NoSearchResultScreen()
            : FoundUserScreen(),
      ),
    );
  }

  NoSearchResultScreen() {
    return StreamBuilder<QuerySnapshot>(
      stream: (FirebaseFirestore.instance
          .collection("user")
          .where("id", isEqualTo: currentUserId)
          .snapshots()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        final chatWithList = snapshot.data?.docs.first['chatWith'];

        if (!hasAlreadyChatWithSomeone || chatWithList == null || chatWithList.isEmpty) {
          return DefaultScreen();
        }

        return MessageListScreen(chatWithList);
      },
    );
  }

  MessageListScreen(List chatWithList){
    //final userProvider = Provider.of<UmeTalkUserProvider>(context, listen: false);
    return Container(
      color: darkMode ? Colors.black : backgroundColor,
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        itemCount: chatWithList.length,
        itemBuilder: (context, index) {
          final chattedUserId = chatWithList[index];
          final item = ProfileChatWith(
            chattedUserId: chattedUserId,
            currentUserId: currentUserId,
            darkMode: darkMode,
          );

          return Slidable(
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              extentRatio: 0.4,
              children: [
                SlidableAction(
                  onPressed: (context) async {
                    // Handle block action
                    deleteChat(chattedUserId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Blocked", style: TextStyle(fontSize: 10)),
                      ),
                    );
                  },
                  backgroundColor: Color(0xff636e72),
                  foregroundColor: Colors.white,
                  icon: Icons.block,
                  label: 'Block',
                ),
                SlidableAction(
                  onPressed: (context) async {
                    // Handle delete action
                    deleteChat(chattedUserId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Deleted", style: TextStyle(fontSize: 10)),
                      ),
                    );
                  },
                  backgroundColor: Color(0xFFFE4A49),
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Delete',
                ),
              ],
            ),
            child: item,
          );
        },
      ),
    );
  }

  DefaultScreen(){
    return Container(
      color: darkMode ? Colors.black : backgroundColor,
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            const Icon(
              Icons.group,
              color: themeColor,
              size: 200.0,
            ),
            const Text(
              "Get Started",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: themeColor,
                fontSize: 50.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  FoundUserScreen() {
    return StreamBuilder<QuerySnapshot>(
      stream: (searchName != "" && searchName != null)
          ? FirebaseFirestore.instance
          .collection("user")
          .where(
        "searchID",
        arrayContains: searchName.toLowerCase().replaceAll(' ', ''),
      )
          .snapshots()
          : FirebaseFirestore.instance.collection("user").snapshots(),
      builder: (context, snapshot) {
        return (snapshot.connectionState == ConnectionState.waiting)
            ? Container(
          color: darkMode ? Colors.black : backgroundColor,
          child: Center(
            child: circularProgress(),
          ),
        )
            : Container(
          color: darkMode ? Colors.black : backgroundColor,
          width: MediaQuery.of(context).size.width,
          child: ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot data = snapshot.data!.docs[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ListTile(
                      title: Text(
                        data["name"],
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: darkMode ? Colors.white : Colors.black),
                      ),
                      subtitle: Text(
                        data["about"],
                        style: const TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w300,
                            color: Colors.grey),
                      ),
                      leading: Container(
                        height: 78.0,
                        width: 78.0,
                        child: CircleAvatar(
                            radius: 34.0,
                            backgroundImage:
                            NetworkImage(data["photoUrl"])),
                      ), //Container
                      onTap: () {
                        try{
                          Navigator.push(context,
                              MyRoute(builder: (context) {
                                return Chat(
                                    receiverId: data["id"],
                                    receiverName: data["name"],
                                    receiverProfileImg: data["photoUrl"],
                                    receiverAbout: data["about"]
                                );
                              }));
                        }on Exception catch(e){
                        }
                      },
                    ),
                  ],
                );
              }),
        );
      },
    );
  }
}
