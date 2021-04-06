import 'package:argo/src/ui/components/ContentHeader.dart';
import 'package:flutter/material.dart';

import 'package:after_layout/after_layout.dart';

import 'package:argo/main.dart';
import 'package:argo/src/utils/hive/adapters.dart';

import 'package:argo/src/ui/components/Card.dart';
import 'package:argo/src/ui/components/Utils.dart';
import 'package:argo/src/ui/components/AppPage.dart';
import 'package:argo/src/ui/components/EmptyPage.dart';
import 'package:argo/src/ui/components/LiveList.dart';

import 'Agenda.dart';

class Afwezigheid extends StatefulWidget {
  @override
  _Afwezigheid createState() => _Afwezigheid();
}

class _Afwezigheid extends State<Afwezigheid> with AfterLayoutMixin<Afwezigheid> {
  void afterFirstLayout(BuildContext context) => handleError(account.magister.afwezigheid.refresh, "Fout tijdens verversen van afwezigheid", context);

  Widget _buildAfwezigheid(Absentie afwezigheid, int i, String hour) {
    return SeeCard(
      border: account.afwezigheid.length - 1 == i || account.afwezigheid[i + 1].dag != afwezigheid.dag
          ? null
          : Border(
              bottom: greyBorderSide(),
            ),
      child: ListTile(
        leading: Padding(
          child: afwezigheid.geoorloofd
              ? Icon(
                  Icons.check,
                  color: Colors.green,
                )
              : Icon(
                  Icons.error_outlined,
                  color: Colors.redAccent,
                ),
          padding: EdgeInsets.only(
            top: 7,
            left: 7,
          ),
        ),
        subtitle: Text(hour + afwezigheid.les.title),
        title: Text(afwezigheid.type),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => LesPagina(afwezigheid.les),
            ),
          );
        },
        trailing: afwezigheid.les.huiswerk != null
            ? !afwezigheid.les.huiswerkAf
                ? Icon(
                    Icons.assignment_outlined,
                    size: 23,
                    color: Colors.grey,
                  )
                : Icon(
                    Icons.assignment_turned_in_outlined,
                    size: 23,
                    color: Colors.green,
                  )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: Text("Afwezigheid"),
      actions: [
        ValueListenableBuilder(
          valueListenable: updateNotifier,
          builder: (context, _, _a) => Row(
            children: [
              Tooltip(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: 15,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check),
                      Text(" " + account.afwezigheid.where((afw) => afw.geoorloofd).length.toString()),
                    ],
                  ),
                ),
                message: "Geoorloofd",
              ),
              Tooltip(
                message: "Ongeoorloofd",
                child: Padding(
                  padding: EdgeInsets.only(
                    right: 15,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error),
                      Text(" " + account.afwezigheid.where((afw) => !afw.geoorloofd).length.toString()),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ],
      body: RefreshIndicator(
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: ValueListenableBuilder(
            valueListenable: updateNotifier,
            builder: (BuildContext context, _, _a) {
              if (account.afwezigheid.isEmpty)
                return EmptyPage(
                  text: "Geen afwezigheid",
                  icon: Icons.check_circle_outlined,
                );

              List<Widget> absenties = [];
              String lastDay;
              for (int i = 0; i < account.afwezigheid.length; i++) {
                Absentie afw = account.afwezigheid[i];
                String hour = afw.les.hour.isEmpty ? "" : afw.les.hour + "e - ";
                if (lastDay != afw.dag) {
                  absenties.add(
                    ContentHeader(afw.dag),
                  );
                }

                absenties.add(
                  _buildAfwezigheid(afw, i, hour),
                );

                lastDay = afw.dag;
              }

              return buildLiveList(absenties, 10);
            },
          ),
        ),
        onRefresh: () async {
          await handleError(account.magister.afwezigheid.refresh, "Fout tijdens verversen van afwezigheid", context);
        },
      ),
    );
  }
}
