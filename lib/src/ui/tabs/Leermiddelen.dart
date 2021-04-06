import 'package:flutter/material.dart';

import 'package:argo/main.dart';
import 'package:argo/src/utils/hive/adapters.dart';
import 'package:argo/src/ui/CustomWidgets.dart';

class Leermiddelen extends StatefulWidget {
  @override
  _Leermiddelen createState() => _Leermiddelen();
}

class _Leermiddelen extends State<Leermiddelen> {
  void afterFirstLayout(BuildContext context) => handleError(account.magister.leermiddelen.refresh, "Fout tijdens verversen van leermiddelen", context);
  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: Text("Leermiddelen"),
      body: RefreshIndicator(
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: ValueListenableBuilder(
              valueListenable: updateNotifier,
              builder: (BuildContext context, _, _a) {
                if (account.leermiddelen.isEmpty) {
                  return EmptyPage(
                    text: "Geen leermiddelen",
                    icon: Icons.language_outlined,
                  );
                }
                return Column(
                  children: [
                    for (Leermiddel leermiddel in account.leermiddelen)
                      SeeCard(
                        child: Tooltip(
                          message: leermiddel.title,
                          child: ListTileBorder(
                            onTap: () => account.magister.leermiddelen.launch(leermiddel),
                            border: account.leermiddelen.last == leermiddel
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
                );
              }),
        ),
        onRefresh: () async {
          await handleError(account.magister.leermiddelen.refresh, "Fout tijdens verversen van leermiddelen", context);
        },
      ),
    );
  }
}
