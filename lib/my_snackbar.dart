import 'package:flutter/material.dart';

class MySnackbar {
  BuildContext _context;

  MySnackbar(this._context);

  void errorSnackbar(String message) {
    ScaffoldMessenger.of(_context).showSnackBar(SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      duration: const Duration(seconds: 4),
      backgroundColor: Colors.red,
    ));
  }

  void successSnackbar(String message) {
    ScaffoldMessenger.of(_context).showSnackBar(SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      duration: const Duration(seconds: 4),
      backgroundColor: Colors.green,
    ));
  }
}
