import 'package:flutter/material.dart';

import 'package:after_layout/after_layout.dart';
import 'package:intl/intl.dart';
import 'package:futuristic/futuristic.dart';
import 'package:infinity_page_view/infinity_page_view.dart';

import 'package:Argo/main.dart';
import 'package:Argo/src/utils/hive/adapters.dart';
import 'package:Argo/src/ui/CustomWidgets.dart';

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

  void afterFirstLayout(BuildContext context) => handleError(account.magister.agenda.refresh, "Fout tijdens verversen van huiswerk", context);

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
        itemBuilder: (context, index) {
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
                  if (account.lessons[buildSlug] == null) {
                    return account.magister.agenda.getLessen(buildMonday);
                  }
                  return Future.value(account.lessons[buildSlug]);
                },
                errorBuilder: (c, dynamic error, retry) => Container(
                  height: bodyHeight(context),
                  child: Center(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: 25,
                          ),
                          child: Icon(
                            Icons.wifi_off_outlined,
                            size: 150,
                            color: Colors.grey[400],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 2,
                          child: Text(
                            "Fout tijdens het laden van huiswerk: \n\n" + error.error,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 17.5,
                            ),
                          ),
                        ),
                        RaisedButton(
                          onPressed: retry,
                          child: Text("Probeer Opnieuw"),
                        ),
                      ],
                    ),
                  ),
                ),
                busyBuilder: (context) => Container(
                  height: bodyHeight(context),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                dataBuilder: (c, week) {
                  List<Les> huiswerkLessen = week.expand((List<Les> x) => x).where((les) => les.huiswerk != null).toList().cast<Les>();
                  List<Widget> huiswerk = [];
                  if (huiswerkLessen.isEmpty) {
                    return Container(
                      height: bodyHeight(context),
                      child: Center(
                        child: Text("Geen Huiswerk deze week."),
                      ),
                    );
                  }
                  String lastDay;
                  int i = 0;
                  for (Les les in huiswerkLessen) {
                    if (lastDay != les.date) {
                      huiswerk.add(ContentHeader(les.date));
                    }
                    lastDay = les.date;
                    huiswerk.add(
                      SeeCard(
                        border: huiswerkLessen.last == les || huiswerkLessen[++i].date != lastDay
                            ? null
                            : Border(
                                bottom: greyBorderSide(),
                              ),
                        child: Column(
                          children: [
                            ListTile(
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
                                les.title,
                              ),
                            ),
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

                  return Container(
                    decoration: BoxDecoration(
                      border: Border.symmetric(
                        horizontal: greyBorderSide(),
                      ),
                    ),
                    child: buildLiveList(huiswerk, 4),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
