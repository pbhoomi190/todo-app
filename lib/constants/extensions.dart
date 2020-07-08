import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'category.dart';
import 'constants.dart';

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

// Extension to create datetime to string
extension dateToInt on DateTime {
   int currentTimeInSeconds() {
    var ms = this.millisecondsSinceEpoch;
    return (ms / 1000).round();
  }

  Future<String> formattedDateString() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var locale = prefs.getString('locale') ?? "en";
    final intl.DateFormat dateFormat = intl.DateFormat("dd LLL, yyyy hh:mm a", locale);
    var dateStr = dateFormat.format(this);
    return dateStr;
  }

  DateTime getLastDayOfMonth() {
     int thisDay = this.day;
     bool isLeapYear = this.year.isLeapYear();
     int daysOfMonth = this.month.getDaysOfMonth(isLeapYear: isLeapYear);
     int remainingDaysOfMonth = daysOfMonth - thisDay;
     DateTime lastDay = this.add(Duration(days: remainingDaysOfMonth + 1));
     print("Last day of month === $lastDay in int === ${lastDay.millisecondsSinceEpoch}");
     return lastDay;
  }

  DateTime getLastDayOfWeek() {
      int thisDay = this.weekday;
      int remainingDays = thisDay.getRemainingDaysOfWeek();
      DateTime lastDay = this.add(Duration(days: remainingDays));
      return lastDay;
  }
}

extension intToDates on int {
    Future<String> dateString() async {
      var dateTime = DateTime.fromMillisecondsSinceEpoch(this);
      var dateStr = await dateTime.formattedDateString();
      return dateStr;
    }

    DateTime dateFromInt() {
      return DateTime.fromMillisecondsSinceEpoch(this);
    }

    bool isLeapYear() {
      if(this%4==0)
      {
        if(this%100==0)
        {
          if(this%400==0)
          {
            return true;
          } else {
            return false;
          }
        } else {
          return true;
        }
      } else {
        return false;
      }
    }

    int getDaysOfMonth({bool isLeapYear = false}) {
      switch (this) {
        case 1:
        case 3:
        case 5:
        case 7:
        case 8:
        case 10:
        case 12:
          return 31;
        case 4:
        case 6:
        case 9:
        case 11:
          return 30;
        case 2:
          return isLeapYear ? 29 : 28;
        default:
          return 30;
      }
    }

    int getRemainingDaysOfWeek() {
      switch (this) {
        case 1:
          return 6;
        case 2:
          return 5;
        case 3:
          return 4;
        case 4:
          return 3;
        case 5:
          return 2;
        case 6:
          return 1;
        case 7:
          return 0;
        default:
          return 6;
      }
    }

}

extension getCategoryType on String {

  int dateToInt() {
    DateTime date = new DateFormat("yyyy-MM-dd hh:mm:ss").parse(this);
    return date.millisecondsSinceEpoch;
  }

  CategoryType categoryType() {
    switch (this) {
      case "Shopping":
        return  CategoryType.shopping;
      case "Event":
        return CategoryType.event;
      case "Meeting":
        return CategoryType.meeting;
      case "Work":
        return CategoryType.work;
      case "Trip":
        return CategoryType.trip;
      case "Other":
        return CategoryType.other;
      case "Show All":
        return CategoryType.all;
      case "Favorites":
        return CategoryType.favorites;
    }
    return CategoryType.other;
  }

  String categoryImage() {
    switch (this) {
      case "Shopping":
        return shoppingImage;
      case "Event":
        return eventImage;
      case "Meeting":
        return meetingImage;
      case "Work":
        return workImage;
      case "Trip":
        return tripImage;
      case "Other":
        return otherImage;
      case "all":
        return allImage;
      case "favourites":
        return favImage;

    }
    return otherImage;
  }
}
