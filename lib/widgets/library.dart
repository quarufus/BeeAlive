import 'dart:collection';

import 'package:flutter/material.dart';

enum AppColors{
  background,
  foreground,
  accent;
}

const appColors = <String, Color>{
  'background' : Colors.red,
  'foreground' : Colors.brown,
  'accent' : Colors.white,
};

class AppColore {
  Color background = Colors.black;
  Color get foreground => Colors.black;
}

TextStyle buttonTextStyle() {
  return const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    fontFamily: "Nuniko",
  );
}

AppBar myAppBarr(Text title) {
  return AppBar(
    title: title,
    backgroundColor: Colors.black,
  );
}