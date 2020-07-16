import 'package:flutter/material.dart';
import 'package:flutter_page_transition/page_transition_type.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertododemo/constants/constants.dart';
import 'package:fluttertododemo/database/ToDo.dart';
import 'package:fluttertododemo/database/database_helper.dart';
import 'package:fluttertododemo/constants/extensions.dart';
import 'package:fluttertododemo/language_support/localization_manager.dart';
import 'package:fluttertododemo/speech_helper/text_to_speech_helper.dart';
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
  TextToSpeech textToSpeech;
  ItemToDo playingItem;
  String playText = "";

  void managePlayingItem(ToDo todo, String text, bool isPlaying) {
    playingItem = ItemToDo(toDo: todo, isPlaying: isPlaying);
    if (isPlaying) {
      textToSpeech.speak(text);
    } else {
      textToSpeech.stop();
    }
  }

  initTextToSpeech() {
    textToSpeech = TextToSpeech(isPlaying: (playing) {
      setState(() {
        playingItem.isPlaying = playing;
      });
    });
    textToSpeech.initializeTts();
  }

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

  markComplete(ToDo toDo, UpcomingType type) {
    helper.markCompletedToDoItem(toDo).then((value) {
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
    });
  }

  showAlertDialogue(BuildContext context, ToDo toDo, UpcomingType type) {
    var obj = LocalizationManager.of(context);
    showDialog(
        context: context,
        child: AlertDialog(
          title: Text(obj.getTranslatedValue("delete_slide_button")),
          content: Text(obj.getTranslatedValue("delete_confirm_msg")),
          actions: <Widget>[
            FlatButton(
              child: Text(obj.getTranslatedValue("no_text"), style: Theme.of(context).textTheme.bodyText2,),
              onPressed: () => Navigator.pop(context),
            ),
            FlatButton(
              child: Text(obj.getTranslatedValue("yes_text"), style: Theme.of(context).textTheme.bodyText2,),
              onPressed: (){
                deleteToDo(type, toDo).then((value) {
                  Navigator.of(context).pop();
                });
              }
            ),
          ],
        )
    );
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
      playingItem = ItemToDo(toDo: thisMonthToDo.first, isPlaying: false);
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

  Widget sliverScroll() {
    var obj = LocalizationManager.of(context);
    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Container(
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
        ),
        sliverWeek(),
        SliverToBoxAdapter(child: SizedBox(height: 15,),),
        SliverToBoxAdapter(
          child: Container(
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
        ),
        SliverToBoxAdapter(child: SizedBox(height: 15,),),
        sliverMonth(),
        SliverToBoxAdapter(child: SizedBox(height: 15,),),
        SliverToBoxAdapter(
          child: Container(
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
        ),
        SliverToBoxAdapter(child: SizedBox(height: 15,),),
        sliverLater(),
      ],
    );
  }

  Widget sliverWeek() {

    var obj = LocalizationManager.of(context);
    if (thisWeek.length > 0) {
      return  SliverList(delegate: SliverChildBuilderDelegate(
              (context, index) {
            return Slidable(
                actionPane: SlidableDrawerActionPane(),
                actionExtentRatio: 0.2,
                secondaryActions: <Widget>[
                 /* IconSlideAction(
                    caption: obj.getTranslatedValue("edit_slide_button"),
                    color: Theme.of(context).primaryColorLight,
                    icon: Icons.edit,
                    onTap: () {
                      print("Edit");
                      Navigator.of(context).push(CustomRoute(page: EditToDoScreen(toDo: thisWeek[index],), type: PageTransitionType.slideLeft));
                    },
                  ),*/
                  IconSlideAction(
                    caption: obj.getTranslatedValue("complete_slide_button"),
                    color: Theme.of(context).primaryColor,
                    icon: Icons.replay,
                    onTap: () {
                      markComplete(thisWeek[index], UpcomingType.thisWeek);
                    },
                  ),
                  IconSlideAction(
                    caption: obj.getTranslatedValue("delete_slide_button"),
                    color: Colors.red,
                    icon: Icons.delete,
                    onTap: () {
                      print("Delete");
                      showAlertDialogue(context, thisWeek[index], UpcomingType.thisWeek);
                    },
                  ),
                ],
                child: ToDoListItem(toDo: ItemToDo(toDo: thisWeek[index],
                    isPlaying: playingItem.toDo.id == thisWeek[index].id ? playingItem.isPlaying : false),
                  key: UniqueKey(),
                  onFavClick: (){},
                  onEditClick: () {
                    moveToEdit(thisWeek[index], UpcomingType.thisWeek);
                  },
                  onPlay: (play, text) {
                    managePlayingItem(thisWeek[index], text, play);
                  },
                )
            );
          },
        childCount: thisWeek.length
      ));
    } else {
      return SliverToBoxAdapter(
        child: Container(
          height: 50,
          child: Center(
            child: Text(obj.getTranslatedValue("no_item_week_msg"), style: Theme.of(context).textTheme.bodyText2,),
          ),
        ),
      );
    }
  }

  Widget sliverMonth() {

    var obj = LocalizationManager.of(context);
    if (thisMonth.length > 0) {
      return  SliverList(delegate: SliverChildBuilderDelegate(
              (context, index) {
            return Slidable(
              actionPane: SlidableDrawerActionPane(),
              actionExtentRatio: 0.2,
              secondaryActions: <Widget>[
                IconSlideAction(
                  caption: obj.getTranslatedValue("complete_slide_button"),
                  color: Theme.of(context).primaryColor,
                  icon: Icons.replay,
                  onTap: () {
                    markComplete(thisMonth[index], UpcomingType.thisMonth);
                  },
                ),
                IconSlideAction(
                  caption: obj.getTranslatedValue("delete_slide_button"),
                  color: Colors.red,
                  icon: Icons.delete,
                  onTap: () {
                    print("Delete");
                    showAlertDialogue(context, thisMonth[index], UpcomingType.thisMonth);
                  },
                ),
              ],
              child: ToDoListItem(
                toDo: ItemToDo(toDo: thisMonth[index],
                    isPlaying: playingItem.toDo.id == thisMonth[index].id ? playingItem.isPlaying : false),
                key: UniqueKey(),
                onFavClick: (){},
                onEditClick: () {
                  moveToEdit(thisMonth[index], UpcomingType.thisMonth);
                },
                onPlay: (play, text) {
                  managePlayingItem(thisMonth[index], text, play);
                },
              ),
            );
          },
        childCount: thisMonth.length
      ),
      );
    } else {
      return SliverToBoxAdapter(
        child: Container(
          height: 50,
          child: Center(
            child: Text(obj.getTranslatedValue("no_item_month_msg"), style: Theme.of(context).textTheme.bodyText2,),
          ),
        ),
      );
    }
  }

  Widget sliverLater() {
    var obj = LocalizationManager.of(context);
    if (laterAfterThisMonth.length > 0) {
      return  SliverList(delegate: SliverChildBuilderDelegate(
              (context, index) {
            return Slidable(
              actionPane: SlidableDrawerActionPane(),
              actionExtentRatio: 0.2,
              secondaryActions: <Widget>[
                IconSlideAction(
                  caption: obj.getTranslatedValue("complete_slide_button"),
                  color: Theme.of(context).primaryColor,
                  icon: Icons.replay,
                  onTap: () {
                    markComplete(laterAfterThisMonth[index], UpcomingType.afterThisMonth);
                  },
                ),
                IconSlideAction(
                  caption: obj.getTranslatedValue("delete_slide_button"),
                  color: Colors.red,
                  icon: Icons.delete,
                  onTap: () {
                    print("Delete");
                    showAlertDialogue(context, laterAfterThisMonth[index], UpcomingType.afterThisMonth);
                  },
                ),
              ],
              child: ToDoListItem(
                toDo: ItemToDo(toDo: laterAfterThisMonth[index],
                    isPlaying: playingItem.toDo.id == laterAfterThisMonth[index].id ? playingItem.isPlaying : false),
                key: UniqueKey(),
                onFavClick: (){},
                onEditClick: () {
                  moveToEdit(laterAfterThisMonth[index], UpcomingType.afterThisMonth);
                },
                onPlay: (play, text) {
                  managePlayingItem(laterAfterThisMonth[index], text, play);
                },
              ),
            );
          },
          childCount: laterAfterThisMonth.length
      ));
    } else {
      return SliverToBoxAdapter(
        child: Container(
          height: 50,
          child: Center(
            child: Text(obj.getTranslatedValue("no_item_later_msg"), style: Theme.of(context).textTheme.bodyText2,),
          ),
        ),
      );
    }
  }

  moveToEdit(ToDo todo, UpcomingType type) async {
    await Navigator.of(context).push(CustomRoute(page: EditToDoScreen(toDo: todo), type: PageTransitionType.slideLeft)).then((value) {
      if (value != null) {
        ToDo editToDo = value;
        switch (type) {
          case UpcomingType.thisWeek:
            var toBeFilter = thisWeek.firstWhere((element) => editToDo.id == element.id);
            setState(() {
              toBeFilter = editToDo;
            });
            break;
          case UpcomingType.thisMonth:
            var toBeFilter = thisMonth.firstWhere((element) => editToDo.id == element.id);
            setState(() {
              toBeFilter = editToDo;
            });
            break;
          case UpcomingType.afterThisMonth:
            var toBeFilter = laterAfterThisMonth.firstWhere((element) => editToDo.id == element.id);
            setState(() {
              toBeFilter = editToDo;
            });
            break;
        }
      }
    });
  }


  @override
  void initState() {
    getUpcomingList();
    initTextToSpeech();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    textToSpeech.dispose();
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
        child: thisMonthToDo.length > 0 || laterAfterThisMonth.length > 0 ? sliverScroll() : Center(
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
