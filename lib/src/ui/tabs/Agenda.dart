part of main;

var dayOfWeek = 1;
DateTime date = DateTime.now();
var lastMondayUnformat = date.subtract(Duration(days: date.weekday - dayOfWeek));
DateFormat numFormatter = DateFormat('dd');
DateFormat dayFormatter = DateFormat('E');

final List dayAbbr = ["MA", "DI", "WO", "DO", "VR", "ZA", "ZO"];

class Agenda extends StatefulWidget {
  final int initialPage = 0;
  @override
  _Agenda createState() => _Agenda();
}

final timeFactor = 5 / 3;

class _Agenda extends State<Agenda> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    double timeMinutes = (((DateTime.now().hour - 8) * 60 + DateTime.now().minute) * timeFactor).toDouble();
    if (timeMinutes.isNegative) {
      timeMinutes = 0;
    }
    final List<List> widgetRooster = [];
    List _rooster = [
      [
        {
          "start": 690,
          "hourFrom": "2",
          "hourTo": "2",
          "startTime": "11:30",
          "endTime": "12:30",
          "duration": 60,
          "title": "EnTL - DKR - A5v3",
          "location": "a103",
        },
        {
          "start": 630,
          "hourFrom": "1",
          "hourTo": "1",
          "startTime": "10:30",
          "endTime": "11:30",
          "duration": 60,
          "title": "Men - BTN - a5vmen1",
          "location": "a103",
        },
      ],
      [
        {
          "hourFrom": "1",
          "hourTo": "1",
          "title": "DuTL - LUA - a5vdutl1",
          "startTime": "09:30",
          "endTime": "10:30",
          "start": 570,
          "duration": 60,
          "location": "a103",
        },
      ],
      [],
      [],
      [],
      [],
      [],
    ];

    for (var dag in _rooster) {
      List<Widget> widgetDag = [];
      if (dag.isEmpty) {
        widgetDag.add(
          Container(),
        );
        widgetRooster.add(widgetDag);
        continue;
      }
      for (var les in dag) {
        var lesUur = les['hourTo'] == les['hourFrom'] ? les['hourFrom'] : '${les['hourFrom']} - ${les['hourTo']}';
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
                          lesUur,
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
                              Padding(
                                padding: EdgeInsets.only(
                                  top: 5,
                                ),
                                child: Text(
                                  les["location"] + " • " + les["startTime"] + " - " + les["endTime"],
                                  style: TextStyle(
                                    color: userdata.get('darkMode') ? Colors.grey.shade400 : Colors.grey.shade600,
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
                onTap: () {},
              ),
            ),
            height: les["duration"] * timeFactor - 1,
          ),
        );
      }
      widgetRooster.add(widgetDag);
    }
    return DefaultTabController(
      // The number of tabs / content sections to display.
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
                  ),
                  text: numFormatter.format(
                    date.add(
                      Duration(days: i - 1),
                    ),
                  ),
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
                              for (int i = 8; i <= 23; i++)
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
                                      i.toString(),
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: i == DateTime.now().hour ? Colors.white : Colors.grey,
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
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          // child: ClipOval(
                          //   child: Container(
                          //     height: 10,
                          //     width: 10,
                          //   ),
                          // ),
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
