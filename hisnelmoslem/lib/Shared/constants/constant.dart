import 'package:flutter/material.dart';

const Color MAINCOLOR = Color(0xFF90CAF9);
const Color SCROLLENDCOLOR = Colors.black26;
const String APP_VERSION = "v1.5.0";
//
Color bleuShade200 = Colors.blue.shade200;
Color transparent = Colors.transparent;
Color white = Colors.white;
Color orange = Colors.orange;
Color redAccent = Colors.redAccent;
Color black26 = Colors.black26;
Color black = Colors.black;
Color blue = Colors.blue;
Color grey = Colors.grey;

//
Color brwon = Color.fromARGB(255, 92, 71, 61);
Color red = Color.fromARGB(255, 122, 54, 59);
Color green = Color.fromARGB(255, 50, 82, 65);
Color yellow = Color.fromARGB(255, 146, 118, 63);
//
//Invert Image Color
const ColorFilter invert = ColorFilter.matrix(<double>[
  -1, 0, 0, 0, //
  255, 0, -1, 0, 0, //
  255, 0, 0, -1, 0, //
  255, 0, 0, 0, 1, 0, //
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

const Iterable<int> arabicTashkelChar = [
  1617,
  124,
  1614,
  124,
  1611,
  124,
  1615,
  124,
  1612,
  124,
  1616,
  124,
  1613,
  124,
  1618
];
