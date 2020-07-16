import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_page_transition/flutter_page_transition.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertododemo/constants/constants.dart';
import 'package:fluttertododemo/database/ToDo.dart';
import 'package:fluttertododemo/database/database_helper.dart';
import 'package:fluttertododemo/language_support/localization_manager.dart';
import 'package:fluttertododemo/speech_helper/text_to_speech_helper.dart';
import 'package:fluttertododemo/widgets/todo_list_item.dart';

import '../custom_route_transition.dart';
import 'edit_todo_screen.dart';

class FavoriteScreen extends StatefulWidget {
  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {

  List<ToDo> favorites = [];
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
              image: AssetImage(favImage),
            ),
          ),
        ),
        const SizedBox(width: 5,),
        Text(obj.getTranslatedValue("favorite_title"), style: Theme.of(context).textTheme.headline6,),
      ],
    );
  }

  void getFavorites() async {
    var results = await helper.getFavoriteToDo();
    print(results);
    results.forEach((element) {
      var todo = ToDo.fromMap(element);
      favorites.add(todo);
    });
    setState(() {
      playingItem = ItemToDo(toDo: favorites.first, isPlaying: false);
      debugPrint("$favorites");
    });
  }

  Future deleteItem(ToDo toDo) async {
    var result = await helper.deleteToDoItem(toDo);
    if (result == 1) {
      setState(() {
        favorites.removeWhere((element) {
          return element == toDo;
        });
      });
    } else {
      print("Unable to delete the item.");
    }
  }

  performDelete(ToDo toDo) {
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

  markComplete(ToDo toDo) {
    helper.markCompletedToDoItem(toDo).then((value) {
      setState(() {
        favorites.removeWhere((element) => element.id == toDo.id);
      });
    });
  }

  moveToEdit(ToDo todo) async {
    await Navigator.of(context).push(CustomRoute(page: EditToDoScreen(toDo: todo), type: PageTransitionType.slideLeft)).then((value) {
      if (value != null) {
        ToDo editToDo = value;
        var toBeFilter = favorites.firstWhere((element) => editToDo.id == element.id);
        setState(() {
          toBeFilter = editToDo;
        });
      }
    });
  }


  @override
  void initState() {
    getFavorites();
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
      body: favorites.length > 0 ? ListView.builder(itemBuilder: (context, index) {
        return Slidable(
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.2,
            secondaryActions: <Widget>[
              IconSlideAction(
                caption: obj.getTranslatedValue("complete_slide_button"),
                color: Theme.of(context).primaryColor,
                icon: Icons.replay,
                onTap: () {
                  markComplete(favorites[index]);
                },
              ),
              IconSlideAction(
                caption: obj.getTranslatedValue("delete_slide_button"),
                color: Colors.red,
                icon: Icons.delete,
                onTap: () {
                  print("Delete");
                  showAlertDialogue(context, favorites[index]);
                },
              ),
            ],
            child: ToDoListItem(toDo: ItemToDo(toDo: favorites[index],
                isPlaying: playingItem.toDo.id == favorites[index].id ? playingItem.isPlaying : false),
              key: UniqueKey(),
              onFavClick: () {
              setState(() {
                favorites.remove(favorites[index]);
              });
            },
              onEditClick: () {
              moveToEdit(favorites[index]);
            },
              onPlay: (play, text) {
                managePlayingItem(favorites[index], text, play);
              },
            )
        );
      },
        itemCount: favorites != null && favorites.length > 0 ? favorites.length : 0,
      ): Center(
        child: Text(obj.getTranslatedValue("no_favorite_msg"), style: Theme.of(context).textTheme.bodyText2,),
      ),
    );
  }
}
