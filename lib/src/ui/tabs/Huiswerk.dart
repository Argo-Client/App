import 'package:flutter/material.dart';

import 'package:after_layout/after_layout.dart';
import 'package:intl/intl.dart';
import 'package:futuristic/futuristic.dart';
import 'package:infinity_page_view/infinity_page_view.dart';

import 'package:argo/src/utils/hive/adapters.dart';
import 'package:argo/src/utils/bodyHeight.dart';
import 'package:argo/src/utils/update.dart';
import 'package:argo/src/utils/handleError.dart';
import 'package:argo/src/utils/account.dart';

import 'package:argo/src/ui/components/Card.dart';
import 'package:argo/src/ui/components/AppPage.dart';
import 'package:argo/src/ui/components/WebContent.dart';
import 'package:argo/src/ui/components/EmptyPage.dart';
import 'package:argo/src/ui/components/ContentHeader.dart';

import 'Agenda.dart';

class Huiswerk extends StatefulWidget {
  @override
  _Huiswerk createState() => _Huiswerk();
}

class _Huiswerk extends State<Huiswerk> with AfterLayoutMixin<Huiswerk>, SingleTickerProviderStateMixin {
  int currentWeek(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  void afterFirstLayout(BuildContext context) => handleError(account().magister.agenda.refresh, "Fout tijdens verversen van huiswerk", context);

  Future<void> _handleError(buildMonday) async => await handleError(() async => account().magister.agenda.getLessen(buildMonday), "Kon huiswerk niet verversen", context);

  int infinityPageCount = 1000;
  int initialPage;
  InfinityPageController pageController;
  DateTime now = DateTime.now();
  DateTime startMonday;
  ValueNotifier<DateTime> lastMonday;
  String weekslug;

  @override
  void initState() {
    initialPage = (infinityPageCount / 2).floor();
    pageController = InfinityPageController(initialPage: initialPage);
    lastMonday = ValueNotifier(now.subtract(Duration(days: now.weekday - 1)));
    startMonday = lastMonday.value;
    lastMonday.addListener(() {
      weekslug = formatDate.format(lastMonday.value);
    });

    super.initState();
  }

  Widget _buildHuiswerkPagina(context, index) {
    DateTime buildMonday = startMonday.add(
      Duration(days: (index - initialPage) * 7),
    );
    String buildSlug = formatDate.format(buildMonday);

    return ValueListenableBuilder(
      valueListenable: updateNotifier,
      builder: (context, _, _a) {
        return Futuristic(
          autoStart: true,
          futureBuilder: () {
            if (account().lessons[buildSlug] == null) {
              return account().magister.agenda.getLessen(buildMonday);
            }

            return Future.value(account().lessons[buildSlug]);
          },
          errorBuilder: (c, error, retry) => RefreshIndicator(
            onRefresh: () async => retry(),
            child: EmptyPage(
              icon: Icons.wifi_off_outlined,
              text: "Geen internet",
            ),
          ),
          busyBuilder: (context) => Container(
            height: bodyHeight(context),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          dataBuilder: (c, _) {
            List<List<Les>> week = account().lessons[buildSlug];
            List<Les> huiswerkLessen = week.expand((x) => x).where((les) => les.huiswerk != null).toList();
            List<Widget> huiswerkWidgets = [];

            if (huiswerkLessen.isEmpty)
              return EmptyPage(
                text: "Geen huiswerk deze week",
                icon: Icons.assignment_outlined,
              );

            String lastDay;
            for (Les les in huiswerkLessen) {
              if (lastDay != les.date) {
                huiswerkWidgets.add(ContentHeader(les.date));
              }
              lastDay = les.date;
              huiswerkWidgets.add(
                MaterialCard(
                  child: ExpansionTile(
                    leading: les.huiswerkAf
                        ? IconButton(
                            onPressed: () {
                              huiswerkAf(les);
                            },
                            icon: Icon(
                              Icons.assignment_turned_in_outlined,
                              color: Colors.green,
                            ),
                          )
                        : IconButton(
                            onPressed: () {
                              huiswerkAf(les);
                            },
                            icon: Icon(
                              Icons.assignment_outlined,
                              color: Colors.grey[400],
                            ),
                          ),
                    title: Text(
                      les.getName(),
                    ),
                    children: [
                      Padding(
                        child: WebContent(
                          les.huiswerk,
                        ),
                        padding: EdgeInsets.only(
                          left: 30,
                          right: 30,
                          bottom: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => _handleError(buildMonday),
              child: ListView(
                children: huiswerkWidgets,
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Huiswerk"),
          ValueListenableBuilder(
            valueListenable: lastMonday,
            builder: (context, date, _a) => Text(
              "Week ${currentWeek(date)}",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[300],
                fontWeight: FontWeight.w400,
              ),
            ),
          )
        ],
      ),
      body: InfinityPageView(
        controller: pageController,
        itemCount: infinityPageCount,
        onPageChanged: (value) {
          lastMonday.value = startMonday.add(
            Duration(days: (value - initialPage) * 7),
          );
        },
        itemBuilder: _buildHuiswerkPagina,
      ),
    );
  }
}
