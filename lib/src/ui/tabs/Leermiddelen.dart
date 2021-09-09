import 'package:argo/src/ui/components/Refreshable.dart';
import 'package:flutter/material.dart';

import 'package:argo/src/utils/hive/adapters.dart';
import 'package:argo/src/utils/handleError.dart';
import 'package:argo/src/utils/account.dart';

import 'package:argo/src/ui/components/Card.dart';
import 'package:argo/src/ui/components/greyBorderSize.dart';
import 'package:argo/src/ui/components/ListTileBorder.dart';
import 'package:argo/src/ui/components/AppPage.dart';
import 'package:argo/src/ui/components/EmptyPage.dart';

class Leermiddelen extends StatefulWidget {
  @override
  _Leermiddelen createState() => _Leermiddelen();
}

class _Leermiddelen extends State<Leermiddelen> {
  void afterFirstLayout(BuildContext context) => handleError(account().magister.leermiddelen.refresh, "Fout tijdens verversen van leermiddelen", context);

  @override
  Widget build(BuildContext context) => AppPage(
        title: Text("Leermiddelen"),
        body: Refreshable(
          type: "leermiddelen",
          onRefresh: account().magister.leermiddelen.refresh,
          child: account().leermiddelen.isEmpty
              ? EmptyPage(
                  text: "Geen leermiddelen",
                  icon: Icons.language_outlined,
                )
              : Column(
                  children: [
                    for (Leermiddel leermiddel in account().leermiddelen)
                      MaterialCard(
                        child: Tooltip(
                          message: leermiddel.title,
                          child: ListTileBorder(
                            onTap: () => account().magister.leermiddelen.launch(leermiddel),
                            border: account().leermiddelen.last == leermiddel
                                ? null
                                : Border(
                                    bottom: greyBorderSide(),
                                  ),
                            title: Text(
                              leermiddel.title,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: leermiddel?.uitgeverij == null
                                ? null
                                : Text(
                                    leermiddel?.uitgeverij,
                                  ),
                            trailing: Text(
                              leermiddel?.vak?.code ?? "",
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      );
}
