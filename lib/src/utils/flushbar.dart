import 'package:another_flushbar/flushbar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

void errorFlushbar(BuildContext context, String title, [error = ""]) {
  String message = error.toString();

  if (error is DioError) {
    if (error.type == DioErrorType.response) {
      message = error.response.data;
    } else {
      message = error.message;

      if (error.stackTrace.toString().isNotEmpty) {
        message += "\n${error.stackTrace.toString().split("\n").first}";
      }
    }
  }

  print(error);
  _defaultFlushbar(
    context,
    title + (message.isEmpty ? "" : "\n" + message),
    icon: Icon(
      Icons.warning,
      size: 28.0,
      color: Colors.red[300],
    ),
    leftColor: Colors.red[300],
  );
}

void successFlushbar(BuildContext context, String title) {
  _defaultFlushbar(context, title,
      icon: Icon(
        Icons.check_circle,
        color: Colors.green[300],
      ),
      leftColor: Colors.green[300]);
}

void _defaultFlushbar(BuildContext context, String message, {Icon icon, Color leftColor}) {
  Flushbar(
    message: message,
    icon: icon,
    backgroundColor: Theme.of(context).cardColor,
    leftBarIndicatorColor: leftColor,
    duration: Duration(seconds: 3),
    shouldIconPulse: false,
  ).show(context);
}
