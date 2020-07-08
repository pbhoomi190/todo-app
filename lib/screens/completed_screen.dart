import 'package:flutter/material.dart';
import 'package:flutter_page_transition/page_transition_type.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertododemo/constants/constants.dart';
import 'package:fluttertododemo/database/ToDo.dart';
import 'package:fluttertododemo/database/database_helper.dart';
import 'package:fluttertododemo/language_support/localization_manager.dart';
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
      debugPrint("$completed");
    });
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
            ],
            child: ToDoListItem(toDo: completed[index], key: UniqueKey(), onFavClick: () {},)
        );
      },
        itemCount: completed != null && completed.length > 0 ? completed.length : 0,
      ) : Center(
        child: Text(obj.getTranslatedValue("no_completed_msg"), style: Theme.of(context).textTheme.bodyText2,textAlign: TextAlign.center,),
      ),
    );
  }
}

