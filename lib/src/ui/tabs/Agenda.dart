import 'package:flutter/material.dart';

import 'package:futuristic/futuristic.dart';
import 'package:infinity_page_view/infinity_page_view.dart';
import 'package:after_layout/after_layout.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:flushbar/flushbar_helper.dart';
import 'package:intl/intl.dart';

import 'package:Argo/main.dart';
import 'package:Argo/src/utils/hive/adapters.dart';
import 'package:Argo/src/ui/CustomWidgets.dart';

final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

class Agenda extends StatefulWidget {
  @override
  _Agenda createState() => _Agenda();
}

Future huiswerkAf(hw) async {
  await account.magister.agenda.toggleHuiswerk(hw);
  hw.huiswerkAf = !hw.huiswerkAf;
  update();
}

class _Agenda extends State<Agenda> with AfterLayoutMixin<Agenda>, TickerProviderStateMixin {
  void afterFirstLayout(BuildContext context) {
    handleError(account.magister.agenda.refresh, "Fout tijdens verversen van agenda", context);
  }

  final int infinityPageCount = 1000;
  int initialPage;

  InfinityPageController infinityPageController;
  InfinityPageController appBarPageController;

  DateTime startDay = DateTime.now();
  DateTime startMonday;

  double _tabBarHeight = 55;
  ValueNotifier<DateTime> currentDay;

  double pixelsFromTop(int minutes, startHour) => ((minutes - startHour * 60) * userdata.get("pixelsPerHour") / 60).toDouble();

  void initVariables() {
    initialPage = (infinityPageCount / 2).floor();
    currentDay = ValueNotifier(startDay);
    infinityPageController = InfinityPageController(
      initialPage: initialPage,
    );
    appBarPageController = InfinityPageController(
      initialPage: initialPage,
    );
    startMonday = currentDay.value.subtract(
      Duration(
        days: currentDay.value.weekday - 1,
      ),
    );

    currentDay.addListener(() {
      int days = currentDay.value.difference(startMonday).inDays;
      jumpOrAnimate(appBarPageController, (days / 7).floor() + initialPage, fast: true);
    });
  }

  @override
  void initState() {
    initVariables();
    super.initState();
  }

  @override
  void dispose() {
    appBarPageController.dispose();
    infinityPageController.dispose();
    super.dispose();
  }

  int relative(int index) => index - initialPage;

  int getStartHour(List<Les> dag) {
    int startHour = userdata.get("agendaStartHour");
    if (dag == null) return startHour;

    List<Les> normalLessons = (dag.where((les) => !les.heleDag)).toList();
    if (normalLessons.isEmpty) return startHour;
    int firstLessonHour = (normalLessons.first.start / 60).floor();
    if (firstLessonHour < startHour) {
      return firstLessonHour;
    }
    return userdata.get("agendaAutoBegin") ? firstLessonHour : startHour;
  }

  int getEndHour(List<Les> dag) {
    int startHour = userdata.get("agendaEndHour");
    if (dag == null) return startHour;
    List<Les> normalLessons = (dag.where((les) => !les.heleDag)).toList();
    if (normalLessons.isEmpty) return startHour;
    int endLessonHour = (normalLessons.last.start / 60).ceil();
    if (endLessonHour > startHour) {
      return endLessonHour;
    }
    return userdata.get("agendaAutoEind") ? endLessonHour : startHour;
  }

  void jumpOrAnimate(InfinityPageController controller, int page, {bool fast}) {
    if ((controller.page - page).abs() > 7) {
      return controller.jumpToPage(page);
    }
    try {
      controller.animateToPage(
        page,
        duration: Duration(
          milliseconds: fast == null ? 600 : 300,
        ),
        curve: Curves.ease,
      );
    } catch (e) {}
  }

  void datePicker() => showDatePicker(
        context: context,
        initialDate: currentDay.value,
        firstDate: DateTime.fromMicrosecondsSinceEpoch(0),
        lastDate: DateTime(DateTime.now().year + 100),
      ).then((value) {
        if (value != null) {
          startDay = value;
          initVariables();
          setState(() {});
        }
      });

  Widget lesCard(Les les, int startHour) {
    List<Absentie> afwezig = account.afwezigheid.where((abs) => abs.les.id == les.id).toList();

    return Container(
      margin: EdgeInsets.only(
        top: pixelsFromTop(les.start, startHour),
      ),
      width: MediaQuery.of(context).size.width - 30,
      height: les.duration * userdata.get("pixelsPerHour") / 60 + 1,
      child: SeeCard(
        border: userdata.get("theme") == "OLED" || les.uitval
            ? null
            : Border.symmetric(
                horizontal: greyBorderSide(),
              ),
        color: les.uitval
            ? theme == Brightness.dark
                ? Color.fromARGB(255, 119, 66, 62)
                : Color.fromARGB(255, 255, 205, 210)
            : null,
        // shape: BorderRadius.all(),
        margin: EdgeInsets.only(
          top: .75,
        ),
        child: InkWell(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 5,
                    left: 5,
                  ),
                  child: Text(
                    les.hour,
                    style: TextStyle(
                      color: theme == Brightness.dark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 5,
                    right: 7.5,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (afwezig.isNotEmpty)
                        Container(
                          margin: les.infoType.isNotEmpty || les.huiswerk != null ? EdgeInsets.only(right: 5) : null,
                          child: Material(
                            color: afwezig.first.geoorloofd ? Colors.green : Colors.red,
                            shape: ContinuousRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(3.0),
                              child: Icon(
                                afwezig.first.geoorloofd ? Icons.check : Icons.error_outlined,
                                color: Colors.white,
                                size: 17,
                              ),
                            ),
                          ),
                        ),
                      if (les.infoType.isNotEmpty)
                        Material(
                          child: Padding(
                            child: Text(
                              les.infoType,
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            padding: EdgeInsets.all(4.5),
                          ),
                          shape: ContinuousRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          color: userdata.get("accentColor"),
                        )
                      else if (les.huiswerk != null)
                        if (!les.huiswerkAf)
                          Icon(
                            Icons.assignment_outlined,
                            size: 23,
                            color: Colors.grey,
                          )
                        else
                          Icon(
                            Icons.assignment_turned_in_outlined,
                            size: 23,
                            color: Colors.green,
                          )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(
                          les.title,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        if (les.onlineLes)
                          Padding(
                            child: Icon(
                              Icons.videocam,
                              color: Colors.grey[400],
                              size: 20,
                            ),
                            padding: EdgeInsets.only(left: 5),
                          ),
                      ],
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            les.information,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              color: theme == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => LesPagina(les),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget dagLessen(List<Les> dag) {
    List<Les> heleDagLessen = dag.where((les) => les.heleDag).toList();

    if (heleDagLessen.isEmpty) {
      return Container();
    }

    return Row(
      children: [
        for (Les les in heleDagLessen)
          Expanded(
            child: Tooltip(
              message: les.title,
              child: SeeCard(
                border: Border(
                  top: userdata.get("theme") != "OLED"
                      ? BorderSide(
                          width: 0,
                        )
                      : greyBorderSide(),
                  right: les == dag.where((les) => les.heleDag).last
                      ? BorderSide(
                          width: 0,
                        )
                      : greyBorderSide(),
                ),
                child: InkWell(
                  child: Padding(
                    // width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(
                      15,
                    ),
                    child: Text(
                      les.title,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => LesPagina(les),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget tijdBalk(startHour) => TimerBuilder.periodic(
        Duration(seconds: 10),
        builder: (c) {
          DateTime now = DateTime.now();
          return Positioned(
            top: ((now.hour - startHour) * 60 + now.minute) * (userdata.get("pixelsPerHour") / 60).toDouble(),
            child: Container(
              height: 0,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: userdata.get('accentColor'),
                  ),
                ),
              ),
            ),
          );
        },
      );

  Widget appbarBottom() => PreferredSize(
        preferredSize: Size.fromHeight(_tabBarHeight),
        child: Container(
          height: _tabBarHeight,
          child: InfinityPageView(
            itemCount: infinityPageCount,
            controller: appBarPageController,
            itemBuilder: (BuildContext context, int index) {
              return ValueListenableBuilder(
                valueListenable: currentDay,
                builder: (c, _, _a) => Stack(
                  children: [
                    Positioned(
                      left: (currentDay.value.weekday - 1) * MediaQuery.of(context).size.width / 7,
                      bottom: 0,
                      child: Container(
                        width: MediaQuery.of(context).size.width / 7,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: userdata.get("accentColor"),
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (int dag = 0; dag < 7; dag++)
                          () {
                            DateTime tabDag = startMonday.add(
                              Duration(days: relative(index) * 7 + dag),
                            );
                            DateFormat numFormatter = DateFormat('dd');
                            return Expanded(
                              child: InkWell(
                                onTap: () {
                                  int page = relative(index) * 7 + dag + initialPage - startDay.weekday + 1;
                                  jumpOrAnimate(infinityPageController, page);
                                },
                                child: Column(
                                  children: (() {
                                    return [
                                      Padding(
                                        child: Text(
                                          ["MA", "DI", "WO", "DO", "VR", "ZA", "ZO"][dag],
                                          overflow: TextOverflow.visible,
                                          softWrap: false,
                                          style: TextStyle(
                                            color: currentDay.value.weekday - 1 != dag ? Colors.grey[300] : Colors.white,
                                          ),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          vertical: 5,
                                        ),
                                      ),
                                      Text(
                                        numFormatter.format(tabDag),
                                        style: TextStyle(
                                          color: currentDay.value.weekday - 1 != dag ? Colors.grey[300] : Colors.white,
                                        ),
                                      ),
                                    ];
                                  })(),
                                ),
                              ),
                            );
                          }()
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: Text("Agenda"),
      actions: [
        IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: datePicker,
        ),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AddLesPagina(
                  currentDay.value,
                ),
              ),
            );
          },
        ),
      ],
      bottom: appbarBottom(),
      body: InfinityPageView(
        itemCount: infinityPageCount,
        onPageChanged: (int index) {
          currentDay.value = startDay.add(
            Duration(
              days: relative(index),
            ),
          );
        },
        controller: infinityPageController,
        itemBuilder: (BuildContext context, int index) {
          DateTime buildDay = startDay.add(
            Duration(
              days: relative(index),
            ),
          );
          DateTime buildWeekMonday = buildDay.subtract(
            Duration(
              days: buildDay.weekday - 1,
            ),
          );
          String buildWeekslug = formatDate.format(buildWeekMonday);
          return RefreshIndicator(
            onRefresh: () async => await handleError(
              () async => account.magister.agenda.getLessen(buildWeekMonday),
              "Kon agenda niet verversen",
              context,
            ),
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: ValueListenableBuilder(
                // Hele Dag lessen
                valueListenable: updateNotifier,
                builder: (context, _, _a) {
                  bool gotLessons = false;
                  List<Les> dag;
                  if (account.lessons[buildWeekslug] != null) {
                    dag = account.lessons[buildWeekslug][buildDay.weekday - 1];
                    gotLessons = true;
                  }

                  int startHour = getStartHour(dag);
                  int endHour = getEndHour(dag);

                  return Column(
                    children: [
                      /// [ Hele Dag lessen ]
                      if (gotLessons) dagLessen(dag),
                      Stack(
                        children: [
                          /// [ Balkje van de tijd nu ]
                          if (formatDate.format(buildDay) == formatDate.format(DateTime.now())) tijdBalk(startHour),

                          /// [ Lijnen op de achtergrond om uren aan te geven ]
                          for (int uur = startHour; uur <= endHour; uur++)
                            Positioned(
                              top: ((uur - startHour) * userdata.get("pixelsPerHour")).toDouble(),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: greyBorderSide(),
                                  ),
                                ),
                              ),
                            ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// [ Balkje aan de zijkant van de uren ]
                              Column(
                                children: [
                                  for (int uur = startHour; uur <= endHour; uur++)
                                    Container(
                                      // Een uur van het balkje
                                      height: userdata.get("pixelsPerHour").toDouble(),
                                      width: 30,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          top: greyBorderSide(),
                                          right: greyBorderSide(),
                                          left: greyBorderSide(),
                                        ),
                                      ),

                                      child: Center(
                                        child: TimerBuilder.periodic(
                                          Duration(seconds: 10),
                                          builder: (c) {
                                            Color color = Color.fromARGB(255, 100, 100, 100);
                                            if (formatDate.format(buildDay) == formatDate.format(DateTime.now())) {
                                              if (uur == DateTime.now().hour) {
                                                color = Colors.white;
                                              }
                                            }
                                            return Text(
                                              uur.toString(),
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: color,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                ],
                              ),

                              /// [Laat een error zien als er geen lessen zijn]
                              if (!gotLessons)
                                Futuristic(
                                  autoStart: true,
                                  futureBuilder: () async => account.magister.agenda.getLessen(buildWeekMonday),
                                  busyBuilder: (c) => Container(
                                    width: MediaQuery.of(context).size.width - 30,
                                    height: bodyHeight(context),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  errorBuilder: (c, dynamic error, retry) {
                                    return Container(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.wifi_off_outlined,
                                            size: 150,
                                            color: Colors.grey[400],
                                          ),
                                          Container(
                                            width: MediaQuery.of(context).size.width / 2,
                                            child: Text(
                                              "Fout tijdens het laden van de dag: \n\n" + error.error,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 17.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      width: MediaQuery.of(context).size.width - 30,
                                      height: bodyHeight(context) - _tabBarHeight,
                                    );
                                  },
                                  onData: (_) => update(),
                                )
                              else

                                /// [Container van alle lessen]
                                Stack(
                                  children: () {
                                    List<Les> lessen = dag.where((les) => pixelsFromTop(les.start, startHour) > 0).toList();
                                    if (lessen.isEmpty) {
                                      return <Widget>[Container()];
                                    }
                                    return <Widget>[for (Les les in lessen) lesCard(les, startHour)];
                                  }(),
                                )
                            ],
                          )
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

// Popup als je op een les klikt
class LesPagina extends StatefulWidget {
  final Les les;
  LesPagina(this.les);
  @override
  _LesPagina createState() => _LesPagina(les);
}

class _LesPagina extends State<LesPagina> with SingleTickerProviderStateMixin {
  Les les;
  _LesPagina(this.les);

  AnimationController _animationController;
  Animation<Color> _fabColor;
  Animation<double> _fabProgress;
  bool isChecked;
  double _maxProgress = 20.0;
  AnimatedIconData icon = AnimatedIcons.add_event;
  ColorTween color = ColorTween(
    begin: userdata.get("primaryColor"),
    end: Colors.green,
  );

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    )..addListener(() {
        setState(() {});
      });

    _fabProgress = Tween<double>(begin: 0.0, end: _maxProgress).animate(
      _animationController,
    );

    _fabColor = color.animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));

    // _animationController.

    if (les.huiswerkAf != null) if (les.huiswerkAf) _animationController.forward();

    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!les.huiswerkAf) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  Widget lesPaginaItem({String title, String subtitle, IconData icon, Widget trailing, Function onTap}) => ListTileBorder(
        subtitle: Text(subtitle),
        border: Border(
          top: greyBorderSide(),
        ),
        leading: Icon(icon),
        title: Text(
          title,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: trailing,
        onTap: onTap,
      );

  Widget page() {
    List<Absentie> afwezig = account.afwezigheid.where((abs) => abs.les.id == les.id).toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          SeeCard(
            column: [
              if (les.hour != null)
                lesPaginaItem(
                  title: (les.hour != "" ? les.hour + "e " : "") + les.startTime + " - " + les.endTime,
                  subtitle: "Tijd",
                  icon: Icons.access_time,
                ),
              if (les.date.isNotEmpty)
                lesPaginaItem(
                  title: les.date,
                  subtitle: "Datum",
                  icon: Icons.event,
                ),
              if (les.title == null || les.title.capitalize != les.vak.naam)
                lesPaginaItem(
                  title: les.vak.naam,
                  subtitle: "Vak",
                  icon: Icons.book,
                ),
              if (les.title.isNotEmpty)
                lesPaginaItem(
                  title: les.title,
                  subtitle: "Les",
                  icon: Icons.title,
                  trailing: les.vak.id == null
                      ? null
                      : IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            TextEditingController con = TextEditingController();
                            Future updateLessons() async {
                              await handleError(() async => account.magister.agenda.getLessen(les.lastMonday), "Kon agenda niet herladen", context, () {
                                setState(update);
                              });
                            }

                            showDialog(
                              context: context,
                              child: AlertDialog(
                                content: Row(children: [
                                  Expanded(
                                    child: TextField(
                                      controller: con,
                                      autofocus: true,
                                      decoration: new InputDecoration(labelText: 'Nieuwe naam', hintText: les.title),
                                    ),
                                  ),
                                ]),
                                actions: <Widget>[
                                  FlatButton(
                                      child: Text('RESET'),
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        custom.delete("vak${les.vak.id}");
                                        await updateLessons();
                                        Navigator.pop(context);
                                      }),
                                  FlatButton(
                                      child: Text('CANCEL'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      }),
                                  FlatButton(
                                    child: Text('SAVE'),
                                    onPressed: () {
                                      if (con.text == "") return;

                                      custom.put("vak${les.vak.id}", con.text);
                                      les.title = con.text;
                                      setState(() {});
                                      updateLessons();
                                      Navigator.pop(context);
                                    },
                                  )
                                ],
                              ),
                            );
                            // print(custom.toMap().toString());
                          }),
                ),
              if (les.location != null && les.location.isNotEmpty)
                lesPaginaItem(
                  title: les.location,
                  subtitle: "Locatie",
                  icon: Icons.location_on,
                ),
              if (les.docenten != null)
                lesPaginaItem(
                  subtitle: "Docent(en)",
                  onTap: les.docenten.length > 5
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ShowPeopleList(
                                les.docenten,
                                title: "Docenten",
                              ),
                            ),
                          );
                        }
                      : null,
                  icon: Icons.person,
                  title: les.docenten.join(", "),
                ),
              if (afwezig.isNotEmpty)
                lesPaginaItem(
                  icon: Icons.check_circle_outline,
                  title: afwezig.first.type,
                  subtitle: "Registraties",
                  trailing: Material(
                    color: afwezig.first.geoorloofd ? Colors.green : Colors.red,
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Icon(
                        afwezig.first.geoorloofd ? Icons.check : Icons.error_outlined,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (les.description.isNotEmpty)
            SeeCard(
              margin: EdgeInsets.only(top: 20),
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (les.description.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: 10,
                          ),
                          child: Text(
                            "Huiswerk",
                            style: TextStyle(
                              fontSize: 23,
                            ),
                          ),
                        ),
                        WebContent(
                          les.description,
                        )
                      ],
                    ),
                ],
              ),
            ),
          if (les.heeftBijlagen)
            SeeCard(
              margin: EdgeInsets.only(top: 20),
              child: Futuristic(
                autoStart: true,
                futureBuilder: () => account.magister.agenda.getBijlagen(les),
                dataBuilder: (context, bijlagen) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: 20,
                        left: 20,
                        bottom: 10,
                      ),
                      child: Text(
                        "Bijlagen",
                        style: TextStyle(
                          fontSize: 23,
                        ),
                      ),
                    ),
                    for (Bron bron in bijlagen)
                      BijlageItem(
                        bron,
                        onTap: () {
                          account.magister.bronnen.downloadFile(bron, (_, _a) {});
                        },
                        border: bijlagen.last != bron
                            ? Border(
                                bottom: greyBorderSide(),
                              )
                            : null,
                      )
                  ],
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.only(bottom: 90),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(les.title),
          actions: !les.editable
              ? null
              : [
                  // IconButton(
                  //   icon: Icon(Icons.edit),
                  //   onPressed: () {
                  //     print("edit");
                  //   },
                  // ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => account.magister.agenda.deleteLes(les).then((e) async {
                      Navigator.of(context).pop();
                      await account.magister.agenda.refresh();
                      update();
                    }).catchError((e) {
                      FlushbarHelper.createError(message: "Les verwijderen mislukt: $e")..show(context);
                      throw (e);
                    }),
                  )
                ],
        ),
        floatingActionButton: les.huiswerk == null
            ? null
            : FloatingActionButton(
                onPressed: () async {
                  animate();
                  await account.magister.agenda.toggleHuiswerk(les);
                  les.huiswerkAf = !les.huiswerkAf;
                  setState(() {});
                  update();
                },
                backgroundColor: _fabColor.value,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.translate(
                      offset: Offset(-_fabProgress.value, 0),
                      child: Icon(
                        Icons.assignment,
                        color: Colors.white,
                        size: _maxProgress - _fabProgress.value,
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(-_fabProgress.value + _maxProgress, 0),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: _fabProgress.value,
                      ),
                    ),
                  ],
                ),
              ),
        body: page(),
      );
}

class AddLesPagina extends StatefulWidget {
  final DateTime date;
  AddLesPagina(this.date);
  @override
  _AddLesPagina createState() => _AddLesPagina(date);
}

class _AddLesPagina extends State<AddLesPagina> {
  DateTime date;
  bool heleDag = false;

  TimeOfDay startTime = TimeOfDay.now(),
      endTime = TimeOfDay.fromDateTime(
        DateTime.now().add(
          Duration(hours: 1),
        ),
      );

  DateFormat formatDate = DateFormat("d-M-y");
  String titel, locatie, inhoud;
  _AddLesPagina(this.date);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nieuwe afspraak"),
      ),
      body: SeeCard(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  ListTileBorder(
                    border: Border(
                      bottom: greyBorderSide(),
                    ),
                    leading: Icon(Icons.title),
                    title: TextFormField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintText: 'Titel',
                      ),
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Veld verplicht';
                        }
                        return null;
                      },
                      onChanged: (value) => titel = value,
                    ),
                  ),
                  ListTileBorder(
                    border: Border(
                      bottom: greyBorderSide(),
                    ),
                    leading: Icon(Icons.location_on),
                    title: TextFormField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintText: 'Locatie',
                      ),
                      // validator: validator,
                      onChanged: (value) => locatie = value,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: greyBorderSide(),
                      ),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          activeColor: userdata.get("accentColor"),
                          title: Text("Hele dag"),
                          value: heleDag,
                          onChanged: (value) => setState(
                            () {
                              heleDag = value;
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            bottom: 10,
                          ),
                          child: Row(
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: 10,
                                    ),
                                    child: RaisedButton(
                                      color: userdata.get("accentColor"),
                                      child: Text("Datum: " + formatDate.format(date)),
                                      onPressed: () async {
                                        DateTime newDate = await showDatePicker(
                                          context: context,
                                          initialDate: date,
                                          firstDate: DateTime.fromMicrosecondsSinceEpoch(0),
                                          lastDate: DateTime(DateTime.now().year + 100),
                                        );

                                        setState(
                                          () {
                                            if (newDate != null) date = newDate;
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  FlatButton(
                                    onPressed: !heleDag
                                        ? () async {
                                            TimeOfDay newStartTime = await showTimePicker(
                                              context: context,
                                              initialTime: startTime,
                                            );
                                            setState(
                                              () {
                                                if (newStartTime != null) startTime = newStartTime;
                                              },
                                            );
                                          }
                                        : null,
                                    child: Text(
                                      "Begin: " + startTime.format(context),
                                    ),
                                  ),

                                  /// [GUUS] renderflex error bij AM PM of klein telefoontje
                                  FlatButton(
                                    onPressed: !heleDag
                                        ? () async {
                                            TimeOfDay newEndTime = await showTimePicker(
                                              context: context,
                                              initialTime: endTime,
                                            );
                                            setState(
                                              () {
                                                if (newEndTime != null) endTime = newEndTime;
                                              },
                                            );
                                          }
                                        : null,
                                    child: Text(
                                      "Eind: " + endTime.format(context),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.subject),
                    title: TextFormField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 20,
                      scrollPadding: EdgeInsets.all(20.0),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintText: 'Inhoud',
                      ),
                      // validator: validator,
                      onChanged: (value) => inhoud = value,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "AddAfspraak",
        onPressed: () async {
          if (startTime.hour * 60 + startTime.minute > endTime.hour * 60 + endTime.minute) {
            FlushbarHelper.createError(message: "Eind tijd kan niet eerder zijn dan start tijd.")..show(context);
            return;
          }
          if (_formKey.currentState.validate()) {
            handleError(
              () async {
                await account.magister.agenda.addAfspraak(
                  {
                    "title": titel,
                    "locatie": locatie,
                    "heledag": heleDag,
                    "inhoud": inhoud,
                    "start": DateTime(
                      date.year,
                      date.month,
                      date.day,
                      startTime.hour,
                      startTime.minute,
                    ),
                    "eind": DateTime(
                      date.year,
                      date.month,
                      date.day,
                      endTime.hour,
                      endTime.minute,
                    ),
                  },
                );
              },
              "Kon afspraak niet opslaan",
              context,
              () async {
                Navigator.of(context).pop();
                FlushbarHelper.createSuccess(message: "$titel is toegevoegd")..show(context);
                await account.magister.agenda.refresh();
                update();
              },
            );
          }
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      resizeToAvoidBottomPadding: true,
    );
  }
}
