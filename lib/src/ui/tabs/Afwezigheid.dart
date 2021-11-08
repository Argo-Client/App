import 'package:flutter/material.dart';

import 'package:after_layout/after_layout.dart';

import 'package:argo/src/utils/hive/adapters.dart';
import 'package:argo/src/utils/update.dart';
import 'package:argo/src/utils/handleError.dart';
import 'package:argo/src/utils/account.dart';

import 'package:argo/src/ui/components/Card.dart';
import 'package:argo/src/ui/components/AppPage.dart';
import 'package:argo/src/ui/components/EmptyPage.dart';
import 'package:argo/src/ui/components/ContentHeader.dart';
import 'package:argo/src/ui/components/ListTileDivider.dart';
import 'package:argo/src/ui/components/Refreshable.dart';

import 'Agenda.dart';

class Afwezigheid extends StatefulWidget {
  @override
  _Afwezigheid createState() => _Afwezigheid();
}

class _Afwezigheid extends State<Afwezigheid> with AfterLayoutMixin<Afwezigheid> {
  void afterFirstLayout(BuildContext context) => handleError(account().magister.afwezigheid.refresh, "Fout tijdens verversen van afwezigheid", context);

  Widget _buildAfwezigheid(Absentie afwezigheid, String hour) {
    return MaterialCard(
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
        subtitle: Text(hour + afwezigheid.les.getName()),
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
                      Text(" " + account().afwezigheid.where((afw) => afw.geoorloofd).length.toString()),
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
                      Text(" " + account().afwezigheid.where((afw) => !afw.geoorloofd).length.toString()),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ],
      body: Refreshable(
        onRefresh: account().magister.afwezigheid.refresh,
        type: "afwezigheid",
        builder: (context) {
          if (account().afwezigheid.isEmpty)
            return EmptyPage(
              text: "Geen afwezigheid",
              icon: Icons.check_circle_outlined,
            );

          Map<String, List<Absentie>> absentiesPerDay = {};
          List<Widget> absentiesWidgets = [];

          for (var absentie in account().afwezigheid) {
            absentiesPerDay[absentie.dag] ??= [];
            absentiesPerDay[absentie.dag].add(absentie);
          }

          absentiesPerDay.entries.forEach((day) {
            absentiesWidgets.addAll(
              [
                ContentHeader(day.key),
                ...divideListTiles(
                  day.value
                      .map(
                        (absentie) => _buildAfwezigheid(absentie, absentie.les.hour.isEmpty ? "" : absentie.les.hour + "e - "),
                      )
                      .toList(),
                ),
              ],
            );
          });

          return ListView(
            children: absentiesWidgets,
          );
        },
      ),
    );
  }
}
