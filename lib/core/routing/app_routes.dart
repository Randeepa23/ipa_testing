class AppRoutes {
  static const splash = '/';
  static const login = '/login';

  static const inbox = '/inbox';
  static const conversations = '/conversations';
  static const customers = '/customers';
  static const notifications = '/notifications';
  static const more = '/more';

  static const chat = '/chat/:conversationId';
  static const customerDetails = '/customer/:customerId';

  static String chatPath(String conversationId) {
    return '/chat/$conversationId';
  }

  static String customerDetailsPath(String customerId) {
    return '/customer/$customerId';
  }
}
