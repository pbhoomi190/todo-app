import 'package:flutter/material.dart';

final String tableName = 'todo_table';
final String colId = 'id';
final String colTitle = 'title';
final String colDescription = 'description';
final String colDate = "date";
final String colCategory = "category";
final String colReminder = "isReminderOn";
final String colFavourite = "isFavourite";

final String reminderTable = "reminder_table";
final String reminderColId = "reminder_id";
final String reminderColName = "reminder_name";
final String reminderColTime = "reminder_time";
final String reminderColSelected = "reminder_selected";


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
  @required String category;
  int isReminderOn = 1;
  int isFavourite = 0;

  ToDo({this.title, this.description, this.date, this.category});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colId: id,
      colTitle: title,
      colDescription: description,
      colDate: date,
      colCategory: category,
      colReminder: isReminderOn,
      colFavourite: isFavourite,
    };
    return map;
  }

  ToDo.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    title = map[colTitle];
    description = map[colDescription];
    date = map[colDate];
    category = map[colCategory];
    isReminderOn = map[colReminder];
    isFavourite = map[colFavourite];
  }
}