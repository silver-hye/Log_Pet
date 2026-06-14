class User {
  String userId;
  String password;
  String nickname;

  User({
    required this.userId,
    required this.password,
    required this.nickname,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'password': password,
      'nickname': nickname,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['userId'],
      password: map['password'],
      nickname: map['nickname'],
    );
  }
}