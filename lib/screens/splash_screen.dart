import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_page_transition/page_transition_type.dart';
import 'dart:async';
import 'package:fluttertododemo/custom_route_transition.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {

  AnimationController _controller;
  Animation<double> _animation;

  Widget customRounds(Color color, double size) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(size / 2)),
        color: color,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 3), vsync: this, value: 0.1);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.bounceInOut);
    _controller.forward();
    Timer(Duration(seconds: 4), () {
      print("move to home");
      Navigator.of(context).pushReplacement(CustomRoute(page: HomeScreen(), type: PageTransitionType.fadeIn));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: ScaleTransition(
                  scale: _animation,
                  alignment: Alignment.center,
                child: Column(
                  children: <Widget>[
                    Image.asset("assets/images/icon.png"),
                    SizedBox(height: 10,),
                    Image.asset("assets/images/splash_image.png"),
                  ],
                ),
              ),
            ),
            Align(
                alignment: Alignment.topRight,
                child: ScaleTransition(
                    scale: _animation,
                    child: Container(
                      padding: EdgeInsets.only(top: 30, right: 10),
                        child: customRounds(Colors.lightBlueAccent, 40))
                )
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: ScaleTransition(
                  scale: _animation,
                  child: Container(
                    padding: EdgeInsets.only(left: 20, bottom: 40),
                      child: customRounds(Colors.amber, 60))
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
                child: ScaleTransition(
                    scale: _animation,
                    child: Container(
                      padding: EdgeInsets.only(left: 50, bottom: 20),
                        child: customRounds(Colors.red, 75))
                )
            ),
            Align(
                alignment: Alignment.bottomLeft,
                child: ScaleTransition(
                    scale: _animation,
                    child: Container(
                      padding: EdgeInsets.only(left: 20, bottom: 30),
                        child: customRounds(Colors.greenAccent, 45))
                )
            ),
          ],
        ),
      ),
    );
  }
}
