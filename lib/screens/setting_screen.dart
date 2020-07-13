import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertododemo/database/ToDo.dart';
import 'package:fluttertododemo/database/database_helper.dart';
import 'package:fluttertododemo/language_support/language.dart';
import 'package:fluttertododemo/language_support/localization_manager.dart';
import 'package:fluttertododemo/main.dart';
import 'package:fluttertododemo/widgets/custom_top_bar.dart';
import 'package:fluttertododemo/widgets/time_select_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertododemo/constants/constants.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool isDarkTheme = false;
  Reminder selectedTime;
  DatabaseHelper helper = DatabaseHelper();
  List<Reminder> reminderTimes = [];
  List<Categories> allCategories = [];
  Language selectedLanguage = Language.listOfLanguage().first;
  TextEditingController textCategoryController = TextEditingController(text: "");

  void changeLanguage(Language language) {
    print(language.languageCode);
    Locale temp = Locale(language.languageCode);
    MyApp.setLocale(context, temp);
    setState(() {
      selectedLanguage = language;
    });
  }

  void getSelectedLanguage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var locale = prefs.getString('locale') ?? "en";
    print(locale);
    selectedLanguage = Language.listOfLanguage().firstWhere((element) => element.languageCode == locale);
  }

  fetchFromDatabase() async {
    var results = await helper.fetchReminders();
    var arrCategory = await helper.fetchCategories(showHidden: false);
    arrCategory.forEach((element) {
      var category = Categories.fromMap(element);
      allCategories.add(category);
    });
    results.forEach((element) {
      var reminder = Reminder.fromMap(element);
      reminderTimes.add(reminder);
    });
    setState(() {
      selectedTime = reminderTimes.where((element) {
        return element.isSelected == 1;
      }).toList().first;
    });
  }

  void openLanguageSelectionDialog(BuildContext context) {
    var obj = LocalizationManager.of(context);
    List<Language> array = Language.listOfLanguage();
      showDialog(
          context: context,
        builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColorLight],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft
                  ),
                    borderRadius: BorderRadius.all(Radius.circular(20))
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ListView.builder(itemBuilder: (context, index) {
                    if (index == 0) {
                      return Container(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(obj.getTranslatedValue("select_language"), style: Theme.of(context).textTheme.bodyText1,),
                        ),
                      );
                    } else {
                      return OutlineButton(
                        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                        child: Text(array[index - 1].name, style: Theme.of(context).textTheme.bodyText2),
                        onPressed: () {
                          Navigator.of(context).pop();
                          changeLanguage(array[index - 1]);
                        },
                      );
                    }
                  },
                    itemCount: array.length + 1,
                  )
                ),
              ),
            );
        }
      );
  }

  void onReminderTimeChange(Reminder time) {
    helper.setSelectedForReminder(time, 1);
    reminderTimes.where((element) {
      return element.id != time.id;
    }).toList().forEach((element) {
      helper.setSelectedForReminder(element, 0);
    });
    helper.updateReminderForAllToDo(time.time);
    setState(() {
      selectedTime = time;
    });
  }

  Future<void> addCustomCategory(String name) async {
    Categories category= Categories(name: name, image: otherImage, isHidden: 0, isAll: 0, isFav: 0);
    var result = await helper.addCategory(category);
    setState(() {
      category.id = result;
      allCategories.add(category);
    });
  }

  void openCategoryListDialog(BuildContext context) {
    var obj = LocalizationManager.of(context);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))
            ),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColorLight],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(20))
              ),
              child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ListView.builder(itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              openCategoryAdder();
                            },
                            child: Row(
                              children: <Widget>[
                                CircleAvatar(
                                  radius: 20,
                                  child: Icon(Icons.add)
                                ),
                                const SizedBox(width: 10,),
                                Text(obj.getTranslatedValue("add_category"), overflow: TextOverflow.ellipsis, maxLines: 2,)
                              ],
                            ),
                          ),
                          Divider(),
                        ],
                      );
                    } else {
                      return Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: AssetImage(allCategories[index - 1].image),
                              ),
                              const SizedBox(width: 10,),
                              Text(allCategories[index - 1].name, overflow: TextOverflow.ellipsis, maxLines: 2,)
                            ],
                          ),
                          Divider()
                        ],
                      );
                    }
                  },
                    itemCount: allCategories.length + 1,
                  )
              ),
            ),
          );
        }
    );
  }

  void openCategoryAdder() {
    var obj = LocalizationManager.of(context);
      showDialog(context: context,
        child: AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: new Row(
            children: <Widget>[
              new Expanded(
                child: new TextField(
                  controller: textCategoryController,
                  maxLength: 15,
                  autofocus: true,
                  decoration: new InputDecoration(
                      labelText: obj.getTranslatedValue("category_label"), hintText: obj.getTranslatedValue("category_hint")),
                ),
              )
            ],
          ),
          actions: <Widget>[
            new FlatButton(
                child: Text('${obj.getTranslatedValue("cancel_text")}'),
                onPressed: () {
                  textCategoryController.text = "";
                  Navigator.pop(context);
                }),
            new FlatButton(
                child: Text(obj.getTranslatedValue("add_text")),
                onPressed: () {
                  addCustomCategory(textCategoryController.text.trim()).then((value) {
                    textCategoryController.text = "";
                    Navigator.pop(context);
                  });
                })
          ],
        )
      );
  }

  getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkTheme = prefs.getBool('isDark') ?? false;
    });
  }

  Widget darkTheme() {
    var obj = LocalizationManager.of(context);
    return Semantics(
      label: obj.getTranslatedValue("dark_theme_talkback"),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(obj.getTranslatedValue("dark_theme"), style: Theme.of(context).textTheme.bodyText1,),
          Tooltip(
            message: obj.getTranslatedValue("dark_theme_msg_talkback"),
            child: Switch(
              activeColor: Theme.of(context).primaryColor,
              value: isDarkTheme,
              onChanged: (isOn) {
                setState(() {
                  isDarkTheme = isOn;
                  MyApp.setTheme(context, isDarkTheme ? ThemeMode.dark : ThemeMode.light);
                });
              },
            ),
          )
        ],
      ),
    );
  }

  Widget selectLanguage() {
    var obj = LocalizationManager.of(context);
    return InkWell(
      onTap: () {
        openLanguageSelectionDialog(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(25)),
          gradient: LinearGradient(
              colors: [Colors.greenAccent, Colors.black12],
              begin: Alignment.centerLeft,
              end: Alignment.bottomRight
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(child: Text("${obj.getTranslatedValue("select_language")} (${selectedLanguage.name})", style: Theme.of(context).textTheme.bodyText1,)),
            Icon(Icons.keyboard_arrow_down)
          ],
        ),
      ),
    );
  }

  Widget categoryList() {
    var obj = LocalizationManager.of(context);
    return InkWell(
      onTap: () {
          openCategoryListDialog(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(25)),
          gradient: LinearGradient(
              colors: [Colors.red, Colors.black12],
              begin: Alignment.centerLeft,
              end: Alignment.bottomRight
          ),
        ),
        child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(child: Text("${obj.getTranslatedValue("category_string")}", style: Theme.of(context).textTheme.bodyText1,)),
          Icon(Icons.keyboard_arrow_down)
        ],
      ),
      ),
    );
  }

  @override
  void initState() {
    fetchFromDatabase();
    getData();
    getSelectedLanguage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var obj = LocalizationManager.of(context);
    return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              CustomTopBar(title: obj.getTranslatedValue("setting_title"), subTitle: obj.getTranslatedValue("setting_subtitle"), isLeft: true, isRight: false, onPop: () {
                Navigator.of(context).pop();
              },),
              const SizedBox(height: 30,),
              InkWell(
                onTap: () {
                  showDialog(context: context, builder: (context) => TimeSelectDialog(reminderTimes: reminderTimes, onReminderTimeChange: (time) {
                    Navigator.of(context).pop();
                    onReminderTimeChange(time);
                  },));
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(25)),
                    gradient: LinearGradient(
                        colors: [Colors.black12, Colors.red],
                        begin: Alignment.centerLeft,
                        end: Alignment.bottomRight
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(obj.getTranslatedValue("reminder_setting"), style: Theme.of(context).textTheme.bodyText1, maxLines: 2,
                              overflow: TextOverflow.ellipsis,),
                            const SizedBox(height: 5,),
                            Text("${obj.getTranslatedValue("remind_before_text")} ${ selectedTime != null ? selectedTime.name : "15 minutes"}", style: Theme.of(context).textTheme.bodyText1, maxLines: 2,
                                overflow: TextOverflow.ellipsis,),
                            const SizedBox(height: 5,),
                            Text(obj.getTranslatedValue("remind_suggestion_text"),
                              style: Theme.of(context).textTheme.bodyText2,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5,),
                          ],
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down)
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(25)),
                  gradient: LinearGradient(
                      colors: [Colors.black12, Colors.cyan],
                      begin: Alignment.centerLeft,
                      end: Alignment.bottomRight
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(obj.getTranslatedValue("tune_setting"), style: Theme.of(context).textTheme.bodyText1, maxLines: 2,
                            overflow: TextOverflow.ellipsis,),
                          const SizedBox(height: 5,),
                          Text(obj.getTranslatedValue("reminder_tune"), style: Theme.of(context).textTheme.bodyText1, maxLines: 2,
                            overflow: TextOverflow.ellipsis,),
                          const SizedBox(height: 5,),
                          Text(obj.getTranslatedValue("tune_suggestion_text"),
                            style: Theme.of(context).textTheme.bodyText2,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5,),
                        ],
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down)
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  gradient: LinearGradient(
                      colors: [Colors.greenAccent, Colors.black12],
                      begin: Alignment.centerLeft,
                      end: Alignment.bottomRight
                  ),
                ),
                child: darkTheme(),
              ),
              selectLanguage(),
              categoryList(),
            ],
          ),
        ),
    );
  }
}
