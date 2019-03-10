library gym_notebook.decorations;

import 'package:flutter/material.dart';

InputDecoration notesDecoration = InputDecoration(
  labelText: 'Notes',
  contentPadding:
      EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0, right: 100.0),
);

Color primaryColor = Colors.orange;
Color accentColor = Colors.purple;

ShapeDecoration iconButtonDecoration =
    ShapeDecoration(color: accentColor, shape: CircleBorder());
