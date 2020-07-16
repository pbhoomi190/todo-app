import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertododemo/constants/constants.dart';
import 'package:fluttertododemo/database/ToDo.dart';
import 'package:fluttertododemo/constants/extensions.dart';
import 'package:fluttertododemo/database/database_helper.dart';
import 'package:fluttertododemo/language_support/localization_manager.dart';

class ItemToDo {
  ToDo toDo;
  bool isPlaying = false;

  ItemToDo({this.toDo, this.isPlaying});
}

typedef void SpeechPlayingCallbackWithText(bool isPlaying, String text);
class ToDoListItem extends StatefulWidget {

  final ItemToDo toDo;
  final Key key;
  final VoidCallback onFavClick;
  final VoidCallback onEditClick;
  final SpeechPlayingCallbackWithText onPlay;
  ToDoListItem({this.toDo, this.key, this.onFavClick, this.onEditClick, this.onPlay});

  @override
  _ToDoListItemState createState() => _ToDoListItemState();
}

class _ToDoListItemState extends State<ToDoListItem> {
  DatabaseHelper helper = DatabaseHelper();
  bool isFav = false;
  ItemToDo itemToDo;
  String dateString = "";
  String image = allImage;
  String txtToSpeak = "";

  manageFavourite() async {
      var result = await helper.markFavouriteToDoItem(itemToDo.toDo, isFav ? 1 : 0);
      debugPrint(result.toString());
      setState(() {
        itemToDo.toDo.isFavourite = isFav ? 1 : 0;
      });
  }

  initialSetup() async {

    if (itemToDo.toDo.date != 0) {
      var date = await itemToDo.toDo.date.dateString();
      if (mounted) {
        setState(() {
          dateString = date;
            txtToSpeak = "${itemToDo.toDo.title}, ${itemToDo.toDo.description}, $dateString}";
        });
      }
    }
    var cat = await itemToDo.toDo.category.getCategoryForId();
    if (mounted) {
      setState(() {
        image = cat.image;
      });
    }
  }

  @override
  void initState() {
    isFav = widget.toDo.toDo.isFavourite == 0 ? false : true;
    itemToDo = widget.toDo;
    txtToSpeak = "${itemToDo.toDo.title}, ${itemToDo.toDo.description}";
    initialSetup();
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
                    icon: itemToDo.isPlaying ? Icon(Icons.stop,
                      color: Theme.of(context).primaryColor,) : Icon(Icons.record_voice_over,
                      color: Theme.of(context).primaryColor,),
                    onPressed: () {
                      if (itemToDo.isPlaying) {
                        widget.onPlay(false, "");
                      } else {
                        widget.onPlay(true, txtToSpeak);
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
                        icon: Icon(
                          itemToDo.toDo.isFavourite == 0 ? Icons.favorite_border : Icons.favorite,
                          color: Theme.of(context).primaryColor,),
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
