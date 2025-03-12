import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
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
import '../Models/themeData.dart';
import '../data/datasource/FirebaseDataSource.dart';
import '../domain/entity/UmeTalkUser.dart';
import '../presentation/UmeTalkUserProvider.dart';

class HomeScreen extends StatefulWidget {
  final String currentUserId;
  HomeScreen({Key? key, required this.currentUserId}) : super(key: key);
  @override
  State createState() => HomeScreenState(currentUserId: currentUserId);
}

class HomeScreenState extends State<HomeScreen> {
  HomeScreenState({Key? key, required this.currentUserId});

  final GoogleSignIn googleSignIn = GoogleSignIn();
  TextEditingController searchTextEditingController = TextEditingController();
  final String currentUserId;
  String searchName = "";
  late bool hasAlreadyChatWithSomeone = false, darkMode = false;
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
    //checkVersion();
    //loadUserData();
    ErrorWidget.builder = (FlutterErrorDetails details) => Container();
    //NotificationAPI.init();
    registerNotification();
    configureLocalNotification();
    getThemeMode();
  }

  Future loadUserData() async{
    final userProvider = Provider.of<UmeTalkUserProvider>(context, listen: false);
    await userProvider.loadCurrentUser();
    //userProvider.listenToUserUpdates();
  }

  /*
  void listenNotifications() =>
      NotificationAPI.onNotification.stream.listen(onClickedNotification);

  void onClickedNotification(String? payload) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return SettingsScreen();
      }));

   */

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
    print("FirebaseMessaging: ${FirebaseMessaging.instance}");
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

            //styleInformation: styleInformation,
            //fullScreenIntent: true
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

  void checkChatList() async {
    var snapshot = await FirebaseFirestore.instance
        .collection("user")
        .doc(currentUserId)
        .get();

    var idChatWith = [];
    if (snapshot["chatWith"] != null) {
      setState(() {
        hasAlreadyChatWithSomeone = true;
      });
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
                return Setting();
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

  // NoSearchResultScreen() {
  //   print("NoSearchResultScreen");
  //   // final userProvider = Provider.of<UmeTalkUserProvider>(context, listen: true);
  //   // final chatWithList = userProvider.user?.chatWith;
  //   final chatWithList = context.select<UmeTalkUserProvider, List<dynamic>?>(
  //         (provider) => provider.user?.chatWith,
  //   );
  //
  //   print("chatWithList: ${chatWithList}");
  //   if (!hasAlreadyChatWithSomeone || chatWithList == null || chatWithList.isEmpty) {
  //     return Container(
  //       color: darkMode ? Colors.black : backgroundColor,
  //       child: Center(
  //         child: ListView(
  //           shrinkWrap: true,
  //           children: <Widget>[
  //             const Icon(
  //               Icons.group,
  //               color: themeColor,
  //               size: 200.0,
  //             ),
  //             const Text(
  //               "Get Started",
  //               textAlign: TextAlign.center,
  //               style: TextStyle(
  //                 color: themeColor,
  //                 fontSize: 50.0,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   }
  //
  //   // if (chatWithList != null || !chatWithList.isEmpty) {
  //   //   return Container(
  //   //     color: darkMode ? Colors.black : backgroundColor,
  //   //     child: Center(
  //   //       child: circularProgress(),
  //   //     ),
  //   //   );
  //   // }
  //   // profileChatWithList = [];
  //   // for(var user in chatWithList){
  //   //   final item = ProfileChatWith(
  //   //     chattedUserId: user,
  //   //     currentUserId: currentUserId,
  //   //     darkMode: darkMode,
  //   //   );
  //   //   profileChatWithList.add(item);
  //   // }
  //
  //   //final chatWithList = userProvider.user!.chatWith!;
  //
  //   return Container(
  //     color: darkMode ? Colors.black : backgroundColor,
  //     width: MediaQuery.of(context).size.width,
  //     child: ListView.builder(
  //       itemCount: chatWithList.length,
  //       itemBuilder: (context, index) {
  //         final chattedUserId = chatWithList[index];
  //         final item = ProfileChatWith(
  //           chattedUserId: chattedUserId,
  //           currentUserId: currentUserId,
  //           darkMode: darkMode,
  //         );
  //
  //         return Slidable(
  //           endActionPane: ActionPane(
  //             motion: const ScrollMotion(),
  //             extentRatio: 0.4,
  //             children: [
  //               SlidableAction(
  //                 onPressed: (context) async {
  //                   // Handle block action
  //                   deleteChat(chattedUserId);
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     SnackBar(
  //                       content: Text("Blocked", style: TextStyle(fontSize: 10)),
  //                     ),
  //                   );
  //                 },
  //                 backgroundColor: Color(0xff636e72),
  //                 foregroundColor: Colors.white,
  //                 icon: Icons.block,
  //                 label: 'Block',
  //               ),
  //               SlidableAction(
  //                 onPressed: (context) async {
  //                   // Handle delete action
  //                   deleteChat(chattedUserId);
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     SnackBar(
  //                       content: Text("Deleted", style: TextStyle(fontSize: 10)),
  //                     ),
  //                   );
  //                 },
  //                 backgroundColor: Color(0xFFFE4A49),
  //                 foregroundColor: Colors.white,
  //                 icon: Icons.delete,
  //                 label: 'Delete',
  //               ),
  //             ],
  //           ),
  //           child: item,
  //         );
  //       },
  //     ),
  //   );
  // }

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
    final userProvider = Provider.of<UmeTalkUserProvider>(context, listen: false);
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
    print("FoundUserScreen");
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
