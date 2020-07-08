import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertododemo/constants/constants.dart';
import 'package:fluttertododemo/database/ToDo.dart';
import 'package:fluttertododemo/language_support/localization_manager.dart';

typedef void ReminderTimeCallback(Reminder reminder);
class TimeSelectDialog extends StatelessWidget {
  final ReminderTimeCallback onReminderTimeChange;
  final List<Reminder> reminderTimes;
  TimeSelectDialog({this.onReminderTimeChange, this.reminderTimes});

  Widget reminderTimeButton(BuildContext context, Reminder reminder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        OutlineButton(
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
          onPressed: () {
            onReminderTimeChange(reminder);
          },
          child: Text(reminder.name, style: Theme.of(context).textTheme.bodyText2),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var obj = LocalizationManager.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20))
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.45,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColorLight],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft
            ),
          borderRadius: BorderRadius.all(Radius.circular(20))
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                height: 75,
                width: 75,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(clockImage),
                  ),
                ),
              ),
              Center(child: Text(obj.getTranslatedValue("select_time"), style: Theme.of(context).textTheme.bodyText1, textAlign: TextAlign.center,)),
              const SizedBox(height: 10,),
              ListView.builder(itemBuilder: (context, index) {
                return reminderTimeButton(context, reminderTimes[index]);
              },
                itemCount: reminderTimes.length,
                shrinkWrap: true,
              )
            ],
          ),
        ),
      ),
    );
  }
}
