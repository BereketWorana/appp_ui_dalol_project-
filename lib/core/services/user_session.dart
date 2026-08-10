class UserSession {
  // CHANGE THIS VALUE TO TEST DIFFERENT USERS
  //
  // consumer
  // creator
  // merchant

  static String role = "consumer";

  static bool isLoggedIn = true;

  static bool get isConsumer {
    return role == "consumer";
  }

  static bool get isCreator {
    return role == "creator";
  }

  static bool get isMerchant {
    return role == "merchant";
  }
}
