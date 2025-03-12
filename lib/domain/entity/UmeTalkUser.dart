class UmeTalkUser {
  String id;
  String name;
  String photoUrl;
  String? about;
  List<dynamic>? chatWith;
  String? createdAt;
  String? token;
  bool? updateNewChatList;

  UmeTalkUser({
    required this.id,
    required this.name,
    required this.photoUrl,
    this.about,
    this.chatWith,
    required this.createdAt,
    this.token,
    this.updateNewChatList
  });


  UmeTalkUser copyWith({
    String? id,
    String? name,
    String? photoUrl,
    String? about,
    List<String>? chatWith,
    String? createdAt,
    String? token,
    bool? updateNewChatList,
  }) {
    return UmeTalkUser(
      id: id ?? this.id,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      about: about ?? this.about,
      chatWith: chatWith ?? this.chatWith,
      createdAt: createdAt ?? this.createdAt,
      token: token ?? this.token,
      updateNewChatList: updateNewChatList ?? this.updateNewChatList,
    );
  }

  UmeTalkUser updateProfile({
    String? name,
    String? photoUrl,
    String? about,
  }) {
    return UmeTalkUser(
      id: id,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      about: about ?? this.about,
      chatWith: chatWith,
      createdAt: createdAt,
      token: token,
      updateNewChatList: updateNewChatList,
    );
  }
}
