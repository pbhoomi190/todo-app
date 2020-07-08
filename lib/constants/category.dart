import 'package:flutter/material.dart';

extension categoryString on CategoryType {

  String getString() {
    switch (this) {
      case CategoryType.shopping:
        return "Shopping";
      case CategoryType.event:
        return "Event";
      case CategoryType.meeting:
        return "Meeting";
      case CategoryType.work:
        return "Work";
      case CategoryType.trip:
        return "Trip";
      case CategoryType.other:
        return "Other";
      case CategoryType.all:
        return "Show All";
      case CategoryType.favorites:
        return "Favourites";
    }
    return "Other";
  }
}

enum CategoryType {
  shopping,
  event,
  meeting,
  work,
  trip,
  other,
  all,
  favorites
}


class Category {
  String id = UniqueKey().toString();
  String title;
  String image;
  CategoryType type;

  Category({this.title, this.image, this.type});

  static List<Category> getCategories() {
    return [
      Category(title: "Shopping", image: "assets/images/shopping.jpg", type: CategoryType.shopping),
      Category(title: "Event", image: "assets/images/event.png", type: CategoryType.event),
      Category(title: "Meeting", image: "assets/images/meeting.jpg", type: CategoryType.meeting),
      Category(title: "Work", image: "assets/images/work.png", type: CategoryType.work),
      Category(title: "Trip", image: "assets/images/trip.png", type: CategoryType.trip),
      Category(title: "Other", image: "assets/images/todo.png", type: CategoryType.other),
    ];
  }
}