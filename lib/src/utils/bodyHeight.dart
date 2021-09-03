import 'package:flutter/material.dart';

double bodyHeight(context) {
  double screenheight = MediaQuery.of(context).size.height;
  double defaultAppBarHeight = AppBar().preferredSize.height;
  double statusBar = MediaQuery.of(context).padding.top;
  return screenheight - defaultAppBarHeight - statusBar - kToolbarHeight;
}
