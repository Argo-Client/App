import 'package:flutter/material.dart';

import 'package:argo/src/utils/bodyHeight.dart';
import 'package:argo/src/utils/handleError.dart';
import 'package:argo/src/utils/update.dart';

class Refreshable extends StatelessWidget {
  final Widget Function(BuildContext) builder;
  final Widget child;
  final Future Function() onRefresh;
  final String type;

  Refreshable({this.builder, this.child, this.onRefresh, this.type});

  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: () async {
          await handleError(onRefresh, "Fout tijdens verversen van $type", context);
        },
        child: Container(
          height: bodyHeight(context),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: ValueListenableBuilder(
              valueListenable: updateNotifier,
              builder: (context, _, _a) => child ?? builder(context),
            ),
          ),
        ),
      );
}
