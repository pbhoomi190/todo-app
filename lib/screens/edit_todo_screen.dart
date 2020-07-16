import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertododemo/constants/extensions.dart';
import 'package:fluttertododemo/database/database_helper.dart';
import 'package:fluttertododemo/language_support/localization_manager.dart';
import 'package:fluttertododemo/speech_helper/speech_to_text_helper.dart';
import 'package:fluttertododemo/widgets/custom_top_bar.dart';
import 'package:fluttertododemo/database/ToDo.dart';


class EditToDoScreen extends StatefulWidget {
  final ToDo toDo;
  final bool isFromCompleted;
  EditToDoScreen({this.toDo, this.isFromCompleted});

  @override
  _EditToDoScreenState createState() => _EditToDoScreenState();
}

class _EditToDoScreenState extends State<EditToDoScreen> {
  TextEditingController titleController;
  TextEditingController categoryController;
  TextEditingController descController;
  TextEditingController dateController;
  Categories selectedCategory;
  String title = "";
  String desc = "";
  String cat = "";
  String date = "";
  bool isValid = false;
  bool isReminder = true;
  bool canReminderEnable = false;
  DatabaseHelper helper = DatabaseHelper();
  ToDo editToDo;
  bool isFromComplete = false;
  List<Categories> categories = [];
  SpeechToText speechToTextForTitle;
  FocusNode _focus = FocusNode();

  // Database update methods

  void updateReminder(bool isOn) async {
    debugPrint("update reminder called");
      await helper.turnOnOffReminderToDoItem(editToDo, isOn ? 1 : 0);
      editToDo.isReminderOn =  isOn ? 1 : 0;
      setState(() {
        isReminder = isOn;
      });
  }

  void updateToDo() async {
    debugPrint("update to-do called");
    updateReminder(isReminder);
      await helper.updateToDoItem(editToDo).then((value) {
        Navigator.of(context).pop(editToDo);
      });
  }

  Future<void> reAddToDo() async {
    ToDo toDo = ToDo(title: title, description: desc, date: editToDo.date, category: selectedCategory.id);
    await helper.createToDoListItem(toDo).then((value) {
      Navigator.of(context).pop();
    });
  }

  void setCategory(Categories categoryType) {
    setState(() {
      selectedCategory = categoryType;
      categoryController.text = selectedCategory.name;
    });
  }

  void validate() {
    editToDo.title = title.trim();
    editToDo.description = desc.trim();
    editToDo.category = selectedCategory.id;
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

  void _onFocusChange(){
    debugPrint("Focus: "+_focus.hasFocus.toString());
  }

  void initSpeechToTextForTitle() {
    _focus.addListener(_onFocusChange);
    speechToTextForTitle = SpeechToText(onAvailable: (isAvailable) {
      if (!isAvailable) {
        debugPrint("speech not available");
      }
    }, onListening: (isListening) {
      debugPrint("Is listening add title ===> $isListening");
    }, onPermissionStatus: (isGranted) {
      if (!isGranted) {
        print("Please allow app to record audio");
      }
    }, onResult: (text) {
      if (_focus.hasFocus == true) {
        print("sfasfhasfkjashfjksahfjas");
        titleController.text = text;
      } else {
        descController.text = text;
        print("223532554");
      }
    },);
    speechToTextForTitle.initSpeechRecognizer();
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

  Future<void> initialSetup() async {
    editToDo = widget.toDo;
    selectedCategory = await widget.toDo.category.getCategoryForId();
    isFromComplete = widget.isFromCompleted == null ? false : widget.isFromCompleted;
    if (isFromComplete == false) {
      getDate();
    }
    titleController = TextEditingController(text: widget.toDo.title);
    descController = TextEditingController(text: widget.toDo.description);
    dateController = TextEditingController(text: "");
    categoryController = TextEditingController(text: selectedCategory.name);
    isReminder = widget.toDo.isReminderOn == 0 ? false : true;
    var results = await helper.fetchCategories();
    results.forEach((element) {
      var category = Categories.fromMap(element);
      categories.add(category);
    });
    setState(() {

    });
    title = titleController.text;
    desc = descController.text;
    cat = categoryController.text;
    date = dateController != null ? dateController.text : "";
    validate();
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

  // Picker handle methods
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
        editToDo.date = selectedDate.millisecondsSinceEpoch;
        var dateStr = await selectedDate.formattedDateString();
        setState(() {
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
                              setCategory( arrayCateggory[index]);
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

  // Life cycle method

  void getDate() async {
    if (widget.toDo.date != 0) {
      date = await widget.toDo.date.dateString();
      setState(() {
        dateController.text = date;
      });
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          CustomTopBar(title: isFromComplete ? obj.getTranslatedValue("re_save_title") : obj.getTranslatedValue("edit_title"), isLeft: true, onPop: () {
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
                    focusNode: _focus,
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: obj.getTranslatedValue("title_text"),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.mic),
                        onPressed: () {
                          speechToTextForTitle.listen();
                        },
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
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: obj.getTranslatedValue("desc_text"),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.mic),
                        onPressed: () {
                          speechToTextForTitle.listen();
                        },
                      ),
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
                    label:  obj.getTranslatedValue("reminder_talkback"),
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
                                updateReminder(value);
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 50,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              gradient: LinearGradient(
                colors: [Theme.of(context).primaryColorLight, Theme.of(context).primaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight
              )
            ),
            child: FlatButton(
              child: Text(obj.getTranslatedValue("done_text"), style: isValid ? Theme.of(context).textTheme.bodyText1 : TextStyle(fontSize: 20)),
              onPressed: isValid ? () {
                isFromComplete == false ? updateToDo() : reAddToDo();
              } : null,
            ),
          )
        ],
      ),
    );
  }
}
