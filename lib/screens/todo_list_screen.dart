import 'package:flutter/material.dart';
import 'package:flutter_page_transition/page_transition_type.dart';
import 'package:fluttertododemo/constants/category.dart';
import 'package:fluttertododemo/constants/constants.dart';
import 'package:fluttertododemo/database/ToDo.dart';
import 'package:fluttertododemo/database/database_helper.dart';
import 'package:fluttertododemo/language_support/localization_manager.dart';
import 'package:fluttertododemo/screens/edit_todo_screen.dart';
import 'package:fluttertododemo/widgets/delete_todo_dialog.dart';
import 'package:fluttertododemo/widgets/filtered_list_inherited_widget.dart';
import 'package:fluttertododemo/widgets/todo_list_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../custom_route_transition.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ToDoListScreen extends StatefulWidget {
  @override
  _ToDoListScreenState createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController controller = ScrollController();
  bool closeCategories = false;
  double topContainer = 0;
  DatabaseHelper helper = DatabaseHelper();
  List<ToDo> filteredToDo = [];
  List<ToDo> allToDo = [];
  CategoryType selectedCategory = CategoryType.all;

  void showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message),);
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  void fetchAllToDoItems() async {
    var results = await helper.fetchToDoList();
    print(results);
    results.forEach((element) {
      var todo = ToDo.fromMap(element);
      allToDo.add(todo);
    });
    setState(() {
      filteredToDo = allToDo;
        debugPrint("$allToDo");
    });
  }

  Future deleteItem(ToDo toDo) async {
    var result = await helper.deleteToDoItem(toDo);
    if (result == 1) {
      setState(() {
        allToDo.removeWhere((element) {
          return element == toDo;
        });
        filteredToDo.removeWhere((element) {
          return element == toDo;
        });
      });
    } else {
      showSnackBar("Unable to delete the item.");
    }
  }

  void reloadData(CategoryType category) {
    filteredToDo.forEach((element) {
      debugPrint("${element.toMap()}");
    });
    setState(() {
      selectedCategory = category;
    });
  }

  performDelete(ToDo toDo) {
    deleteItem(toDo).then((value) {
      Navigator.of(context).pop();
    });
  }

  showAlert(BuildContext context, ToDo toDo) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return DeleteToDoDialog(noClicked: () {
            Navigator.of(context).pop();
          }, yesClicked: () {
            performDelete(toDo);
          },);
        });
  }

  void filterItemsWithCategory(CategoryType category) {
    switch (category) {
      case CategoryType.all:
        filteredToDo = allToDo;
        reloadData(category);
        break;
      case CategoryType.favorites:
        filteredToDo = allToDo.where((element) {
          return element.isFavourite == 1;
        }).toList();
        reloadData(category);
        break;
      case CategoryType.shopping:
        filteredToDo = allToDo.where((element) {
          return element.category == CategoryType.shopping.getString();
        }).toList();
        reloadData(category);
        break;
      case CategoryType.event:
        filteredToDo = allToDo.where((element) {
          return element.category == CategoryType.event.getString();
        }).toList();
        reloadData(category);
        break;
      case CategoryType.work:
        filteredToDo = allToDo.where((element) {
          return element.category == CategoryType.work.getString();
        }).toList();
        reloadData(category);
        break;
      case CategoryType.trip:
        filteredToDo = allToDo.where((element) {
          return element.category == CategoryType.trip.getString();
        }).toList();
        reloadData(category);
        break;
      case CategoryType.other:
        filteredToDo = allToDo.where((element) {
          return element.category == CategoryType.other.getString();
        }).toList();
        reloadData(category);
        break;
      case CategoryType.meeting:
        filteredToDo = allToDo.where((element) {
          return element.category == CategoryType.meeting.getString();
        }).toList();
        reloadData(category);
        break;
    }
  }

  @override
  void initState() {
    fetchAllToDoItems();
    super.initState();
    controller.addListener(() {
      double value = controller.offset/120;

      setState(() {
        topContainer = value;
        closeCategories = controller.offset > 50;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    var obj = LocalizationManager.of(context);
    return CategoryInheritedWidget(
      categoryType: selectedCategory,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(obj.getTranslatedValue("list_title"), style: Theme.of(context).textTheme.headline6),
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
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: closeCategories ? 0 : 1,
              child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: size.width,
                  alignment: Alignment.topCenter,
                  height: closeCategories ? 0 : 175,
                  child: HorizontalCategoryScrollView(onCategoryChange: (category) {
                        filterItemsWithCategory(category);
                  },)
              ),
            ),
            Expanded(
                child: filteredToDo.length > 0 ? ListView.builder(
                    controller: controller,
                    itemCount: filteredToDo.length != 0 ? filteredToDo.length : 0,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      double scale = 1.0;
                      if (topContainer > 0.5) {
                        scale = index + 0.5 - topContainer;
                        if (scale < 0) {
                          scale = 0;
                        } else if (scale > 1) {
                          scale = 1;
                        }
                      }
                      return Opacity(
                        opacity: scale,
                        child: Transform(
                          transform:  Matrix4.identity()..scale(scale,scale),
                          alignment: Alignment.bottomCenter,
                          child: Slidable(
                            actionPane: SlidableDrawerActionPane(),
                            actionExtentRatio: 0.2,
                            secondaryActions: <Widget>[
                              IconSlideAction(
                                caption: obj.getTranslatedValue("edit_slide_button"),
                                color: Theme.of(context).primaryColorLight,
                                icon: Icons.edit,
                                onTap: () {
                                  print("Edit");
                                  Navigator.of(context).push(CustomRoute(page: EditToDoScreen(toDo: filteredToDo[index],), type: PageTransitionType.slideLeft));
                                },
                              ),
                              IconSlideAction(
                                caption: obj.getTranslatedValue("delete_slide_button"),
                                color: Colors.red,
                                icon: Icons.delete,
                                onTap: () {
                                  print("Delete");
                                  showAlert(context, filteredToDo[index]);
                                },
                              ),
                            ],
                            child: ToDoListItem(toDo: filteredToDo[index], key: UniqueKey(), onFavClick: () {},),
                          ),
                        ),
                      );
                    }) : Center(
                  child: Text(obj.getTranslatedValue("no_item_msg"), style: Theme.of(context).textTheme.bodyText2, textAlign: TextAlign.center,),
                )
            ),
          ]
        ),
      ),
    );
  }
}

typedef void CategoryCallback(CategoryType type);
class HorizontalCategoryScrollView extends StatefulWidget {
  final CategoryCallback onCategoryChange;
  HorizontalCategoryScrollView({this.onCategoryChange});

  @override
  _HorizontalCategoryScrollViewState createState() => _HorizontalCategoryScrollViewState();
}

class _HorizontalCategoryScrollViewState extends State<HorizontalCategoryScrollView> {

  bool isDark = false;

  getTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDark = prefs.getBool('isDark') ?? false;
    });
  }

  Widget itemCard(String title, String image, CategoryType type) {

    final selectedCategory = CategoryInheritedWidget.of(context).categoryType;
    return Semantics(
      label: "Category item",
      hint: "Double tap to show list. Scroll left with two fingers to scroll through the list",
      value: title,
      selected: selectedCategory == type ? true : false,
      container: true,
      excludeSemantics: true,
      child: InkWell(
        onTap: () {
          widget.onCategoryChange(type);
        },
        child: Container(
          width: 150,
          height: 175,
          child: Card(
            color: selectedCategory == type ? (isDark ? Theme.of(context).primaryColor : Theme.of(context).primaryColorLight) : (isDark ? Theme.of(context).primaryColorLight : Colors.white) ,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(image),
                ),
                const SizedBox(height: 10,),
                Text(title, overflow: TextOverflow.ellipsis, maxLines: 2,)
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    getTheme();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var obj = LocalizationManager.of(context);
    return ListView(
      scrollDirection: Axis.horizontal,
      children: <Widget>[
        itemCard(obj.getTranslatedValue("show_all"), allImage, CategoryType.all),
        itemCard(obj.getTranslatedValue("favorites"), favImage, CategoryType.favorites),
        itemCard(obj.getTranslatedValue("shopping"), shoppingImage, CategoryType.shopping),
        itemCard(obj.getTranslatedValue("event"), eventImage, CategoryType.event),
        itemCard(obj.getTranslatedValue("trip"), tripImage, CategoryType.trip),
        itemCard(obj.getTranslatedValue("work"), workImage, CategoryType.work),
        itemCard(obj.getTranslatedValue("meeting"), meetingImage, CategoryType.meeting),
        itemCard(obj.getTranslatedValue("other"), otherImage, CategoryType.other),
      ],
    );
  }
}



