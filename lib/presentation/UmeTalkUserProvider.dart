
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:ume_talk/domain/entity/UmeTalkUser.dart';

import '../domain/repository/UmeTalkUserRepository.dart';

class UmeTalkUserProvider with ChangeNotifier {

  static final UmeTalkUserProvider _instance = UmeTalkUserProvider._internal();
  factory UmeTalkUserProvider({required UmeTalkUserRepository umeTalkUserRepository}) {
    _instance.umeTalkUserRepository = umeTalkUserRepository;
    return _instance;
  }
  UmeTalkUserProvider._internal();

  UmeTalkUserRepository? umeTalkUserRepository;
  UmeTalkUser? _user;
  UmeTalkUser? get user => _user;
  StreamSubscription<UmeTalkUser>? _userUpdatesSubscription;

  Future<void> loginWithEmail(String email, String password) async {
    _user = await umeTalkUserRepository!.emailLogin(email, password);
    notifyListeners();
  }

  Future<void> loginWithGoogle() async{
    _user = await umeTalkUserRepository!.googleSignIn();
    notifyListeners();
  }

  Future<void> loginWithApple() async{
    _user = await umeTalkUserRepository!.appleSignIn();
    notifyListeners();
  }

  Future<void> register(String email, String password) async {
    _user = await umeTalkUserRepository!.register(email, password);
    notifyListeners();
  }

  Future<void> updateProfile(String userId, String name, String photoUrl, String about) async {
    if (_user != null) {
      // TODO: Implemented
      _user!.copyWith(name: name, photoUrl: photoUrl, about: about);
      //notifyListeners();
    }
  }

  Future<void> logout() async {
    await umeTalkUserRepository!.logout();
    _user = await umeTalkUserRepository!.clearUser();
    notifyListeners();
  }

  Future<void> loadCurrentUser() async {
    _user = await umeTalkUserRepository!.getCurrentUser();
    notifyListeners();
  }

  Future<void> clearUserInfo() async{
    _user = await umeTalkUserRepository!.clearUser();
    notifyListeners();
  }

  // void listenToUserUpdates() {
  //   // Cancel any existing subscription
  //   _userUpdatesSubscription?.cancel();
  //
  //   // Listen to user updates
  //   _userUpdatesSubscription = umeTalkUserRepository.listenToUserUpdates(_user!.id).listen((user) {
  //     if(_user?.chatWith != user.chatWith){
  //       _user = user;
  //       notifyListeners(); // Notify UI to rebuild
  //     }
  //   });
  // }


  @override
  void dispose() {
    _userUpdatesSubscription?.cancel(); // Cancel subscription when the provider is disposed
    super.dispose();
  }
}