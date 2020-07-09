import 'package:flutter/material.dart';
import 'package:flutter_page_transition/page_transition_type.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertododemo/constants/constants.dart';
import 'package:fluttertododemo/database/ToDo.dart';
import 'package:fluttertododemo/database/database_helper.dart';
import 'package:fluttertododemo/constants/extensions.dart';
import 'package:fluttertododemo/language_support/localization_manager.dart';
import 'package:fluttertododemo/widgets/delete_todo_dialog.dart';
import 'package:fluttertododemo/widgets/todo_list_item.dart';

import '../custom_route_transition.dart';
import 'edit_todo_screen.dart';

enum UpcomingType {
   thisWeek, thisMonth, afterThisMonth
}

class UpcomingScreen extends StatefulWidget {
  @override
  _UpcomingScreenState createState() => _UpcomingScreenState();
}

class _UpcomingScreenState extends State<UpcomingScreen> {
  List<ToDo> thisMonthToDo = [];
  List<ToDo> thisWeek = [];
  List<ToDo> thisMonth = [];
  List<ToDo> laterAfterThisMonth = [];
  DatabaseHelper helper = DatabaseHelper();

  Future deleteToDo(UpcomingType type, ToDo toDo) async {
    var result = await helper.deleteToDoItem(toDo);
    setState(() {
      switch (type) {
        case UpcomingType.thisWeek:
          thisWeek.removeWhere((element) {
            return element == toDo;
          });
          break;
        case UpcomingType.thisMonth:
          thisMonth.removeWhere((element) {
            return element == toDo;
          });
          break;
        case UpcomingType.afterThisMonth:
          laterAfterThisMonth.removeWhere((element) {
            return element == toDo;
          });
          break;
      }
    });
  }

  showAlert(BuildContext context, ToDo toDo, UpcomingType type) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return DeleteToDoDialog(noClicked: () {
            Navigator.of(context).pop();
          }, yesClicked: () {
            deleteToDo(type, toDo).then((value) {
              Navigator.of(context).pop();
            });
          },);
        });
  }

  Widget appTitle() {
    var obj = LocalizationManager.of(context);
    return Row(
      children: <Widget>[
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            image: DecorationImage(
              image: AssetImage(clockImage),
            ),
          ),
        ),
        const SizedBox(width: 5,),
        Expanded(child: Text(obj.getTranslatedValue("upcoming_title"), style: Theme.of(context).textTheme.headline6, overflow: TextOverflow.ellipsis,)),
      ],
    );
  }

  void getUpcomingList() async {
    var results = await helper.getThisMonthToDo();
    var other = await helper.getAfterThisMonthToDo();
    print(results);
    results.forEach((element) {
      var todo = ToDo.fromMap(element);
      thisMonthToDo.add(todo);
    });
    other.forEach((element) {
      var todo = ToDo.fromMap(element);
      laterAfterThisMonth.add(todo);
    });
    setState(() {
      int getLastDayOfWeek = DateTime.now().getLastDayOfWeek().millisecondsSinceEpoch;
      thisWeek = thisMonthToDo.where((element) {
       return element.date < getLastDayOfWeek;
      }).toList();
      thisMonth = thisMonthToDo.where((element) {
        return element.date >= getLastDayOfWeek;
      }).toList();
    });
  }

  Widget thisWeekSection() {
    var obj = LocalizationManager.of(context);
    if (thisWeek.length > 0) {
      return  ListView.builder(itemBuilder: (context, index) {
        return Slidable(
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.2,
            secondaryActions: <Widget>[
              IconSlideAction(
                caption: obj.getTranslatedValue("edit_slide_button"),
                color: Theme.of(context).primaryColorLight,
                icon: Icons.edit,
                onTap: () {
                  print("Edit");
                  Navigator.of(context).push(CustomRoute(page: EditToDoScreen(toDo: thisWeek[index],), type: PageTransitionType.slideLeft));
                },
              ),
              IconSlideAction(
                caption: obj.getTranslatedValue("delete_slide_button"),
                color: Colors.red,
                icon: Icons.delete,
                onTap: () {
                  print("Delete");
                  showAlert(context, thisWeek[index], UpcomingType.thisWeek);
                },
              ),
            ],
            child: ToDoListItem(toDo: thisWeek[index], key: UniqueKey(), onFavClick: (){},)
        );
      },
        itemCount: thisWeek.length,
        shrinkWrap: true,
      );
    } else {
      return Container(
        height: 50,
        child: Center(
          child: Text(obj.getTranslatedValue("no_item_week_msg"), style: Theme.of(context).textTheme.bodyText2,),
        ),
      );
    }
  }

  Widget thisMonthSection() {
    var obj = LocalizationManager.of(context);
    if (thisMonth.length > 0) {
      return ListView.builder(itemBuilder: (context, index) {
        return Slidable(
          actionPane: SlidableDrawerActionPane(),
          actionExtentRatio: 0.2,
          secondaryActions: <Widget>[
            IconSlideAction(
              caption: obj.getTranslatedValue("edit_slide_button"),
              color: Theme.of(context).primaryColorLight,
              icon: Icons.edit,
              onTap: () {
                print("Edit");
                Navigator.of(context).push(CustomRoute(page: EditToDoScreen(toDo: thisMonth[index],), type: PageTransitionType.slideLeft));
              },
            ),
            IconSlideAction(
              caption: obj.getTranslatedValue("delete_slide_button"),
              color: Colors.red,
              icon: Icons.delete,
              onTap: () {
                print("Delete");
                showAlert(context, thisMonth[index], UpcomingType.thisMonth);
              },
            ),
          ],
          child: ToDoListItem(
            toDo: thisMonth[index], key: UniqueKey(),onFavClick: (){},),
        );
      },
        itemCount: thisMonth.length,
        shrinkWrap: true,
      );
    } else {
      return Container(
        height: 50,
        child: Center(
          child: Text(obj.getTranslatedValue("no_item_month_msg"), style: Theme.of(context).textTheme.bodyText2, textAlign: TextAlign.center,),
        ),
      );
    }
  }

  Widget laterAfterThisMonthSection() {
    var obj = LocalizationManager.of(context);
    if (laterAfterThisMonth.length > 0) {
      return ListView.builder(itemBuilder: (context, index) {
        return Slidable(
          actionPane: SlidableDrawerActionPane(),
          actionExtentRatio: 0.2,
          secondaryActions: <Widget>[
            IconSlideAction(
              caption: obj.getTranslatedValue("edit_slide_button"),
              color: Theme.of(context).primaryColorLight,
              icon: Icons.edit,
              onTap: () {
                print("Edit");
                Navigator.of(context).push(CustomRoute(page: EditToDoScreen(toDo: laterAfterThisMonth[index],), type: PageTransitionType.slideLeft));
              },
            ),
            IconSlideAction(
              caption: obj.getTranslatedValue("delete_slide_button"),
              color: Colors.red,
              icon: Icons.delete,
              onTap: () {
                print("Delete");
                showAlert(context, laterAfterThisMonth[index], UpcomingType.afterThisMonth);
              },
            ),
          ],
          child: ToDoListItem(
            toDo: laterAfterThisMonth[index], key: UniqueKey(), onFavClick: (){},),
        );
      },
        itemCount: laterAfterThisMonth.length,
        shrinkWrap: true,
      );
    } else {
      return Container(
        height: 50,
        child: Center(
          child: Text(obj.getTranslatedValue("no_item_later_msg"), style: Theme.of(context).textTheme.bodyText2,textAlign: TextAlign.center,),
        ),
      );
    }
  }

  @override
  void initState() {
    getUpcomingList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var obj = LocalizationManager.of(context);
    return Scaffold(
      appBar: AppBar(
        title: appTitle(),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Theme.of(context).primaryColorLight, Theme.of(context).primaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight
              )
          ),
        ),
        leading: IconButton(
          tooltip: obj.getTranslatedValue("back_btn_talkback"),
          icon: Icon(Icons.arrow_back_ios, color: Colors.black,),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: thisMonthToDo.length > 0 || laterAfterThisMonth.length > 0 ? SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(15), bottomRight:  Radius.circular(15)),
                  color: Theme.of(context).primaryColor
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(obj.getTranslatedValue("this_week_title"), style: Theme.of(context).textTheme.bodyText1, textAlign: TextAlign.center,),
                ),
              ),
              const SizedBox(height: 16,),
              thisWeekSection(),
              const SizedBox(height: 16,),
              Container(
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(15), bottomRight:  Radius.circular(15)),
                    color: Theme.of(context).primaryColor
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(obj.getTranslatedValue("this_month_title"), style: Theme.of(context).textTheme.bodyText1, textAlign: TextAlign.center,),
                ),
              ),
              const SizedBox(height: 16,),
              thisMonthSection(),
              const SizedBox(height: 16,),
              Container(
                height: 40,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(15), bottomRight:  Radius.circular(15)),
                    color: Theme.of(context).primaryColor
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(obj.getTranslatedValue("later_title"), style: Theme.of(context).textTheme.bodyText1, textAlign: TextAlign.center,),
                ),
              ),
              const SizedBox(height: 16,),
              laterAfterThisMonthSection(),
            ],
          ),
        ) : Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Text(obj.getTranslatedValue("no_upcoming_msg"),
              style: Theme.of(context).textTheme.bodyText2, textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
