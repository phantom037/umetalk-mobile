import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ume_talk/domain/entity/UmeTalkUser.dart';

class UserModel extends UmeTalkUser{
  UserModel({
    required String id,
    required String name,
    required String photoUrl,
    String? about,
    List<dynamic>? chatWith,
    required String? createdAt,
    String? token,
    bool? updateNewChatList
  }) : super(id: id, name: name, photoUrl: photoUrl, about: about,
    chatWith: chatWith, createdAt: createdAt, token: token, updateNewChatList: updateNewChatList);

  factory UserModel.fromFirebase(DocumentSnapshot doc) {
    return UserModel(
      id: doc['id'],
      name: doc['name'],
      photoUrl: doc['photoUrl'],
      about: doc['about'],
      chatWith: doc['chatWith'],
      createdAt: doc['createdAt'],
      token: doc['token'],
      updateNewChatList: doc['updateNewChatList'],
    );
  }
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      photoUrl: map['photoUrl'],
      about: map['about'],
      chatWith: map['chatWith'],
      createdAt: map['createdAt'],
      token: map['token'],
      updateNewChatList: map['updateNewChatList'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'photoUrl': photoUrl,
      'about': about,
      'chatWith': chatWith,
      'createdAt': createdAt,
      'token': token,
      'updateNewChatList': updateNewChatList
    };
  }
}
