import 'package:audiobooks/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


class CustomToast {
  static void showToast(String text) {
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black38,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}

Snack(String msg, BuildContext ctx, Color color) {
  var snackBar = SnackBar(
      backgroundColor: color,
      content: Text(
        msg,
        textAlign: TextAlign.center,
      ));
  ScaffoldMessenger.of(ctx).showSnackBar(snackBar);
}

SnackAction(String msg, BuildContext ctx, Color color, Function fnc) {
  var snackBar = SnackBar(
      duration: Duration(seconds: 5),
      action: SnackBarAction(
        label: 'Open',
        onPressed: () {
          fnc();
        },
      ),
      backgroundColor: color,
      content: Text(
        msg,
        style: TextStyle(
            color: cFirstColor, fontSize: 15, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ));
  ScaffoldMessenger.of(ctx).showSnackBar(snackBar);
}