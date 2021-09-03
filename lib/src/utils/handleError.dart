import 'package:flutter/material.dart';

import 'package:flushbar/flushbar_helper.dart';

import 'package:argo/src/utils/update.dart';
import 'package:argo/src/utils/account.dart';

Future handleError(Function fun, String msg, BuildContext context, [Function cb]) async {
  if (account.id != 0) {
    try {
      await fun();
      update();
      if (cb != null) cb();
    } catch (e) {
      String flush = "$msg:\n$e";
      try {
        flush = "$msg:\n${e.error}";
      } catch (_) {
        throw (e);
      }
      FlushbarHelper.createError(message: flush)..show(context);
    }
  }
}
