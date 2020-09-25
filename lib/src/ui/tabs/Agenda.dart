part of main;

final GlobalKey<ScaffoldState> _agendaKey = new GlobalKey<ScaffoldState>();

class Agenda extends StatefulWidget {
  static _Agenda of(BuildContext context) => context.findAncestorStateOfType<_Agenda>();

  final int initialPage = 0;
  @override
  _Agenda createState() => _Agenda();
}

const BorderSide GreyBorderSide = BorderSide(color: Color.fromARGB(255, 100, 100, 100), width: .75);

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
  }
  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime lastMonday = now.subtract(Duration(days: now.weekday - 1));

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
          Positioned(
            height: les["duration"] * timeFactor - 1,
            top: (les["start"] - startHour * 60) * timeFactor,
            left: 0,
            right: 0,
            child: Container(
              width: MediaQuery.of(context).size.width - 30,
              height: les["duration"] * timeFactor,
              child: Card(
                color: les["uitval"] ? theme == Brightness.dark ? Color.fromARGB(255, 119, 66, 62) : Color.fromARGB(255, 255, 205, 210) : null,
                // shape: BorderRadius.all(),
                margin: EdgeInsets.only(
                  top: .75,
                ),
                shape: Border(bottom: GreyBorderSide),
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
                                    maxLines: 2,
                                    style: TextStyle(
                                      color: theme == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
                                    ),
                                  ),
                                )
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
          ),
        );
      }
      widgetRooster.add(widgetDag);
    }
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
                    textAlign: TextAlign.left,
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
                    child: Stack(
                      children: [
                        for (int uur = getStartHour(dag); uur <= endHour; uur++) // Lijnen op de achtergrond om uren aan te geven
                          Positioned(
                            top: ((uur - getStartHour(dag)) * userdata.get("pixelsPerHour")).toDouble(),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: GreyBorderSide,
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
                                        top: GreyBorderSide,
                                        right: GreyBorderSide,
                                        left: GreyBorderSide,
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
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: double.maxFinite,
                                maxWidth: MediaQuery.of(context).size.width - 30,
                              ),
                              child: Stack(
                                children: widgetRooster.isEmpty ? [] : widgetRooster[dag],
                              ),
                            ),
                          ],
                        ),
                        if (dag + 1 == DateTime.now().weekday) // Balkje van de tijd nu
                          Positioned(
                            top: (((DateTime.now().hour - getStartHour(dag)) * 60 + DateTime.now().minute) * timeFactor).toDouble(),
                            child: Container(
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
                      ],
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
class LesPagina extends StatelessWidget {
  final Map les;
  const LesPagina(this.les);

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
                    if (e == true) {
                      Navigator.of(context).pop();
                      await account.magister.agenda.refresh();
                      Agenda.of(_agendaKey.currentContext).setState(() {});
                    } else {
                      FlushbarHelper.createError(message: "Les verwijderen mislukt: $e");
                    }
                  }),
                )
              ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              margin: EdgeInsets.only(
                bottom: 20,
                top: 0,
                left: 0,
                right: 0,
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
  static GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  bool heleDag = false;
  @override
  Widget build(BuildContext context) {
    String titel;
    String locatie;
    String inhoud;
    String validator(String value) {
      if (value.isEmpty) {
        return 'Please enter some text';
      }
      return null;
    }

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
                        bottom: GreyBorderSide,
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
                        validator: validator,
                        onChanged: (value) => titel = value,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: GreyBorderSide,
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
                        validator: validator,
                        onChanged: (value) => locatie = value,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: GreyBorderSide,
                      ),
                    ),
                    child: SwitchListTile(
                      activeColor: userdata.get("accentColor"),
                      title: Text("Hele dag?"),
                      value: heleDag,
                      onChanged: (value) => setState(() {
                        heleDag = value;
                      }),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.description),
                    title: TextFormField(
                      maxLines: 10,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintText: 'Inhoud',
                      ),
                      validator: validator,
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
              "start": DateTime.now(),
              "eind": DateTime.now().add(Duration(minutes: 60)),
            }).then((added) async {
              Navigator.of(context).pop();
              FlushbarHelper.createSuccess(message: "$titel is toegevoegd")..show(context);
              await account.magister.agenda.refresh();
              Agenda.of(_agendaKey.currentContext).setState(() {});
            }).catchError((e) {
              print(e);
              FlushbarHelper.createError(message: "Kon afspraak niet opslaan:\n$e");
            });
          }
        },
        child: Icon(
          Icons.send,
          color: Colors.white,
        ),
      ),
    );
  }
}
