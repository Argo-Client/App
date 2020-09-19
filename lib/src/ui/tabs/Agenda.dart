part of main;

class Agenda extends StatefulWidget {
  final int initialPage = 0;
  @override
  _Agenda createState() => _Agenda();
}

const BorderSide GreyBorderSide = BorderSide(color: Colors.grey, width: .75);

class _Agenda extends State<Agenda> {
  DateTime now, lastMonday;
  DateFormat numFormatter, dayFormatter;
  List dayAbbr;
  double timeFactor;
  int endHour, defaultStartHour, pixelsPerHour;
  int getStartHour(dag) {
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
            top: (les["start"] - startHour * 60) * timeFactor,
            child: Container(
              width: MediaQuery.of(context).size.width - 30,
              height: les["duration"] * timeFactor - 1,
              decoration: BoxDecoration(
                border: Border(
                  bottom: GreyBorderSide,
                ),
              ),
              child: Card(
                color: les["uitval"] ? Color.fromARGB(255, 119, 66, 62) : null,
                shape: Border.all(width: 0),
                margin: EdgeInsets.zero,
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
                                    (les["location"] != null ? les["location"] + " • " : "") + les["startTime"] + " - " + les["endTime"] + (les["description"].length != 0 ? " • " + les["description"] : ""),
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
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => _layoutKey.currentState.openDrawer(),
          ),
          title: Text("Agenda"),
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
              onPressed: () {},
            ),
          ],
        ),
        body: TabBarView(
          children: [
            for (int dag = 0; dag < 7; dag++) // 1 Tabje van de week
              RefreshIndicator(
                onRefresh: () async {
                  await account.magister.agenda.refresh();
                  setState(() {});
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
                                        color: uur == DateTime.now().hour && dag + 1 == DateTime.now().weekday ? Colors.white : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          // Container van alle lessen
                          Container(
                            width: MediaQuery.of(context).size.width - 30,
                            height: MediaQuery.of(context).size.height,
                            child: Stack(
                              children: widgetRooster[dag],
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
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              margin: EdgeInsets.only(
                bottom: 10,
                top: 0,
                left: 0,
                right: 0,
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.access_time),
                    title: Text((les["hour"] != "" ? les["hour"] + "e " : "") + les["startTime"] + " - " + les["endTime"]),
                  ),
                  ListTile(
                    leading: Icon(Icons.event),
                    title: Text(les["date"]),
                  ),
                  ListTile(
                    leading: Icon(Icons.book),
                    title: Text(les["vak"]),
                  ),
                  if (les["location"] != "")
                    ListTile(
                      leading: Icon(Icons.location_on),
                      title: Text(les["location"]),
                    ),
                  if (les["docent"] != "")
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
