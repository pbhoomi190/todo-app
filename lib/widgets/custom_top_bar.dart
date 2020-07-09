import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertododemo/constants/constants.dart';
import 'package:fluttertododemo/language_support/localization_manager.dart';

class CustomTopBar extends StatelessWidget {
  @required final String title;
  final bool isLeft;
  final bool isRight;
  final String subTitle;
  final VoidCallback onPop;
  final VoidCallback onSetting;
  CustomTopBar({this.title, this.subTitle, this.isLeft, this.isRight, this.onPop, this.onSetting});

  @override
  Widget build(BuildContext context) {
    var obj = LocalizationManager.of(context);
    return Container(
      child: SafeArea(
        child: Stack(
          children: <Widget>[
            Align(
              alignment: appGlobalLocale.languageCode == 'ar' ? Alignment.topRight :  Alignment.topLeft,
              child: Visibility(
                visible: isLeft,
                child: IconButton(
                  tooltip: obj.getTranslatedValue("back_btn_talkback"),
                  icon: Icon(Icons.arrow_back_ios, color: Colors.black,),
                  onPressed: () {
                    onPop();
                  },
                ),
              ),
            ),
            Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline6),
                    Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: Text(subTitle != null ? subTitle : "", style: Theme.of(context).textTheme.bodyText2, textAlign: TextAlign.center,),
                    )
                  ],
                )),
            Align(
              alignment: appGlobalLocale.languageCode == 'ar' ? Alignment.topLeft :  Alignment.topRight,
              child: Visibility(
                visible: isRight,
                child: Container(
                  child: IconButton(
                    tooltip: obj.getTranslatedValue("setting_btn_talkback"),
                    icon: Icon(Icons.settings),
                    onPressed: () {
                      onSetting();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      height: 150.0,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorLight,
        gradient: LinearGradient(
          colors: [Theme.of(context).primaryColorLight, Theme.of(context).primaryColor],
          begin: Alignment.centerLeft,
          end: Alignment.bottomRight
        ),
        boxShadow: [
           BoxShadow(blurRadius: 10.0)
        ],
        borderRadius: BorderRadius.vertical(
            bottom: Radius.elliptical(
                MediaQuery.of(context).size.width, 100.0)),
      ),
    );
  }
}
