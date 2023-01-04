import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScreenUtils {
  final BuildContext _context;

  ScreenUtils(this._context);

  void navigateTo(Widget destination,
      {bool replaceScreen = false, Function? listener = null}) {
    if (replaceScreen) {
      Navigator.pushReplacement(
        _context,
        MaterialPageRoute(
          builder: (context) => destination,
        ),
      ).then((value) {
        if (listener != null) {
          listener(value);
        }
      });
    } else {
      Navigator.push(
        _context,
        MaterialPageRoute(
          builder: (context) => destination,
        ),
      ).then((value) {
        if (listener != null) {
          listener(value);
        }
      });
    }
  }

  void finish() {
    if (Navigator.canPop(_context)) {
      Navigator.pop(_context);
    } else {
      SystemNavigator.pop();
    }
  }
}
