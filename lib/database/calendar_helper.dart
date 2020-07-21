import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluttertododemo/database/ToDo.dart';
import 'package:fluttertododemo/database/database_helper.dart';

class CalendarHelper {

  Calendar selectedCalender;
  DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();
  DatabaseHelper helper = DatabaseHelper();

  Future retrieveCalendars() async {
    try {
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess && !permissionsGranted.data) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (!permissionsGranted.isSuccess || !permissionsGranted.data) {
          return;
        }
      }

      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
        var calendars = calendarsResult?.data;
        var result = calendars.firstWhere((element) => element.isReadOnly == false);
        selectedCalender = result;
        debugPrint("Selected calendar == ${selectedCalender.accountType}   ${selectedCalender.accountName}");
    } on PlatformException catch (e) {
      print(e);
    }
  }

  Future addToCalendar(ToDo toDo) async {
    var isAllow = await _deviceCalendarPlugin.hasPermissions();
    var startDate = DateTime.fromMillisecondsSinceEpoch(toDo.date);
    Event event = Event(selectedCalender.id,
        eventId: toDo.toString(),
        title: toDo.title,
        description: toDo.description,
        start: startDate, allDay: true,
        end: startDate.add(Duration(hours: 24)));
    if (isAllow.data == true) {
      debugPrint('$_deviceCalendarPlugin  $startDate');
      var result = await _deviceCalendarPlugin.createOrUpdateEvent(event);
      debugPrint("add to calendar result ${result.data} ${result.isSuccess}");
      helper.addEventIdOnToDo(toDo, result.data);
    } else {
      var allowed = await _deviceCalendarPlugin.requestPermissions();
      if (allowed.isSuccess) {
        var result = await _deviceCalendarPlugin.createOrUpdateEvent(event);
        debugPrint("add to calendar result ${result.isSuccess}");
      }
    }
  }

  Future<ToDo> deleteFromCalendar(ToDo toDo) async{
      if (selectedCalender == null) {
        retrieveCalendars().then((value) async {
          print("to be deleted event id === ${toDo.eventId}");
          var result = await _deviceCalendarPlugin.deleteEvent(selectedCalender.id, '${toDo.eventId}');
          debugPrint('delete result === ${result.isSuccess}, event id === ${toDo.eventId} calendar id === ${selectedCalender.id}');
          if (result.isSuccess) {
            toDo.eventId = "";
            helper.addEventIdOnToDo(toDo, "");
          }
          return toDo;
        });
      }
      return toDo;
  }

  Future<ToDo> updateToCalendar(ToDo toDo) async {
    retrieveCalendars().then((value) async {
      var startDate = DateTime.fromMillisecondsSinceEpoch(toDo.date);
      var id = toDo.eventId != "" ? toDo.eventId : toDo.toString();
      Event event = Event(selectedCalender.id, eventId: id, title: toDo.title,
          description: toDo.description, start: startDate, allDay: true, end: startDate.add(Duration(hours: 24)));
      var result = await _deviceCalendarPlugin.createOrUpdateEvent(event);
      debugPrint('update result === ${result.isSuccess}, event id === ${toDo.eventId} calendar id === ${selectedCalender.id}');
      helper.addEventIdOnToDo(toDo, result.data);
      toDo.eventId = result.data;
      return toDo;
    });
    return toDo;
  }

}