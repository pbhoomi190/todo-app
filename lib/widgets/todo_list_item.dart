import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertododemo/database/ToDo.dart';
import 'package:fluttertododemo/constants/extensions.dart';
import 'package:fluttertododemo/database/database_helper.dart';
import 'package:fluttertododemo/language_support/localization_manager.dart';

class ToDoListItem extends StatefulWidget {

  final ToDo toDo;
  final Key key;
  final VoidCallback onFavClick;
  ToDoListItem({this.toDo, this.key, this.onFavClick});

  @override
  _ToDoListItemState createState() => _ToDoListItemState();
}

class _ToDoListItemState extends State<ToDoListItem> {
  DatabaseHelper helper = DatabaseHelper();
  bool isFav = false;
  ToDo itemToDo;
  String dateString = "";

  manageFavourite() async {
      var result = await helper.markFavouriteToDoItem(itemToDo, isFav ? 1 : 0);
      debugPrint(result.toString());
      setState(() {
        itemToDo.isFavourite = isFav ? 1 : 0;
      });
  }

  getDate() async {
    var date = await itemToDo.date.dateString();
    setState(() {
      dateString = date;
    });
  }

  @override
  void initState() {
    isFav = widget.toDo.isFavourite == 0 ? false : true;
    itemToDo = widget.toDo;
    getDate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var obj = LocalizationManager.of(context);
    return Container(
      height: 120,
      padding: const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
      child: Card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(width: 8,),
                CircleAvatar(
                  backgroundImage: AssetImage(itemToDo.category.categoryImage()),
                ),
                const SizedBox(width: 16,),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(itemToDo.title, maxLines: 1, overflow: TextOverflow.ellipsis,),
                      const SizedBox(height: 5,),
                      Text(itemToDo.description, maxLines: 1, overflow: TextOverflow.ellipsis,),
                      const SizedBox(height: 5,),
                      Text(dateString, maxLines: 1, overflow: TextOverflow.ellipsis,),
                      const SizedBox(height: 5,),
                    ],
                  ),
                ),
                const SizedBox(width: 8,),
                Semantics(
                  label: obj.getTranslatedValue("swipe_option_talkback"),
                  selected: itemToDo.isFavourite == 0 ? false : true,
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
                      icon: Icon(itemToDo.isFavourite == 0 ? Icons.favorite_border : Icons.favorite , color: Theme.of(context).primaryColor,),
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
    );
  }
}
