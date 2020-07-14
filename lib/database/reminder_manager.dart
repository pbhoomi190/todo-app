import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertododemo/constants/extensions.dart';
import 'ToDo.dart';

class ReminderManager {

  static ReminderManager _reminderManager;
  static FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  static const int idAdder = 10000;
  ReminderManager._createInstance();

  factory ReminderManager() {
    if (_reminderManager == null) {
      _reminderManager = ReminderManager._createInstance();
    }
    return _reminderManager;
  }

  get reminder {
    if (_flutterLocalNotificationsPlugin == null) {
      _flutterLocalNotificationsPlugin = setup();
    }
    return _flutterLocalNotificationsPlugin;
  }

  FlutterLocalNotificationsPlugin setup() {
    _flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);

    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);

    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    return _flutterLocalNotificationsPlugin;
  }

  void setReminder(ToDo toDo, int reminderId, int time) async {
    FlutterLocalNotificationsPlugin reminder = this.reminder;

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    DateTime reminderBefore = toDo.date.dateFromInt().subtract(Duration(minutes: time));
    DateTime taskTime = toDo.date.dateFromInt();
    int id = reminderId + idAdder;
    await reminder.schedule(id, toDo.title, "Time for your task: ${toDo.title}", taskTime, platformChannelSpecifics);
    await reminder.schedule(reminderId,
        toDo.title, "You should start your task: ${toDo.title} in $time minutes.",
        reminderBefore, platformChannelSpecifics);

  }

  Future onSelectNotification(String payload) async {
    print('on select notification called $payload');
    return Future.value(0);
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    print('did receive local Notification clicked');
    return Future.value(1);
  }

  void removeReminder(int reminderID) {
    FlutterLocalNotificationsPlugin reminder = this.reminder;
    reminder.cancel(idAdder - reminderID);
    reminder.cancel(reminderID);
  }

  void removeAllReminder() {
    FlutterLocalNotificationsPlugin reminder = this.reminder;
    reminder.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingReminders() async {
    FlutterLocalNotificationsPlugin reminder = this.reminder;
    var results = await reminder.pendingNotificationRequests();
    return results;
  }
}