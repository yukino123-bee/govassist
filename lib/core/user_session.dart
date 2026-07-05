class UserSession {
  static final UserSession _instance = UserSession._internal();

  factory UserSession() {
    return _instance;
  }

  UserSession._internal();

  Map<String, dynamic>? currentUser;

  void setUser(Map<String, dynamic> user) {
    currentUser = user;
  }

  void clearSession() {
    currentUser = null;
  }
}
