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
  hw["huiswerkAf"] = !hw["huiswerkAf"];
  update();
}

class _Agenda extends State<Agenda> {
  DateTime now, lastMonday;
  DateFormat numFormatter, dayFormatter;
  List dayAbbr;
  double timeFactor;
  int endHour, defaultStartHour, pixelsPerHour;
  int getStartHour(dag) {
    if (account.lessons.isEmpty) return 0;
    return account.lessons[dag].isEmpty ? defaultStartHour : (account.lessons[dag].first["start"] / 60).floor();
  }

  _Agenda() {
    now = DateTime.now();
    lastMonday = now.subtract(Duration(days: now.weekday - 1));
    numFormatter = DateFormat('dd');
    dayFormatter = DateFormat('E');

    dayAbbr = ["MA", "DI", "WO", "DO", "VR", "ZA", "ZO"];
    timeFactor = userdata.get("pixelsPerHour") / 60;
    endHour = 23;
    defaultStartHour = 8;
    if (account.id != 0) {
      account.magister.agenda.refresh().then((_) {
        setState(() {});
      }).catchError((e) {
        FlushbarHelper.createError(message: "Fout tijdens verversen van agenda:\n$e")..show(context);
        throw (e);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: DateTime.now().weekday - 1,
      length: 7,
      child: Scaffold(
        key: _agendaKey,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => _layoutKey.currentState.openDrawer(),
          ),
          title: InkWell(
            /// [Guus, maak even dat het hoger is alsjeblieft dankjewel]
            /// [NEE]
            // Agenda knopje voor maand view
            onTap: () {},
            child: Row(
              children: [
                Text("Agenda"),
                Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
          bottom: TabBar(
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
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddLesPagina(),
                  ),
                );
              },
            ),
          ],
        ),
        body: Container(
          child: TabBarView(
            children: [
              for (int dag = 0; dag < 7; dag++) // 1 Tabje van de week
                RefreshIndicator(
                  onRefresh: () async {
                    account.magister.agenda.refresh().then((_) {
                      setState(() {});
                    }).catchError((e) {
                      FlushbarHelper.createError(message: "Kon agenda niet verversen:\n$e")..show(context);
                    });
                  },
                  child: SingleChildScrollView(
                    child: ValueListenableBuilder(
                      valueListenable: updateNotifier,
                      builder: (BuildContext context, _, Widget child) {
                        List<List> widgetRooster = [];

                        for (List dag in account.lessons) {
                          List<Widget> widgetDag = [];

                          if (dag.isEmpty) {
                            widgetDag.add(Container());
                            widgetRooster.add(widgetDag);
                            continue;
                          }
                          int startHour = (dag.first["start"] / 60).floor();

                          for (Map les in dag) {
                            widgetDag.add(
                              Container(
                                margin: EdgeInsets.only(
                                  top: ((les["start"] - startHour * 60) * timeFactor).toDouble(),
                                ),
                                width: MediaQuery.of(context).size.width - 30,
                                height: les["duration"] * timeFactor,
                                child: Card(
                                  color: les["uitval"] ? theme == Brightness.dark ? Color.fromARGB(255, 119, 66, 62) : Color.fromARGB(255, 255, 205, 210) : null,
                                  // shape: BorderRadius.all(),
                                  margin: EdgeInsets.only(
                                    top: .75,
                                  ),
                                  shape: Border(bottom: greyBorderSide()),
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
                                              les["hour"],
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
                                            child: les["huiswerk"] != null
                                                ? !les["huiswerkAf"]
                                                    ? Icon(
                                                        Icons.assignment,
                                                        size: 23,
                                                        color: Colors.grey,
                                                      )
                                                    : Icon(
                                                        Icons.check,
                                                        size: 23,
                                                        color: Colors.greenAccent,
                                                      )
                                                : null,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 20, left: 20),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    les["title"],
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
                                                      les["information"],
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
                              ),
                            );
                          }
                          widgetRooster.add(widgetDag);
                        }
                        return Stack(
                          children: [
                            if (dag + 1 == DateTime.now().weekday) // Balkje van de tijd nu
                              Positioned(
                                top: (((DateTime.now().hour - getStartHour(dag)) * 60 + DateTime.now().minute) * timeFactor).toDouble(),
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
                              ),
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
                                              color: uur == DateTime.now().hour && dag + 1 == DateTime.now().weekday ? Colors.white : Color.fromARGB(255, 100, 100, 100),
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
      ),
    );
  }
}

// Popup als je op een les klikt
class LesPagina extends StatefulWidget {
  final Map les;
  LesPagina(this.les);
  @override
  _LesPagina createState() => _LesPagina(les);
}

class _LesPagina extends State<LesPagina> {
  Map les;
  _LesPagina(this.les);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(les["title"]),
        actions: !les["editable"]
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
      floatingActionButton: les["huiswerk"] == null
          ? null
          : FloatingActionButton(
              onPressed: () async {
                await account.magister.agenda.toggleHuiswerk(les);
                les["huiswerkAf"] = !les["huiswerkAf"];
                setState(() {});
                update();
              },
              backgroundColor: les["huiswerkAf"] ? Colors.green : userdata.get("accentColor"),
              child: Icon(les["huiswerkAf"] ? Icons.check : Icons.refresh),
            ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              margin: EdgeInsets.only(
                bottom: 20,
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.access_time),
                    title: Text(
                      (les["hour"] != "" ? les["hour"] + "e " : "") + les["startTime"] + " - " + les["endTime"],
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.event),
                    title: Text(les["date"]),
                  ),
                  if (les["vak"] != null)
                    ListTile(
                      leading: Icon(Icons.book),
                      title: Text(les["vak"]),
                    ),
                  if (les["location"] != null)
                    ListTile(
                      leading: Icon(Icons.location_on),
                      title: Text(les["location"]),
                    ),
                  if (les["docent"] != null)
                    ListTile(
                      leading: Icon(Icons.person),
                      title: Text(les["docent"]),
                    ),
                  // if (les["description"].length != 0)
                  //   ListTile(
                  //     leading: Icon(Icons.edit),
                  //     title: Text("Bewerkt op " + les["bewerkt"]),
                  //   ),
                ],
              ),
            ),
            if (les["description"].length != 0)
              Container(
                child: Card(
                  margin: EdgeInsets.zero,
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
                          data: les["description"],
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
  @override
  _AddLesPagina createState() => _AddLesPagina();
}

class _AddLesPagina extends State<AddLesPagina> {
  bool heleDag = false;
  TimeOfDay startTime = TimeOfDay.now();
  TimeOfDay endTime = TimeOfDay.fromDateTime(
    DateTime.now().add(
      Duration(hours: 1),
    ),
  );
  DateTime date = DateTime.now();
  DateFormat formatDate = DateFormat("d-M-y");
  String titel;
  String locatie;
  String inhoud;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nieuwe afspraak"),
      ),
      body: Card(
        margin: EdgeInsets.zero,
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
                                          initialDate: DateTime.now(),
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
          if (_formKey.currentState.validate()) {
            account.magister.agenda.addAfspraak({
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
            }).then((added) async {
              Navigator.of(context).pop();
              FlushbarHelper.createSuccess(message: "$titel is toegevoegd")..show(context);
              await account.magister.agenda.refresh();
              update();
            }).catchError((e) {
              FlushbarHelper.createError(message: "Kon afspraak niet opslaan:\n$e");
              throw (e);
            });
          }
        },
        child: Icon(
          Icons.send,
          color: Colors.white,
        ),
      ),
      resizeToAvoidBottomPadding: true,
    );
  }
}
