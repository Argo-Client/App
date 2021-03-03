import 'package:flutter/material.dart';

import 'package:after_layout/after_layout.dart';

import 'package:Argo/main.dart';
import 'package:Argo/src/utils/hive/adapters.dart';
import 'package:Argo/src/ui/CustomWidgets.dart';

class Bronnen extends StatefulWidget {
  @override
  _Bronnen createState() => _Bronnen();
}

class _Bronnen extends State<Bronnen> with AfterLayoutMixin<Bronnen> {
  List<List<Bron>> bronnenView = [account.bronnen];
  List<String> breadcrumbs = ["Bronnen"];
  void afterFirstLayout(BuildContext context) => handleError(account.magister.bronnen.refresh, "Fout tijdens verversen van bronnen", context);
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (bronnenView.length > 1) bronnenView.removeLast();
        if (breadcrumbs.length > 1) breadcrumbs.removeLast();
        setState(() {});
        return Future.value(false);
      },
      child: AppPage(
        title: Text("Bronnen"),
        bottom: PreferredSize(
          child: Align(
            alignment: Alignment.centerLeft,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 10,
                bottom: 10,
                right: 10,
              ),
              reverse: true,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0; i < breadcrumbs.length; i++)
                    GestureDetector(
                      child: Row(
                        children: [
                          Text(
                            " ${breadcrumbs[i]} ",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 10,
                          ),
                        ],
                      ),
                      onTap: () {
                        setState(
                          () {
                            breadcrumbs = breadcrumbs.take(i + 1).toList();
                            bronnenView = bronnenView.take(i + 1).toList();
                          },
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          preferredSize: Size.fromHeight(25),
        ),
        body: RefreshIndicator(
          child: ValueListenableBuilder(
            valueListenable: updateNotifier,
            builder: (BuildContext context, _, _a) {
              return ListView(
                children: [
                  if (bronnenView.last == null)
                    Container(
                      height: bodyHeight(context),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (bronnenView.last.isEmpty)
                    Container(
                      height: bodyHeight(context),
                      child: Center(
                        child: Text("Deze map is leeg"),
                      ),
                    )
                  else
                    SeeCard(
                      column: [
                        for (Bron bron in bronnenView.last)
                          BijlageItem(
                            bron,
                            border: bronnenView.last.last != bron
                                ? Border(
                                    bottom: greyBorderSide(),
                                  )
                                : null,
                            onTap: () async {
                              if (bron.isFolder) {
                                breadcrumbs.add(
                                  bron.naam,
                                );
                                bronnenView.add(
                                  bron.children,
                                );
                                setState(
                                  () {},
                                );
                                if (bron.children == null) {
                                  await handleError(
                                    () async => await account.magister.bronnen.loadChildren(bron),
                                    "Kon ${bron.naam} niet laden.",
                                    context,
                                    () {
                                      setState(
                                        () {},
                                      );
                                      bronnenView = bronnenView
                                          .where(
                                            (list) => list != null,
                                          )
                                          .toList();
                                      bronnenView.add(
                                        bron.children,
                                      );
                                    },
                                  );
                                }
                              } else {
                                account.magister.bronnen.downloadFile(
                                  bron,
                                  (count, total) {
                                    setState(
                                      () {
                                        bron.downloadCount = count;
                                      },
                                    );
                                  },
                                );
                              }
                            },
                          ),
                      ],
                    ),
                ],
              );
            },
          ),
          onRefresh: () async {
            await handleError(account.magister.bronnen.refresh, "Kon bronnen niet verversen", context);
          },
        ),
      ),
    );
  }
}
