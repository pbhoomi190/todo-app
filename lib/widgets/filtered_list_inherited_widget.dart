import 'package:flutter/material.dart';
import 'package:fluttertododemo/constants/category.dart';

class CategoryInheritedWidget extends InheritedWidget {
  final CategoryType categoryType;

  CategoryInheritedWidget({this.categoryType, Widget child}) : super(child: child);

  static CategoryInheritedWidget of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CategoryInheritedWidget>();

  @override
  bool updateShouldNotify(CategoryInheritedWidget oldWidget) {
    print('should update notify');
    if (oldWidget.categoryType != categoryType) {
      return true;
    }
    return false;
  }

}