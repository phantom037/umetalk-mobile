import 'package:ume_talk/data/model/UserModel.dart';

import '../../domain/entity/UmeTalkUser.dart';
import '../../domain/repository/UmeTalkUserRepository.dart';
import '../../data/datasource/FirebaseDataSource.dart';

class UmeTalkUserRepositoryImpl implements UmeTalkUserRepository {
  final FirebaseDataSource dataSource;

  UmeTalkUserRepositoryImpl({required this.dataSource});

  @override
  Future<UmeTalkUser> emailLogin(String email, String password) async {
    return await dataSource.emailLogin(email, password);
  }

  @override
  Future<UmeTalkUser> appleSignIn() async {
    return await dataSource.appleSignIn();
  }

  @override
  Future<UmeTalkUser> googleSignIn() async {
    return await dataSource.googleSignIn();
  }

  @override
  Future<UmeTalkUser> register(String email, String password) async {
    try {
      return await dataSource.register(email, password);
    } catch (e) {
      // Re-throw the exception to be handled by the presentation layer
      rethrow;
    }
  }

  @override
  Future<UmeTalkUser> updateUserProfileInfo(String userId, String name, String photoUrl, String about) async {
    return await dataSource.updateUserProfileInfo(userId, name, photoUrl, about);
  }

  @override
  Future<UmeTalkUser> getCurrentUser() async {
    return await dataSource.getCurrentUser();
  }

  @override
  Future<void> logout() async {
    return await dataSource.logout();
  }

  @override
  Future<UmeTalkUser> updateUserProfile(String userId, String name, String address) {
    // TODO: implement updateUserProfile
    throw UnimplementedError();
  }

  // @override
  // Stream<UmeTalkUser> listenToUserUpdates(String userId) {
  //   return dataSource.listenToUserUpdates(userId);
  // }

  @override
  Future<UmeTalkUser?> clearUser() async{
    return null;
  }

}