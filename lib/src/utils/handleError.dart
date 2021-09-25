import 'package:flutter/material.dart';

import 'package:argo/src/utils/flushbar.dart';
import 'package:argo/src/utils/update.dart';
import 'package:argo/src/utils/account.dart';

Future handleError(Future Function() fun, String msg, BuildContext context, [Function cb]) async {
  if (account().id != 0) {
    try {
      await fun();
      update();
      if (cb != null) cb();
    } catch (e) {
      errorFlushbar(context, "$msg:", e);
    }
  }
}
