import 'package:flutter/foundation.dart';

class NavigationRefreshNotifier extends ChangeNotifier {
  void refresh() {
    notifyListeners();
  }
}
