import 'package:flutter/material.dart';
import 'package:flutter_page_transition/page_transition_type.dart';
import 'package:fluttertododemo/database/ToDo.dart';
import 'package:fluttertododemo/database/database_helper.dart';
import 'package:fluttertododemo/language_support/localization_manager.dart';
import 'package:fluttertododemo/screens/edit_todo_screen.dart';
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
  Categories selectedCategory;
  List<Categories> categories = [];

  void showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message),);
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  void fetchAllToDoItems() async {
    var category = await helper.fetchCategories(showHidden: true); // also show fav and all
    category.forEach((element) {
      var category = Categories.fromMap(element);
      categories.add(category);
    });
    selectedCategory = categories.first;
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

  markComplete(ToDo toDo) {
    helper.markCompletedToDoItem(toDo).then((value) {
      setState(() {
        filteredToDo.removeWhere((element) => element.id == toDo.id);
      });
    });
  }

  void reloadData(Categories category) {
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

  void filterItemsWithCategory(Categories category) {
    if (category.isAll == 1) {
      filteredToDo = allToDo;
      reloadData(category);
    } else if (category.isFav == 1) {
      filteredToDo = allToDo.where((element) {
        return element.isFavourite == 1;
      }).toList();
      reloadData(category);
    } else {
      filteredToDo = allToDo.where((element) {
        return element.category == category.id;
      }).toList();
      reloadData(category);
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
                  child: HorizontalCategoryScrollView(categories: categories, onCategoryChange: (category) {
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
                                caption: obj.getTranslatedValue("complete_slide_button"),
                                color: Theme.of(context).primaryColor,
                                icon: Icons.replay,
                                onTap: () {
                                  markComplete(filteredToDo[index]);
                                },
                              ),
                              IconSlideAction(
                                caption: obj.getTranslatedValue("delete_slide_button"),
                                color: Colors.red,
                                icon: Icons.delete,
                                onTap: () {
                                  print("Delete");
                                  showAlertDialogue(context, filteredToDo[index]);
                                },
                              ),
                            ],
                            child: ToDoListItem(toDo: filteredToDo[index], key: UniqueKey(), onFavClick: () {}, onEditClick: () {
                              Navigator.of(context).push(CustomRoute(page: EditToDoScreen(toDo: filteredToDo[index],), type: PageTransitionType.slideLeft));
                            },),
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

typedef void CategoryCallback(Categories type);
class HorizontalCategoryScrollView extends StatefulWidget {
  final CategoryCallback onCategoryChange;
  final List<Categories> categories;
  HorizontalCategoryScrollView({this.onCategoryChange, this.categories});

  @override
  _HorizontalCategoryScrollViewState createState() => _HorizontalCategoryScrollViewState();
}

class _HorizontalCategoryScrollViewState extends State<HorizontalCategoryScrollView> {

  bool isDark = false;
  DatabaseHelper helper = DatabaseHelper();
  List<Categories> categories = [];

  initialSetup() async {
    categories = widget.categories;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDark = prefs.getBool('isDark') ?? false;
    });
  }

  Widget itemCard(Categories category) {

    final selectedCategory = CategoryInheritedWidget.of(context).categoryType;
    var obj = LocalizationManager.of(context);
    debugPrint("category image =========> ${category.image}");
    return Semantics(
      label: "${obj.getTranslatedValue("category_item_talkback")} ${category.name}",
      hint:  obj.getTranslatedValue("category_hint_talkback"),
      value: category.name,
      selected: selectedCategory == category ? true : false,
      container: true,
      excludeSemantics: true,
      child: InkWell(
        onTap: () {
          widget.onCategoryChange(category);
        },
        child: Container(
          width: 150,
          height: 175,
          child: Card(
            color: selectedCategory == category ? (isDark ? Theme.of(context).primaryColor : Theme.of(context).primaryColorLight) : (isDark ? Theme.of(context).primaryColorLight : Colors.white) ,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(category.image),
                ),
                const SizedBox(height: 10,),
                Text(category.name, overflow: TextOverflow.ellipsis, maxLines: 2,)
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    initialSetup();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(itemBuilder: (context, index) {
     return itemCard(categories[index]);
    }, itemCount: categories.length > 0 ? categories.length : 0,
      scrollDirection: Axis.horizontal,
    );
  }
}



