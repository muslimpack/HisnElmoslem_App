import 'package:flutter/material.dart';

const Color MAINCOLOR = Color(0xFF90CAF9);
const Color SCROLLENDCOLOR = Colors.black26;
const String APP_VERSION = "v1.3.0";


//Invert Image Color
const ColorFilter invert = ColorFilter.matrix(<double>[
  -1,  0,  0, 0, 255,
  0, -1,  0, 0, 255,
  0,  0, -1, 0, 255,
  0,  0,  0, 1,   0,
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
  0.33, 0.59,0.11, 0,0,//
  0.33,0.59,0.11, 0,0,//
  0.33, 0.59,0.11, 0,0,//
  0, 0, 0, 1, 0, //
]);
