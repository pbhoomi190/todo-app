import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_page_transition/page_transition_type.dart';
import 'package:fluttertododemo/database/calendar_helper.dart';
import 'package:fluttertododemo/database/database_helper.dart';
import 'package:fluttertododemo/language_support/localization_manager.dart';
import 'package:fluttertododemo/screens/todo_list_screen.dart';
import 'package:fluttertododemo/speech_helper/speech_to_text_helper.dart';
import 'package:fluttertododemo/widgets/custom_top_bar.dart';
import '../custom_route_transition.dart';
import 'package:fluttertododemo/database/ToDo.dart';
import 'package:fluttertododemo/constants/extensions.dart';
import 'package:fluttertododemo/ml_helper/image_picker_screen.dart';

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
  CalendarHelper calendarHelper = CalendarHelper();

  Categories selectedCategory;
  String title = "";
  String desc = "";
  String cat = "";
  String date = "";
  bool isValid = false;
  int dateInt = 0;
  bool isReminder = false;
  bool canReminderEnable = false;
  List<Categories> categories = [];
  DatabaseHelper helper = DatabaseHelper();
  SpeechToConvertText speechToTextForTitle = SpeechToConvertText();
  FocusNode _focus = FocusNode();

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
      if (date.trim().isNotEmpty) {
        setState(() {
          canReminderEnable = true;
       });
      } else {
        if (canReminderEnable == true) {
        setState(() {
          canReminderEnable = false;
        });
      }
     }
      if (title.trim().isNotEmpty && desc.trim().isNotEmpty && cat.trim().isNotEmpty) {
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

  void showSpeechAlert(String message) {
    showDialog(
        context: context,
        child: AlertDialog(
          title: Text("Alert!"),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text("OK", style: Theme.of(context).textTheme.bodyText2,),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        )
    );
  }

  void _onFocusChange(){
    debugPrint("Focus: "+_focus.hasFocus.toString());
  }

  void initSpeechToTextForTitle() {
    _focus.addListener(_onFocusChange);

    speechToTextForTitle.resultObserver.listen((text) {
      if (_focus.hasFocus == true) {
        titleController.text = text;
      } else {
        descController.text = text;
      }
    });

    speechToTextForTitle.permissionObserver.listen((value) {
      debugPrint("permission status ======> $value");
    });
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
      initSpeechToTextForTitle();
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                                    Text(arrayCateggory[index].name, overflow: TextOverflow.ellipsis, maxLines: 2, textAlign: TextAlign.center,)
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
    ToDo toDo = ToDo(
        title: title,
        description: desc,
        date: dateInt,
        category: selectedCategory.id,
        isReminderOn: isReminder ? 1 : 0,);
    var result = await helper.createToDoListItem(toDo);
    if (result == 0) {
      showSnackBar(obj.getTranslatedValue("create_error_msg"));
    } else {
      showSnackBar(obj.getTranslatedValue("create_success_msg"));
      if (toDo.category == 4 && toDo.date != 0) {
        toDo.id = result;
        addToCalendar(toDo, result);
      } else {
        Navigator.of(context).pushReplacement(CustomRoute(page: ToDoListScreen(), type: PageTransitionType.slideLeft));
      }
    }
  }

  void addToCalendar(ToDo toDo, int id) async{
    calendarHelper.retrieveCalendars().then((value) {
      calendarHelper.addToCalendar(toDo).then((value) {
        Navigator.of(context).pushReplacement(CustomRoute(page: ToDoListScreen(), type: PageTransitionType.slideLeft));
      });
    });
  }

  void moveToGetDescriptionFromText() async {
      var result = await Navigator.of(context).push(CustomRoute(page: ImagePickerScreen(), type: PageTransitionType.slideInLeft));
        String description = result as String;
          descController.text = description;
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
          const SizedBox(height: 30),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  TextField(
                    focusNode: _focus,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(25),
                      ],
                      controller: titleController,
                      onEditingComplete: () {
                        debugPrint("On editing complete on title");
                        speechToTextForTitle.stopListening();
                      },
                      decoration: InputDecoration(
                        labelText: obj.getTranslatedValue("title_text"),
                        suffixIcon: Wrap(
                          direction: Axis.horizontal,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.mic_off),
                              onPressed: () {
                                speechToTextForTitle.stopListening();
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.mic),
                              onPressed: () {
                                speechToTextForTitle.lastWords = titleController.text;
                                speechToTextForTitle.startListening();
                              },
                            ),
                          ],
                        ),
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
                      onEditingComplete: () {
                       debugPrint("On editing complete on title");
                       speechToTextForTitle.stopListening();
                      },
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                        labelText: obj.getTranslatedValue("desc_text"),
                        suffixIcon: Wrap(
                          direction: Axis.horizontal,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.mic_off),
                              onPressed: () {
                                speechToTextForTitle.stopListening();
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.mic),
                              onPressed: () {
                                  speechToTextForTitle.lastWords = descController.text;
                                  speechToTextForTitle.startListening();
                              },
                            ),
                          ],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(width: 2),
                        ),
                      ),
                    ),
                  InkWell(
                    onTap: () {
                      moveToGetDescriptionFromText();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(obj.getTranslatedValue("image_picker"), style: TextStyle(fontSize: 14),),
                        Icon(Icons.navigate_next)
                      ],
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
                              if (canReminderEnable) {
                                setState(() {
                                  isReminder = value;
                                  print("Reminder value ==== $value");
                                });
                              }
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
