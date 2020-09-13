part of main;

class Agenda extends StatefulWidget {
  final int initialPage = 0;
  @override
  _Agenda createState() => _Agenda();
}

DateFormat numFormatter = DateFormat('dd');
final List dayAbbr = ["MA", "DI", "WO", "DO", "VR", "ZA", "ZO"];
final timeFactor = 5 / 3;

class _Agenda extends State<Agenda> {
  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime lastMonday = now.subtract(Duration(days: now.weekday - 1));

    double timeMinutes = (((DateTime.now().hour - 8) * 60 + DateTime.now().minute) * timeFactor).toDouble();
    if (timeMinutes.isNegative) {
      timeMinutes = 0;
    }

    List<List> widgetRooster = [];

    for (List dag in account.lessons) {
      List<Widget> widgetDag = [];
      if (dag.isEmpty) {
        widgetDag.add(
          Container(),
        );
        widgetRooster.add(widgetDag);
        continue;
      }

      for (Map les in dag) {
        widgetDag.add(
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 0.75,
                  color: Colors.grey,
                ),
              ),
            ),
            margin: EdgeInsets.only(
              top: ((les["start"] - 480) * timeFactor).toDouble(),
            ),
            width: MediaQuery.of(context).size.width - 30,
            child: Card(
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
                            color: userdata.get('darkMode') ? Colors.grey.shade400 : Colors.grey.shade600,
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
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    top: 5,
                                  ),
                                  child: Text(
                                    les["location"] + les["startTime"] + " - " + les["endTime"] + (les["description"].length != 0 ? " • " + les["description"] : ""),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: TextStyle(
                                      color: userdata.get('darkMode') ? Colors.grey.shade400 : Colors.grey.shade600,
                                    ),
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
            height: les["duration"] * timeFactor - 1,
          ),
        );
      }
      widgetRooster.add(widgetDag);
    }
    return DefaultTabController(
      length: 7,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              _layoutKey.currentState.openDrawer();
            },
          ),
          title: Text("Agenda"),
          bottom: TabBar(
            tabs: <Widget>[
              for (int i = 0; i < 7; i++)
                Tab(
                  icon: Text(
                    dayAbbr[i],
                    textAlign: TextAlign.left,
                  ),
                  text: numFormatter.format(lastMonday.add(Duration(days: i))),
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
            for (int i = 0; i < 7; i++)
              RefreshIndicator(
                onRefresh: () async {
                  await account.magister.agenda.refresh();
                  setState(() {});
                },
                child: SingleChildScrollView(
                  child: Stack(
                    children: [
                      Stack(
                        children: [
                          for (int i = 8; i <= 23; i++)
                            Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                margin: EdgeInsets.only(
                                  top: ((i - 8) * 100).toDouble(),
                                ),
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey,
                                      width: .75,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              for (int j = 8; j <= 23; j++)
                                Container(
                                  height: 100,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        width: .75,
                                        color: Colors.grey,
                                      ),
                                      right: BorderSide(
                                        width: .75,
                                        color: Colors.grey,
                                      ),
                                      left: BorderSide(
                                        width: .75,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      j.toString(),
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: j == DateTime.now().hour && i + 1 == DateTime.now().weekday ? Colors.white : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Stack(
                            children: widgetRooster[i],
                          ),
                        ],
                      ),
                      if (i + 1 == DateTime.now().weekday)
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            margin: EdgeInsets.only(
                              top: timeMinutes,
                            ),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: userdata.get('accentColor'),
                                  width: .75,
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
                    title: Text(les["hour"] + "e " + les["startTime"] + " - " + les["endTime"]),
                  ),
                  ListTile(
                    leading: Icon(Icons.event),
                    title: Text(les["date"]),
                  ),
                  ListTile(
                    leading: Icon(Icons.book),
                    title: Text(les["vak"]),
                  ),
                  ListTile(
                    leading: Icon(Icons.location_on),
                    title: Text(les["location"]),
                  ),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text(les["docent"]),
                  ),
                  if (les["description"].length != 0)
                    ListTile(
                      leading: Icon(Icons.edit),
                      title: Text("Bewerkt op " + les["bewerkt"]),
                    ),
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
