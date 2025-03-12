import '../entity/UmeTalkUser.dart';

abstract class UmeTalkUserRepository {
  Future<UmeTalkUser> googleSignIn();
  Future<UmeTalkUser> appleSignIn();
  Future<UmeTalkUser> emailLogin(String email, String password);
  Future<UmeTalkUser> register(String email, String password);
  Future<UmeTalkUser> updateUserProfileInfo(String userId, String name, String photoUrl, String about);
  // Stream<UmeTalkUser> listenToUserUpdates(String userId);
  Future<UmeTalkUser> getCurrentUser();
  Future<void> logout();
  Future<UmeTalkUser?> clearUser();
}