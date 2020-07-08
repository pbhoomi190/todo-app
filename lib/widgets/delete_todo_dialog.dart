import 'package:flutter/material.dart';
import 'package:fluttertododemo/language_support/localization_manager.dart';

class DeleteToDoDialog extends StatelessWidget {
  final VoidCallback noClicked;
  final VoidCallback yesClicked;
  DeleteToDoDialog({this.noClicked, this.yesClicked});

  @override
  Widget build(BuildContext context) {
    var obj = LocalizationManager.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(20.0)), //this right here
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColorLight],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft
              ),
              borderRadius:
              BorderRadius.circular(20.0)
          ),
          height: MediaQuery.of(context).size.height * 0.25,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(obj.getTranslatedValue("delete_confirm_msg")),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FlatButton(
                    color: Theme.of(context).primaryColorLight,
                    child: Text(obj.getTranslatedValue("no_text"), style: Theme.of(context).textTheme.bodyText2,),
                    onPressed: () {
                     noClicked();
                    },
                  ),
                  FlatButton(
                    color: Theme.of(context).primaryColor,
                    child: Text(obj.getTranslatedValue("yes_text"), style: Theme.of(context).textTheme.bodyText2,),
                    onPressed: () {
                     yesClicked();
                    },
                  )
                ],
              )
            ],
          )
      ),
    );
  }
}
