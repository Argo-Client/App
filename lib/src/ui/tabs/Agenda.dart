part of main;

final GlobalKey<ScaffoldState> _agendaKey = new GlobalKey<ScaffoldState>();
final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

class Agenda extends StatefulWidget {
  @override
  _Agenda createState() => _Agenda();
}

BorderSide greyBorderSide() {
  return BorderSide(color: theme == Brightness.dark ? Color.fromARGB(255, 100, 100, 100) : Color.fromARGB(255, 205, 205, 205), width: 1);
}

Future huiswerkAf(hw) async {
  await account.magister.agenda.toggleHuiswerk(hw);
  hw.huiswerkAf = !hw.huiswerkAf;
  update();
}

class _Agenda extends State<Agenda> with AfterLayoutMixin<Agenda>, SingleTickerProviderStateMixin {
  DateTime now, lastMonday;
  DateFormat numFormatter, dayFormatter;
  List dayAbbr;
  double timeFactor;
  String weekslug;
  int endHour, defaultStartHour, pixelsPerHour, currentDay;
  int getStartHour(dag) {
    if (account.lessons[weekslug] == null) return 0;
    return account.lessons[weekslug][dag].isEmpty ? defaultStartHour : (account.lessons[weekslug][dag].first.start / 60).floor();
  }

  void afterFirstLayout(BuildContext context) {
    handleError(account.magister.agenda.refresh, "Fout tijdens verversen van agenda", context);
  }

  _Agenda() {
    now = DateTime.now();
    lastMonday = now.subtract(
      Duration(
        days: now.weekday - 1,
      ),
    );
    numFormatter = DateFormat('dd');
    dayFormatter = DateFormat('E');
    weekslug = formatDate.format(lastMonday);
    dayAbbr = ["MA", "DI", "WO", "DO", "VR", "ZA", "ZO"];
    timeFactor = userdata.get("pixelsPerHour") / 60;
    endHour = 23;
    defaultStartHour = 8;
    currentDay = now.weekday - 1;
  }

  Future openDatePicker() async {
    DateTime pickDate = await showDatePicker(
      context: context,
      initialDate: lastMonday.add(
        Duration(
          days: currentDay,
        ),
      ),
      firstDate: DateTime.fromMicrosecondsSinceEpoch(0),
      lastDate: DateTime(DateTime.now().year + 100),
    );

    if (pickDate == null) return;
    weekslug = formatDate.format(pickDate.subtract(Duration(days: pickDate.weekday - 1)));
    lastMonday = DateTime.parse(weekslug);

    if (!account.lessons.containsKey(weekslug)) {
      handleError(() async => account.magister.agenda.getLessen(lastMonday), "Kon gekozen week niet laden", context, account.save);
      account.save();
    }

    setState(() {
      currentDay = pickDate.weekday - 1;
      _tabController.index = pickDate.weekday - 1;
    });
  }

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      vsync: this,
      length: 7,
      initialIndex: currentDay,
    )..addListener(
        () {
          setState(
            () {
              currentDay = _tabController.index;
            },
          );
        },
      );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _agendaKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () => _layoutKey.currentState.openDrawer(),
        ),
        title: GestureDetector(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Agenda",
              ),
              Text(
                formatDatum.format(
                  lastMonday.add(
                    Duration(
                      days: currentDay,
                    ),
                  ),
                ),
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[300],
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          onTap: openDatePicker,
        ),
        bottom: TabBar(
          controller: _tabController,
          // Dag kiezer bovenaan
          tabs: <Widget>[
            for (int dag = 0; dag < 7; dag++)
              Tab(
                icon: Text(
                  dayAbbr[dag],
                  overflow: TextOverflow.visible,
                  softWrap: false,
                ),
                text: numFormatter.format(lastMonday.add(Duration(days: dag))),
              )
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today_outlined),
            onPressed: openDatePicker,
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddLesPagina(
                    lastMonday.add(
                      Duration(
                        days: currentDay,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        child: TabBarView(
          controller: _tabController,
          children: [
            for (int dag = 0; dag < 7; dag++) // 1 Tabje van de week
              RefreshIndicator(
                onRefresh: () async {
                  await handleError(() async => account.magister.agenda.getLessen(lastMonday), "Kon agenda niet verversen", context);
                },
                child: SingleChildScrollView(
                  child: ValueListenableBuilder(
                    valueListenable: updateNotifier,
                    builder: (BuildContext context, _, Widget child) {
                      List<List> widgetRooster = [];
                      for (List dag in account.lessons[weekslug] ?? []) {
                        List<Widget> widgetDag = [];

                        if (dag.isEmpty) {
                          widgetDag.add(Container());
                          widgetRooster.add(widgetDag);
                          continue;
                        }
                        int startHour = (dag.first.start / 60).floor();

                        for (Les les in dag) {
                          widgetDag.add(
                            Container(
                              margin: EdgeInsets.only(
                                top: ((les.start - startHour * 60) * timeFactor).toDouble(),
                              ),
                              width: MediaQuery.of(context).size.width - 30,
                              height: les.duration * timeFactor,
                              child: Container(
                                child: SeeCard(
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
                                                color: theme == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                              top: 5,
                                              right: 5,
                                            ),
                                            child: les.huiswerk != null
                                                ? !les.huiswerkAf
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
                                        ),
                                        // Align(
                                        //   alignment: Alignment.bottomRight,
                                        //   child: Padding(
                                        //     padding: EdgeInsets.only(
                                        //       top: 5,
                                        //       right: 5,
                                        //     ),
                                        //     child: les["huiswerk"] != null
                                        //         ? !les["huiswerkAf"]
                                        //             ? Icon(
                                        //                 Icons.assignment,
                                        //                 size: 23,
                                        //                 color: Colors.grey,
                                        //               )
                                        //             : Icon(
                                        //                 Icons.check,
                                        //                 size: 23,
                                        //                 color: Colors.greenAccent,
                                        //               )
                                        //         : null,
                                        //   ),
                                        // ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 20, left: 20),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    les.title,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                    ),
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
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: greyBorderSide(),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        widgetRooster.add(widgetDag);
                      }
                      return Stack(
                        children: [
                          if (dag + 1 == now.weekday) // Balkje van de tijd nu
                            StatefulBuilder(builder: (BuildContext context, StateSetter rebuildMinute) {
                              Future.delayed(const Duration(seconds: 10), () {
                                try {
                                  rebuildMinute(() {});
                                } catch (e) {}
                              });
                              return Positioned(
                                top: (((now.hour - getStartHour(dag)) * 60 + now.minute) * timeFactor).toDouble(),
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
                            }),
                          for (int uur = getStartHour(dag); uur <= endHour; uur++) // Lijnen op de achtergrond om uren aan te geven
                            Positioned(
                              top: ((uur - getStartHour(dag)) * userdata.get("pixelsPerHour")).toDouble(),
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
                              Column(
                                // Balkje aan de zijkant van de uren
                                children: [
                                  for (int uur = getStartHour(dag); uur <= endHour; uur++)
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
                                        child: Text(
                                          uur.toString(),
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: uur == now.hour && dag + 1 == now.weekday ? Colors.white : Color.fromARGB(255, 100, 100, 100),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              // Container van alle lessen

                              widgetRooster.isEmpty
                                  ? Container()
                                  : Stack(
                                      children: widgetRooster[dag],
                                    ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
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

class _LesPagina extends State<LesPagina> {
  Les les;
  _LesPagina(this.les);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                await account.magister.agenda.toggleHuiswerk(les);
                les.huiswerkAf = !les.huiswerkAf;
                setState(() {});
                update();
              },
              backgroundColor: les.huiswerkAf ? Colors.green : userdata.get("accentColor"),
              child: Icon(les.huiswerkAf ? Icons.check : Icons.refresh),
            ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SeeCard(
              margin: EdgeInsets.only(
                bottom: 20,
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.access_time),
                    title: Text(
                      (les.hour != "" ? les.hour + "e " : "") + les.startTime + " - " + les.endTime,
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.event),
                    title: Text(les.date),
                  ),
                  if (les.title == null || les.title.capitalize != les.vak.naam)
                    ListTile(
                      leading: Icon(Icons.book),
                      title: Text(les.vak.naam),
                    ),
                  ListTile(
                    leading: Icon(Icons.title),
                    title: Text(les.title),
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
                                        })
                                  ],
                                ),
                              );
                              // print(custom.toMap().toString());
                            }),
                  ),
                  if (les.location != null)
                    ListTile(
                      leading: Icon(Icons.location_on),
                      title: Text(les.location),
                    ),
                  if (les.docent != null)
                    ListTile(
                      leading: Icon(Icons.person),
                      title: Text(les.docent),
                    ),
                  // if (les["description"].length != 0)
                  //   ListTile(
                  //     leading: Icon(Icons.edit),
                  //     title: Text("Bewerkt op " + les["bewerkt"]),
                  //   ),
                ],
              ),
            ),
            if (les.description.length != 0)
              Container(
                child: SeeCard(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 30,
                      left: 20,
                      right: 20,
                      bottom: 20,
                    ),
                    child: Column(
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
                        Html(
                          data: les.description,
                          onLinkTap: launch,
                        ),
                      ],
                    ),
                  ),
                ),
                width: MediaQuery.of(context).size.width,
              ),
          ],
        ),
      ),
    );
  }
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
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: greyBorderSide(),
                      ),
                    ),
                    child: ListTile(
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
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: greyBorderSide(),
                      ),
                    ),
                    child: ListTile(
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
                          onChanged: (value) => setState(() {
                            heleDag = value;
                          }),
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
