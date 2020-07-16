import 'package:flutter/material.dart';
import 'package:flutter_page_transition/page_transition_type.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertododemo/constants/constants.dart';
import 'package:fluttertododemo/database/ToDo.dart';
import 'package:fluttertododemo/database/database_helper.dart';
import 'package:fluttertododemo/language_support/localization_manager.dart';
import 'package:fluttertododemo/speech_helper/text_to_speech_helper.dart';
import 'package:fluttertododemo/widgets/todo_list_item.dart';

import '../custom_route_transition.dart';
import 'edit_todo_screen.dart';

class CompletedScreen extends StatefulWidget {
  @override
  _CompletedScreenState createState() => _CompletedScreenState();
}

class _CompletedScreenState extends State<CompletedScreen> {

  List<ToDo> completed = [];
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
              image: AssetImage(allImage),
            ),
          ),
        ),
        const SizedBox(width: 5,),
        Expanded(child: Text(obj.getTranslatedValue("completed_title"), style: Theme.of(context).textTheme.headline6,)),
      ],
    );
  }

  void getCompleted() async {
    var results = await helper.getCompletedToDo();
    print(results);
    results.forEach((element) {
      var todo = ToDo.fromMap(element);
      completed.add(todo);
    });
    setState(() {
      playingItem = ItemToDo(toDo: completed.first, isPlaying: false);
      debugPrint("$completed");
    });
  }

  Future deleteItem(ToDo toDo) async {
    var result = await helper.deleteToDoItem(toDo);
    if (result == 1) {
      setState(() {
        completed.removeWhere((element) {
          return element == toDo;
        });
      });
    } else {
      print("Unable to delete the item.");
    }
  }

  performDelete(ToDo toDo) async {
    deleteItem(toDo).then((value) {
      Navigator.of(context).pop();
    });
  }

  showAlertDialogue(BuildContext context, ToDo toDo) {
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
              onPressed: () => performDelete(toDo),
            ),
          ],
        )
    );
  }

  @override
  void initState() {
    getCompleted();
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
      body: completed.length > 0 ? ListView.builder(itemBuilder: (context, index) {
        return Slidable(
          actionPane: SlidableDrawerActionPane(),
          actionExtentRatio: 0.2,
          secondaryActions: <Widget>[
          IconSlideAction(
          caption: obj.getTranslatedValue("repeat_slide_button"),
          color: Theme.of(context).primaryColorLight,
          icon: Icons.repeat,
          onTap: () {
            Navigator.of(context).push(CustomRoute(page: EditToDoScreen(toDo: completed[index], isFromCompleted: true,), type: PageTransitionType.slideLeft));
          },
          ),
            IconSlideAction(
              caption: obj.getTranslatedValue("delete_slide_button"),
              color: Colors.red,
              icon: Icons.delete,
              onTap: () {
                print("Delete");
                showAlertDialogue(context, completed[index]);
              },
            ),
            ],
            child: ToDoListItem(toDo: ItemToDo(toDo: completed[index],
                isPlaying: playingItem.toDo.id == completed[index].id ? playingItem.isPlaying : false),
              key: UniqueKey(),
              onFavClick: () {},
              onEditClick: () {},
              onPlay: (play, text) {
                managePlayingItem(completed[index], text, play);
              },
            )
        );
      },
        itemCount: completed != null && completed.length > 0 ? completed.length : 0,
      ) : Center(
        child: Text(obj.getTranslatedValue("no_completed_msg"), style: Theme.of(context).textTheme.bodyText2,textAlign: TextAlign.center,),
      ),
    );
  }
}

