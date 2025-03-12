import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:crypto/crypto.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:ume_talk/data/model/UserModel.dart';

import '../../presentation/UmeTalkUserProvider.dart';


class FirebaseDataSource{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  late final Timer? timer;
  /**
   * Handling Google Sign In
   */
  Future googleSignIn() async {
    GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAuthentication =
    await googleUser!.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleSignInAuthentication.idToken,
      accessToken: googleSignInAuthentication.accessToken,
    );
    User? user = (await _firebaseAuth.signInWithCredential(credential)).user;

    return checkLoginInStatus(user);
  }

  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /**
   * Handling Apple Sign In
   */
  Future appleSignIn() async {
    try {
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);
      var result = await SignInWithApple.getAppleIDCredential(scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ], nonce: nonce);

      final appleCredential = await OAuthProvider("apple.com").credential(
          accessToken: result.identityToken,
          rawNonce: rawNonce,
          idToken: result.identityToken);

      final authResult = await _firebaseAuth.signInWithCredential(appleCredential);
      User? user = authResult.user;

      return checkLoginInStatus(user);
    } on Error catch (e) {
      // Fluttertoast.showToast(
      //     toastLength: Toast.LENGTH_LONG,
      //     msg: "Apple sign in request IOS 14+");
    }
  }

  /**
   * Handling default email sign in
   */
  Future emailLogin(String email, String password) async {
    try {
      User? user = (await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password))
          .user;

      if (user != null && user.emailVerified) {
        return checkLoginInStatus(user);

      } else {
        user!.sendEmailVerification();
        // Fluttertoast.showToast(msg: "Check your email to verify account");
      }
    } on FirebaseAuthException catch (error) {
      // switch (error.code) {

      // }
      throw _handleFirebaseAuthException(error);
    }
  }

  /**
   * Check the user status from database
   */
  Future<UserModel?> checkLoginInStatus(User? user) async {
    ///Check if Login Success
    if (user != null) {
      final QuerySnapshot resultQuery = await FirebaseFirestore.instance
          .collection("user")
          .where("id", isEqualTo: user.uid)
          .get();
      final List<DocumentSnapshot> documentSnapshots = resultQuery.docs;

      ///New User write data to Firebase
      if (documentSnapshots.length == 0) {
        String convert =
        user.displayName.toString().toLowerCase().replaceAll(' ', '');
        var arraySearchID = List.filled(convert.length, "");
        if (user.displayName != null) {
          for (int i = 0; i < convert.length; i++) {
            arraySearchID[i] =
                convert.substring(0, i + 1).toString().toLowerCase();
          }
        } else {
          String newUnknownUserName = "user" + user.uid.substring(0, 9);
          arraySearchID = new List.filled(newUnknownUserName.length, "");
          for (int i = 0; i < newUnknownUserName.length; i++) {
            arraySearchID[i] =
                newUnknownUserName.substring(0, i + 1).toString().toLowerCase();
          }
        }
        Map<String, dynamic> data = {
          "name": (user.displayName != null || user.displayName == "null")
              ? user.displayName
              : "User " + user.uid.substring(0, 9),
          "photoUrl": user.photoURL != null
              ? user.photoURL
              : "https://dlmocha.com/app/Ume-Talk/userDefaultAvatar.jpeg",
          "id": user.uid,
          "about": "None",
          "createdAt": DateTime.now().toString(),
          "chatWith": null,
          "searchID": arraySearchID,
          "updateNewChatList": false,
          "token": "No-data",
        };

        FirebaseFirestore.instance.collection("user").doc(user.uid).set(data);
        //Write data to Local
        return UserModel.fromMap(data);

      } else {
        ///Check if already SignedUp User
        //Write data to Local
        return UserModel.fromFirebase(documentSnapshots[0]);
      }
    } else {
      ///SignIn fail
      // return Exception("Too many requests. Try again later.");
      print("Error");
    }
  }

  Future register(String email, String password) async{
    try {
      User? newUser = (await _firebaseAuth.createUserWithEmailAndPassword(
      email: email, password: password)).user;
      if (newUser != null) {
        //await verifyEmail(newUser);
        // return checkLoginInStatus(newUser);
        Map<String, dynamic> temp = {
          "name": "Unknown",
          "photoUrl": "https://dlmocha.com/app/Ume-Talk/userDefaultAvatar.jpeg",
          "id": newUser.uid,
          "about": "None",
          "createdAt": DateTime.now().toString(),
          "chatWith": null,
          "searchID": [],
          "updateNewChatList": false,
          "token": "No-data",
        };
        return UserModel.fromMap(temp);
      }
    } on FirebaseAuthException catch (error) {
      throw _handleFirebaseAuthException(error);
    }
  }

  Future<UserModel?> verifyEmail(User? user) async{
    if (!(user!.emailVerified)) {
      await user.sendEmailVerification();
      //Fluttertoast.showToast(msg: "Check your email to verify account");
      await Timer.periodic(Duration(seconds: 3), (_) => checkEmailVerified(user));
      // setState(() {
      //   errorMessage = "Check email to verify!";
      // });
    }
  }

  Future checkEmailVerified(User? user) async {
    await user?.reload();
    User? updatedUser = _firebaseAuth.currentUser;

    if (updatedUser != null && updatedUser.emailVerified) {
      timer?.cancel();
    }
  }

  Exception _handleFirebaseAuthException(FirebaseAuthException error) {
    switch (error.code) {
      case "wrong-password":
        return Exception("Password is incorrect.");
      case "user-not-found":
        return Exception("User with this email doesn't exist.");
      case "user-disabled":
        return Exception("Your account has been disabled.");
      case "too-many-requests":
        return Exception("Too many requests. Try again later.");
      case "invalid-email":
        return Exception("Email is badly formatted.");
      case "weak-password":
        return Exception("Password requires at least 6 letters.");
      case "email-already-in-use":
        return Exception("This email has already been used.");
      case "too-many-requests":
        return Exception("Too many requests. Try again later.");
      default:
        return Exception("An undefined error happened: ${error.message}");
    }
  }

  Future<void> updateUserChatList(String userId, String name, String address) async {
    //await _firebaseAuth.currentUser?.updateDisplayName(name);
    // You can also update additional fields in Firestore if needed.
  }

  Future<UserModel> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if(user != null){
      final QuerySnapshot resultQuery = await FirebaseFirestore.instance
          .collection("user")
          .where("id", isEqualTo: user.uid)
          .get();
      final List<DocumentSnapshot> documentSnapshots = resultQuery.docs;
      return UserModel.fromFirebase(documentSnapshots[0]);
    }
    throw Exception('User not logged in');
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }

  Future<UserModel> updateUserProfileInfo(String userId, String name, String photoUrl, String about) async {
    /// TODO: Implement
    return UserModel.fromMap(new HashMap());
  }

  // Stream<UserModel> listenToUserUpdates(String userId){
  //   return _firestore.collection('user').doc(userId).snapshots().map((doc) {
  //     if (doc.exists) {
  //       return UserModel(
  //         id: doc.id,
  //         name: doc['name'],
  //         photoUrl: doc['photoUrl'],
  //         about: doc['about'],
  //         chatWith: List<dynamic>.from(doc['chatWith'] ?? []),
  //         createdAt: doc['createdAt'],
  //         token: doc['token'],
  //         updateNewChatList: doc['updateNewChatList'] ?? false,
  //       );
  //     } else {
  //       throw Exception('User document does not exist');
  //     }
  //   }).distinct((prev, next) {
  //     // Properly compare the chatWith lists
  //     if (prev.chatWith == null && next.chatWith == null) return true;
  //     if (prev.chatWith == null || next.chatWith == null) return false;
  //
  //     final prevList = List<String>.from(prev.chatWith!);
  //     final nextList = List<String>.from(next.chatWith!);
  //
  //     if (prevList.length != nextList.length) return false;
  //
  //     for (int i = 0; i < prevList.length; i++) {
  //       if (prevList[i] != nextList[i]) return false;
  //     }
  //     return true;
  //   });
  // }
}