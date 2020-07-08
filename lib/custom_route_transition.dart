import 'package:flutter/material.dart';
import 'package:flutter_page_transition/flutter_page_transition.dart';

class CustomRoute extends PageRouteBuilder {
  Widget page;
  PageTransitionType type;
  CustomRoute({this.page, this.type}) : super(
      pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
        return page;
      },
      transitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) {
        return effectMap[type](Curves.linear, animation, secondaryAnimation, child);
      }
  );
}
