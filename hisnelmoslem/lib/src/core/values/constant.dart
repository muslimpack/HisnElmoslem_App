import 'package:flutter/material.dart';

//TODO App Version | Change every release
const String appVersion = "v2.6.01";

//Invert Image Color
const ColorFilter invert = ColorFilter.matrix(
  <double>[
    -1, 0, 0, 0, //
    255, 0, -1, 0, 0, //
    255, 0, 0, -1, 0, //
    255, 0, 0, 0, 1, 0, //
  ],
);

//Do nothing to Image Color
const ColorFilter normal = ColorFilter.matrix(
  <double>[
    1, 0, 0, 0, 0, //
    0, 1, 0, 0, 0, //
    0, 0, 1, 0, 0, //
    0, 0, 0, 1, 0, //
  ],
);

//GreyScale Image Color
const ColorFilter greyScale = ColorFilter.matrix(
  <double>[
    0.33, 0.59, 0.11, 0, 0, //
    0.33, 0.59, 0.11, 0, 0, //
    0.33, 0.59, 0.11, 0, 0, //
    0, 0, 0, 1, 0, //
  ],
);

const Iterable<int> arabicDiacriticsChar = [
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
  1618,
];

final List<Color> shareAsImageColorsList = [
  const Color.fromARGB(255, 66, 66, 66),
  const Color.fromARGB(255, 48, 48, 48),
  const Color.fromARGB(255, 163, 124, 92),
  const Color.fromARGB(255, 25, 26, 33),
  const Color.fromARGB(255, 1, 151, 159),
  Colors.amber,
  const Color.fromARGB(255, 255, 248, 238),
  const Color.fromARGB(255, 244, 246, 248),
];
