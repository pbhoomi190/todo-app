import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_page_transition/page_transition_type.dart';
import 'package:fluttertododemo/database/database_helper.dart';
import 'package:fluttertododemo/language_support/localization_manager.dart';
import 'package:fluttertododemo/screens/todo_list_screen.dart';
import 'package:fluttertododemo/widgets/custom_top_bar.dart';
import '../custom_route_transition.dart';
import 'package:fluttertododemo/database/ToDo.dart';
import 'package:fluttertododemo/constants/extensions.dart';

class AddToDoScreen extends StatefulWidget {
  @override
  _AddToDoScreenState createState() => _AddToDoScreenState();
}

class _AddToDoScreenState extends State<AddToDoScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  Categories selectedCategory;
  String title = "";
  String desc = "";
  String cat = "";
  String date = "";
  bool isValid = false;
  int dateInt;
  bool isReminder = false;
  List<Categories> categories = [];
  DatabaseHelper helper = DatabaseHelper();

  void showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message),);
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  void setCategory(Categories categoryType) {
    setState(() {
      selectedCategory = categoryType;
      categoryController.text = selectedCategory.name;
    });
  }

  void validate() {
      if (title.trim().isNotEmpty && desc.trim().isNotEmpty && cat.trim().isNotEmpty && date.trim().isNotEmpty) {
        setState(() {
          isValid = true;
        });
      } else {
        if (isValid == true) {
          setState(() {
            isValid = false;
          });
        }
      }
  }

  Future<void> initialSetup() async {
      var results = await helper.fetchCategories();
      results.forEach((element) {
        var category = Categories.fromMap(element);
        setState(() {
          categories.add(category);
        });
      });
      titleController.addListener(() {
          title = titleController.text;
          validate();
      });
      descController.addListener(() {
        desc = descController.text;
        validate();
      });
      categoryController.addListener(() {
        cat = categoryController.text;
        validate();
      });
      dateController.addListener(() {
        date = dateController.text;
        validate();
      });
  }

  Future openDatePicker(BuildContext ctx) async {
    DateTime pickedDate = await showDatePicker(
        context: ctx,
        initialDate: new DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: new DateTime(2025),
    );
    if(pickedDate != null) {
       var pickedTime = await timePicker(ctx);
       if (pickedTime != null) {
         var selectedDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
         var dateStr = await selectedDate.formattedDateString();
         setState(() {
           dateInt = selectedDate.millisecondsSinceEpoch;
           dateController.text = dateStr;
         });
       }
    }
  }

  Future<TimeOfDay> timePicker(BuildContext context) {
    return showTimePicker(context: context, initialTime: TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute));
  }

  void openCategoryPicker(BuildContext context) {
    final arrayCateggory = categories.length == 0 ? Categories.getDefaultCategories() : categories;
    print(categories.length);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(20.0)), //this right here
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColorLight],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft
                  ),
                  borderRadius:
                  BorderRadius.circular(20.0)
              ),
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: GridView.builder(
                        shrinkWrap: true,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                    Navigator.of(context).pop();
                                    setCategory(arrayCateggory[index]);
                              },
                              child: Card(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundImage: AssetImage(arrayCateggory[index].image),
                                    ),
                                    const SizedBox(height: 10,),
                                    Text(arrayCateggory[index].name, overflow: TextOverflow.ellipsis, maxLines: 2,)
                                  ],
                                ),
                              ),
                            );
                          },
                        itemCount: arrayCateggory.length,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void addToDoItem() async {
    var obj = LocalizationManager.of(context);
    ToDo toDo = ToDo(title: title, description: desc, date: dateInt, category: selectedCategory.id, isReminderOn: isReminder ? 1 : 0);
    var result = await helper.createToDoListItem(toDo);
    if (result == 0) {
      showSnackBar(obj.getTranslatedValue("create_error_msg"));
    } else {
      showSnackBar(obj.getTranslatedValue("create_success_msg"));
      Navigator.of(context).pushReplacement(CustomRoute(page: ToDoListScreen(), type: PageTransitionType.slideLeft));
    }
  }

  @override
  void initState() {
    initialSetup();
    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    categoryController.dispose();
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var obj = LocalizationManager.of(context);
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        //crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CustomTopBar(title: obj.getTranslatedValue("add_todo_title"), subTitle: obj.getTranslatedValue("add_todo_subtitle"), isLeft: true, onPop: () {
            Navigator.of(context).pop();
          }, isRight: false,),
          SizedBox(height: 30),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  TextField(
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(25),
                      ],
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: obj.getTranslatedValue("title_text"),
                        border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(width: 2),
                        ),
                      ),
                    ),
                  const SizedBox(height: 15),
                  TextField(
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(150),
                      ],
                      controller: descController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                        labelText: obj.getTranslatedValue("desc_text"),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(width: 2),
                        ),
                      ),
                    ),
                  const SizedBox(height: 15),
                  TextField(
                    readOnly: true,
                    showCursor: true,
                    controller: categoryController,
                    onTap: () {
                      openCategoryPicker(context);
                    },
                    decoration: InputDecoration(
                      labelText: obj.getTranslatedValue("category_string"),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    readOnly: true,
                    showCursor: true,
                    controller: dateController,
                    onTap: () {
                      openDatePicker(context);
                    },
                    decoration: InputDecoration(
                      labelText: obj.getTranslatedValue("date_text"),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Semantics(
                    label: "reminder_talkback",
                    selected: isReminder,
                    onTap: () {
                      setState(() {
                        isReminder = !isReminder;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(child: Text(obj.getTranslatedValue("reminder_switch"), maxLines: 2,)),
                        Tooltip(
                          message: obj.getTranslatedValue("reminder_msg_talkback"),
                          child: Switch(
                            value: isReminder,
                            onChanged: (value) {
                              setState(() {
                                isReminder = value;
                                print("Reminder value ==== $value");
                              });
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  LimitedBox(
                    maxWidth: 100,
                    maxHeight: 50,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: 100
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          gradient: LinearGradient(
                            colors: [Theme.of(context).primaryColorLight, Theme.of(context).primaryColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight
                          )
                      ),
                      child: FlatButton(
                        child: Text(obj.getTranslatedValue("save_text"), style: isValid ? Theme.of(context).textTheme.bodyText1 : TextStyle(fontSize: 20)),
                        onPressed: isValid ? () {
                          addToDoItem();
                        } : null,
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
