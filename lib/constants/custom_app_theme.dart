import 'package:flutter/material.dart';

class CustomAppTheme {

  CustomAppTheme._();

  static final ThemeData lightTheme = ThemeData(
    primaryColor: Colors.blue.shade800,
    accentColor: Colors.blue.shade200,
    fontFamily: 'Raleway',
    textTheme: ThemeData.light().textTheme.copyWith(
        bodyText1: TextStyle(
            color: Colors.brown.shade800,
            fontSize: 20,
            fontWeight: FontWeight.bold
        ),
        bodyText2: TextStyle( // Default text style for material
            color: Colors.brown.shade800,
            fontSize: 18
        ),
        headline6: TextStyle( // App bar title and Alert dialog title
            fontSize: 22.0,
            fontFamily: 'RobotoCondensed',
            fontWeight: FontWeight.bold,
            color: Colors.brown.shade900
        )
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Raleway',
    textTheme: ThemeData.dark().textTheme.copyWith(
        bodyText1: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold
        ),
        bodyText2: TextStyle( // Default text style for material
            color: Colors.white,
            fontSize: 18
        ),
        headline6: TextStyle( // App bar title and Alert dialog title
            fontSize: 22.0,
            fontFamily: 'RobotoCondensed',
            fontWeight: FontWeight.bold,
            color: Colors.white
        )
    ),
  );
}