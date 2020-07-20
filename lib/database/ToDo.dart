import 'package:flutter/material.dart';

// Category table
final String categoryTable = "category_table";
final String categoryColId = "category_id";
final String categoryColName = "category_name";
final String categoryColImage = "category_image";
final String categoryColHidden = "category_hidden";
final String categoryColAll = "category_all";
final String categoryColFav = "category_fav";
final String categoryColDefault = "category_default";
final String categoryConstraint ="fk_categories";

// To-Do table
final String tableName = 'todo_table';
final String colId = 'id';
final String colTitle = 'title';
final String colDescription = 'description';
final String colDate = "date";
final String colReminder = "isReminderOn";
final String colFavourite = "isFavourite";
final String colCompleted = "isCompleted";
final String colReminderTune = "reminder_tune";

// Reminder table
final String reminderTable = "reminder_table";
final String reminderColId = "reminder_id";
final String reminderColName = "reminder_name";
final String reminderColTime = "reminder_time";
final String reminderColSelected = "reminder_selected";


class Categories {
  int id;
  @required String name;
  @required String image;
  @required int isHidden = 0;
  @required int isAll = 0;
  @required int isFav = 0;
  @required int isDefault = 0;

  Categories({this.id, this.name, this.image, this.isHidden, this.isAll, this.isFav, this.isDefault});

  static List<Categories> getDefaultCategories() {
    return [
      Categories(name: "Show All", image: "assets/images/all.png", isHidden: 1, isAll: 1, isFav: 0, isDefault: 1),
      Categories(name: "Favorites", image: "assets/images/fav.png" , isHidden: 1, isAll: 0, isFav: 1, isDefault: 1),
      Categories(name: "Shopping", image: "assets/images/shopping.jpg", isHidden: 0, isFav: 0, isAll: 0, isDefault: 1),
      Categories(name: "Event", image: "assets/images/event.png", isHidden: 0, isFav: 0, isAll: 0, isDefault: 1),
      Categories(name: "Meeting", image: "assets/images/meeting.jpg", isHidden: 0, isFav: 0, isAll: 0, isDefault: 1),
      Categories(name: "Work", image: "assets/images/work.png", isHidden: 0, isFav: 0, isAll: 0, isDefault: 1),
      Categories(name: "Trip", image: "assets/images/trip.png", isHidden: 0, isFav: 0, isAll: 0, isDefault: 1),
      Categories(name: "Other", image: "assets/images/todo.png", isHidden: 0, isFav: 0, isAll: 0, isDefault: 1),
    ];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      categoryColId: id,
      categoryColName: name,
      categoryColImage: image,
      categoryColHidden : isHidden,
      categoryColAll: isAll,
      categoryColFav: isFav,
      categoryColDefault: isDefault
    };
    return map;
  }

  Categories.fromMap(Map<String, dynamic> map) {
    id = map[categoryColId];
    name = map[categoryColName];
    image = map[categoryColImage];
    isAll = map[categoryColAll];
    isFav = map[categoryColFav];
    isHidden = map[categoryColHidden];
    isDefault = map[categoryColDefault];
  }
}

class Reminder {
  int id;
  @required String name;
  @required int time;
  @required int isSelected;

  Reminder({this.id, this.name, this.time, this.isSelected});

  static List<Reminder> getAllReminder() {
    return [
      Reminder(name: "15 minutes", time: 15, isSelected: 0),
      Reminder(name: "30 minutes", time: 30, isSelected: 0),
      Reminder(name: "45 minutes", time: 45, isSelected: 0),
      Reminder(name: "1 hour", time: 60, isSelected: 1),
    ];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      reminderColId: id,
      reminderColName: name,
      reminderColTime: time,
      reminderColSelected: isSelected,
    };
    return map;
  }

  Reminder.fromMap(Map<String, dynamic> map) {
    id = map[reminderColId];
    name = map[reminderColName];
    time = map[reminderColTime];
    isSelected = map[reminderColSelected];
  }
}

class ToDo {
  int id;
  @required String title;
  @required String description;
  @required int date;
  @required int category;
  @required int isReminderOn = 1;
  int isFavourite = 0;
  int isCompleted = 0;
  String reminderTune = "";

  ToDo({this.title, this.description, this.date, this.category, this.isReminderOn, this.reminderTune});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colId: id,
      colTitle: title,
      colDescription: description,
      colDate: date,
      categoryColId: category,
      colReminder: isReminderOn,
      colFavourite: isFavourite,
      colCompleted: isCompleted,
      colReminderTune: reminderTune
    };
    return map;
  }

  ToDo.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    title = map[colTitle];
    description = map[colDescription];
    date = map[colDate];
    category = map[categoryColId];
    isReminderOn = map[colReminder];
    isFavourite = map[colFavourite];
    isCompleted = map[colCompleted];
    reminderTune = map[colReminderTune];
  }
}