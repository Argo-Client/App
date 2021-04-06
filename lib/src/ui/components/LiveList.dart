import 'package:flutter/material.dart';
import 'package:argo/main.dart';
import 'package:auto_animated/auto_animated.dart';

final options = LiveOptions(
  // delay: Duration(milliseconds: 1),
  showItemInterval: Duration(milliseconds: 10),
  showItemDuration: Duration(milliseconds: 200),
  visibleFraction: 0.5,
  reAnimateOnVisibility: false,
);

Widget buildLiveList(list, loaded) {
  if (!userdata.get("liveList"))
    return Column(
      children: list,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
    );

  return LiveList.options(
      itemCount: list.length,
      options: options,
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemBuilder: (
        BuildContext context,
        int index,
        Animation<double> animation,
      ) {
        if (index <= loaded)
          return list[index];
        else
          return FadeTransition(
            opacity: Tween<double>(
              begin: 0,
              end: 1,
            ).animate(animation),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0, -0.1),
                end: Offset.zero,
              ).animate(animation),
              child: list[index],
            ),
          );
      });
}
