import 'package:flutter/material.dart';
import 'package:flutter_page_transition/flutter_page_transition.dart';
import 'package:fluttertododemo/language_support/localization_manager.dart';
import 'package:fluttertododemo/screens/add_todo_screen.dart';
import 'package:fluttertododemo/screens/completed_screen.dart';
import 'package:fluttertododemo/screens/favorite_screen.dart';
import 'package:fluttertododemo/screens/setting_screen.dart';
import 'package:fluttertododemo/screens/todo_list_screen.dart';
import 'package:fluttertododemo/screens/upcoming_screen.dart';
import 'package:fluttertododemo/widgets/custom_top_bar.dart';
import 'package:fluttertododemo/constants/extensions.dart';
import '../custom_route_transition.dart';

class HomeScreen extends StatefulWidget {

  @override
  _HomeScreenState createState() => _HomeScreenState();

}

class _HomeScreenState extends State<HomeScreen> {


  Widget toDoItemButton(String title, Icon icon, Color bgColor, VoidCallback onPressed) {
    return InkWell(
      onTap: () {
        onPressed();
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.1,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
          boxShadow: [BoxShadow(color: Colors.black, blurRadius: 1, spreadRadius: 1.5),]
        ),

        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                  child: Text(title, style: Theme.of(context).textTheme.bodyText1,)
              ),
              icon,
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var obj = LocalizationManager.of(context);
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
            CustomTopBar(title: obj.getTranslatedValue("home_title"), subTitle: obj.getTranslatedValue("home_subtitle"), isLeft: false, isRight: true, onSetting: () {
              Navigator.of(context).push(CustomRoute(page: SettingScreen(), type: PageTransitionType.rippleRightDown));
            },),
            SizedBox(height: 30,),
            Expanded(
              flex: 1,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  toDoItemButton(obj.getTranslatedValue("all_button"), Icon(Icons.calendar_today), HexColor.fromHex("DF7777"), () {
                    print("Go to all list");
                    Navigator.of(context).push(CustomRoute(page: ToDoListScreen(), type: PageTransitionType.slideLeft));
                  }),
                  toDoItemButton(obj.getTranslatedValue("upcoming_button"), Icon(Icons.calendar_today), HexColor.fromHex("D1A168"), () {
                    Navigator.of(context).push(CustomRoute(page: UpcomingScreen(), type: PageTransitionType.slideLeft));
                  }),
                  toDoItemButton(obj.getTranslatedValue("favorite_button"), Icon(Icons.favorite), HexColor.fromHex("87C8CC"), () {
                    print("Go to fav list");
                    Navigator.of(context).push(CustomRoute(page: FavoriteScreen(), type: PageTransitionType.slideLeft));
                  }),
                  toDoItemButton(obj.getTranslatedValue("completed_button"), Icon(Icons.replay), HexColor.fromHex("C4C4C4"), () {
                    Navigator.of(context).push(CustomRoute(page: CompletedScreen(), type: PageTransitionType.slideLeft));
                  }),
                ],
              ),
            )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: obj.getTranslatedValue("add_todo_talkback"),
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(CustomRoute(page: AddToDoScreen(), type: PageTransitionType.rippleRightUp));
        },
      ),
    );
  }
}
