import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertododemo/constants/constants.dart';
import 'package:fluttertododemo/database/ToDo.dart';
import 'package:fluttertododemo/constants/extensions.dart';
import 'package:fluttertododemo/database/database_helper.dart';
import 'package:fluttertododemo/language_support/localization_manager.dart';

class ItemToDo {
  ToDo toDo;
  bool isPlaying;

  ItemToDo({this.toDo, this.isPlaying});
}

class ToDoListItem extends StatefulWidget {

  final ToDo toDo;
  final Key key;
  final VoidCallback onFavClick;
  final VoidCallback onEditClick;
  ToDoListItem({this.toDo, this.key, this.onFavClick, this.onEditClick});

  @override
  _ToDoListItemState createState() => _ToDoListItemState();
}

class _ToDoListItemState extends State<ToDoListItem> {
  DatabaseHelper helper = DatabaseHelper();
  bool isFav = false;
  ItemToDo itemToDo;
  String dateString = "";
  String image = allImage;
  FlutterTts _flutterTts;
  String txtToSpeak = "";

  manageFavourite() async {
      var result = await helper.markFavouriteToDoItem(itemToDo.toDo, isFav ? 1 : 0);
      debugPrint(result.toString());
      setState(() {
        itemToDo.toDo.isFavourite = isFav ? 1 : 0;
      });
  }

  getDate() async {
    if (itemToDo.toDo.date != 0) {
      var date = await itemToDo.toDo.date.dateString();
      if (mounted) {
        setState(() {
          dateString = date;
        });
      }
      txtToSpeak = "${itemToDo.toDo.title}, ${itemToDo.toDo.description}, $dateString";
    }
    var cat = await itemToDo.toDo.category.getCategoryForId();
    if (mounted) {
      setState(() {
        image = cat.image;
      });
    }
  }

  initializeTts() {
    _flutterTts = FlutterTts();

    _flutterTts.setStartHandler(() {
      setState(() {
        itemToDo.isPlaying = true;
      });
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        itemToDo.isPlaying = false;
      });
    });

    _flutterTts.setErrorHandler((err) {
      setState(() {
        print("error occurred: " + err);
        itemToDo.isPlaying = false;
      });
    });
  }

  Future speak(String text) async {
    if (text != null && text.isNotEmpty) {
      var result = await _flutterTts.speak(text);
      if (result == 1)
        setState(() {
          itemToDo.isPlaying = true;
        });
    }
  }

  Future stop() async {
    var result = await _flutterTts.stop();
    if (result == 1)
      setState(() {
        itemToDo.isPlaying = false;
      });
  }

  void setTtsLanguage() async {
    await _flutterTts.setLanguage("en-US");
  }

  @override
  void dispose() {
    super.dispose();
    _flutterTts.stop();
  }

  @override
  void initState() {
    isFav = widget.toDo.isFavourite == 0 ? false : true;
    itemToDo = ItemToDo(toDo: widget.toDo, isPlaying: false);
    getDate();
    initializeTts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var obj = LocalizationManager.of(context);
    return InkWell(
      onTap: () {
        widget.onEditClick();
      },
      child: Container(
        height: 120,
        padding: const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
        child: Card(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(width: 8,),
                  CircleAvatar(
                    backgroundImage: AssetImage(image), //itemToDo.category
                  ),
                  const SizedBox(width: 16,),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(itemToDo.toDo.title, maxLines: 1, overflow: TextOverflow.ellipsis,),
                        const SizedBox(height: 5,),
                        Text(itemToDo.toDo.description, maxLines: 1, overflow: TextOverflow.ellipsis,),
                        const SizedBox(height: 5,),
                        Text(dateString, maxLines: 1, overflow: TextOverflow.ellipsis,),
                        const SizedBox(height: 5,),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8,),
                  IconButton(
                    icon: itemToDo.isPlaying ? Icon(Icons.stop) : Icon(Icons.record_voice_over),
                    onPressed: () {
                      if (itemToDo.isPlaying) {
                        stop();
                      } else {
                        speak(txtToSpeak);
                      }
                    },
                  ),
                  Semantics(
                    label: obj.getTranslatedValue("swipe_option_talkback"),
                    selected: itemToDo.toDo.isFavourite == 0 ? false : true,
                    onTap: () {
                      widget.onFavClick();
                      isFav = !isFav;
                      manageFavourite();
                    },
                    child: Container(
                      width: 40,
                      height: 100,
                      child: IconButton(
                        tooltip: "favorite",
                        icon: Icon(itemToDo.toDo.isFavourite == 0 ? Icons.favorite_border : Icons.favorite , color: Theme.of(context).primaryColor,),
                        onPressed: () {
                          widget.onFavClick();
                          isFav = !isFav;
                          manageFavourite();
                        },
                      ),
                    ),
                  )
                ],
              ),
        ),
      ),
    );
  }
}
