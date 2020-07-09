import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:fluttertododemo/database/reminder_manager.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertododemo/constants/extensions.dart';
import 'ToDo.dart';

class DatabaseHelper {

  static DatabaseHelper _databaseHelper;
  static Database _database;
  ReminderManager manager = ReminderManager();

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  // Getter for database
  Future<Database> get database async {
    if (_database == null) {
      _database = await initDatabase();
    }
    return _database;
  }

  // Initialize database
  Future<Database> initDatabase() async {
    // Get path for directory
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';
    //Open/Create database at this path
    var todoDatabase = await openDatabase(path, version: 1, onCreate: _createDB);
    return todoDatabase;
  }

  // Create Database
  Future _createDB(Database db, int newVersion) async {
    await db.execute('CREATE TABLE $tableName('
        '$colId INTEGER PRIMARY KEY AUTOINCREMENT, '
        '$colTitle TEXT, '
        '$colDescription TEXT, '
        '$colDate INTEGER, '
        '$colCategory TEXT, '
        '$colReminder INTEGER, '
        '$colFavourite INTEGER, '
        '$colCompleted INTEGER)');
    await db.execute('CREATE TABLE $reminderTable('
        '$reminderColId INTEGER PRIMARY KEY AUTOINCREMENT, '
        '$reminderColName TEXT, '
        '$reminderColTime INTEGER, '
        '$reminderColSelected INTEGER)'
    ).then((value) {
      Reminder.getAllReminder().forEach((element) {
        addReminder(element);
      });
    });
  }

  getDatabase() async {
    Database db = await this.database;
  }

  // Putting the arguments in curly braces makes it optional :
  // String title, String description, String date, String category, {int isReminderOn = 1, int isFavourite = 0}

  // Add new reminder
  Future<int> addReminder(Reminder reminder) async {
    debugPrint("Reminder to add:- ${reminder.toMap()}");
    Database db = await this.database;
    var result = await db.insert(reminderTable, reminder.toMap());
    print("Created reminder item response integer: === $result");
    return result;
  }

  // Get time of reminder set by user default is 1 hour
  Future<int> getReminderTime() async {
    Database db = await this.database;
    var results = await db.rawQuery('SELECT * FROM $reminderTable WHERE $reminderColSelected = 1');
    List<Reminder> reminder = [];
    results.forEach((element) {
       reminder.add(Reminder.fromMap(element));
    });
    debugPrint("Selected reminder time ===> ${reminder.first.name}");
    return reminder.first.time;
  }

  // called when Change reminder time from setting screen
  Future setSelectedForReminder(Reminder reminder, int selected) async {
    Database db = await this.database;
    var result = await db.rawQuery('UPDATE $reminderTable SET $reminderColSelected = $selected WHERE $reminderColId == ${reminder.id}');
    debugPrint("Result of set selected reminder ===> $result Time for reminder ===> ${reminder.time}");
    return result;
  }

  // Called on setting screen to show list of reminder times
  Future<List<Map<String, dynamic>>> fetchReminders() async {
    Database db = await this.database;
    print("Databse==================$db");
    var reminders = await db.query(reminderTable);
    print("reminder================$reminders");
    return reminders;
  }

  // Called when reminder time changes from the setting screen
  updateReminderForAllToDo(int time) async {
    var allList = await fetchToDoList();
    List<ToDo> allUpcomingToDo = [];
    allList.forEach((element) {
      var todo = ToDo.fromMap(element);
      allUpcomingToDo.add(todo);
    });
    var notifications = await manager.getPendingReminders();
    notifications.forEach((reminder) {
      var todo = allUpcomingToDo.firstWhere((todo) {
        return todo.id == reminder.id;
      });
      manager.removeReminder(reminder.id);
      manager.setReminder(todo, reminder.id, time);
    });
  }

  // Add To-Do item
  Future<int> createToDoListItem(ToDo toDo) async {
    debugPrint("TODO to add:- ${toDo.toMap()}");
    Database db = await this.database;
    var result = await db.insert(tableName, toDo.toMap());
    print("Created todo item response integer: === $result");
    if (toDo.isReminderOn == 1) {
      int time = await getReminderTime();
      manager.setReminder(toDo, result, time);
    }
    return result;
  }

  // Get list of To-Do items
  Future<List<Map<String, dynamic>>> fetchToDoList() async {
    Database db = await this.database;
    int today = DateTime.now().millisecondsSinceEpoch;
    var result = await db.query(tableName, where: '$colDate > $today AND $colCompleted = 0');
    return result;
  }

  // Delete To-Do
  Future<int> deleteToDoItem(ToDo toDo) async {
    Database db = await this.database;
    var result = await db.rawDelete('DELETE FROM $tableName WHERE $colId == ${toDo.id}');
    manager.removeReminder(toDo.id);
    return result;
  }

  // Mark To-Do item as favourite
  Future markFavouriteToDoItem(ToDo todo, int isFav) async {
    Database db = await this.database;
    var result = await db.rawQuery('UPDATE $tableName SET $colFavourite = $isFav WHERE $colId == ${todo.id}');
    return result;
  }

  Future markCompletedToDoItem(ToDo toDo) async {
    Database db = await this.database;
    var result = await db.rawQuery('UPDATE $tableName SET $colCompleted = 1 WHERE $colId == ${toDo.id}');
    return result;
  }

  // Turn on/off reminder for To-Do
  Future turnOnOffReminderToDoItem(ToDo todo, int isOn) async {
    Database db = await this.database;
    var result = await db.rawQuery('UPDATE $tableName SET $colReminder = $isOn AND $colDate = ${todo.date} WHERE $colId == ${todo.id}');
    if (isOn == 0) {
      // cancel the reminder
      debugPrint("Reminder deleted");
      manager.removeReminder(todo.id);
    } else {
      // create the reminder
      debugPrint("Reminder added for ${todo.date.dateFromInt()}");
      int time = await getReminderTime();
      manager.setReminder(todo, todo.id, time);
    }
    return result;
  }

  // Update To-Do
  Future updateToDoItem(ToDo todo) async {
    Database db = await this.database;
    try {
      var result = await db.rawQuery('UPDATE $tableName '
          'SET  $colTitle = "${todo.title}",'
          '$colDescription = "${todo.description}",'
          '$colCategory = "${todo.category}",'
          '$colDate = "${todo.date}",'
          '$colReminder = ${todo.isReminderOn}, '
          '$colFavourite = ${todo.isFavourite} '
          'WHERE $colId == ${todo.id}');
      return result;
    } catch (error) {
      debugPrint(error);
    }

  }

    // Get this month to-do
    Future<List<Map<String, dynamic>>> getThisMonthToDo() async {
    int today = DateTime.now().millisecondsSinceEpoch;
    int lastDate = DateTime.now().getLastDayOfMonth().millisecondsSinceEpoch;
    Database db = await this.database;
    var result = await db.query(tableName, where: '$colDate >= $today AND $colDate < $lastDate AND $colCompleted = 0' );
    return result;
  }

  // Get after this month to-do
  Future<List<Map<String, dynamic>>> getAfterThisMonthToDo() async {
    int lastDate = DateTime.now().getLastDayOfMonth().millisecondsSinceEpoch;
    Database db = await this.database;
    var result = await db.query(tableName, where: '$colDate > $lastDate AND $colCompleted = 0' );
    return result;
  }

  // Get completed to-do
  Future<List<Map<String, dynamic>>> getCompletedToDo() async {
    int today = DateTime.now().millisecondsSinceEpoch;
    Database db = await this.database;
    var result = await db.query(tableName, where: '$colDate < $today OR $colCompleted = 1');
    return result;
  }

  // Get favorite to-do
  Future<List<Map<String, dynamic>>> getFavoriteToDo() async {
    Database db = await this.database;
    int today = DateTime.now().millisecondsSinceEpoch;
    var result = await db.query(tableName, where: '$colFavourite = 1 AND $colDate > $today AND $colCompleted = 0' );
    return result;
  }

}