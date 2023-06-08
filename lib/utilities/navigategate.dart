import 'package:flutter/material.dart';

class NavigatorNavigate {
  go(GlobalKey<NavigatorState> navState, String type) {
    switch (type) {
      case 'login':
        // navState.currentState!.pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Login  ), (route) => false);
        break;

      default:
        navState.currentState!.pushNamed('error');
    }
  }
}
