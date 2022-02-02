import 'package:flutter/material.dart';

const Color MAINCOLOR = Color(0xFF90CAF9);
const Color SCROLLENDCOLOR = Colors.black26;
const String APP_VERSION = "v1.5.0";
//
Color brwon = Color.fromARGB(255, 92, 71, 61);
Color red = Color.fromARGB(255, 122, 54, 59);
Color green = Color.fromARGB(255, 50, 82, 65);

Color yellow = Color.fromARGB(255, 146, 118, 63);
//
//Invert Image Color
const ColorFilter invert = ColorFilter.matrix(<double>[
  -1,
  0,
  0,
  0,
  255,
  0,
  -1,
  0,
  0,
  255,
  0,
  0,
  -1,
  0,
  255,
  0,
  0,
  0,
  1,
  0,
]);

//Do nothing to Image Color
const ColorFilter normal = ColorFilter.matrix(<double>[
  1, 0, 0, 0, 0, //
  0, 1, 0, 0, 0, //
  0, 0, 1, 0, 0, //
  0, 0, 0, 1, 0, //
]);

//GreyScale Image Color
const ColorFilter greyScale = ColorFilter.matrix(<double>[
  0.33, 0.59, 0.11, 0, 0, //
  0.33, 0.59, 0.11, 0, 0, //
  0.33, 0.59, 0.11, 0, 0, //
  0, 0, 0, 1, 0, //
]);
