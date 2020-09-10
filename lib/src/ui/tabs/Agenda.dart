part of main;

var dayOfWeek = 1;
DateTime date = DateTime.now();
var lastMondayUnformat =
    date.subtract(Duration(days: date.weekday - dayOfWeek));
DateFormat numFormatter = DateFormat('dd');
DateFormat dayFormatter = DateFormat('E');

final List dayAbbr = ["Ma", "Di", "Wo", "Do", "Vr", "Za", "Zo"];

class Agenda extends StatefulWidget {
  final int initialPage = 0;
  @override
  _Agenda createState() => _Agenda();
}

final timeFactor = 5 / 3;

class _Agenda extends State<Agenda> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    double timeMinutes =
        (((DateTime.now().hour - 8) * 60 + DateTime.now().minute) * timeFactor)
            .toDouble();
    if (timeMinutes.isNegative) {
      timeMinutes = 0;
    }
    final List<List> widgetRooster = [];
    List _rooster = [
      [
        {
          "start": 550,
          "title": "yeet",
          "duration": 60,
        },
        {
          "start": 610,
          "title": "hi",
          "duration": 60,
        },
      ],
      [
        {
          "start": 600,
          "duration": 50,
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
      for (var les in dag) {
        widgetDag.add(
          Container(
            margin: EdgeInsets.only(
              top: ((les["start"] - 480) * timeFactor).toDouble(),
            ),
            width: MediaQuery.of(context).size.width - 30,
            child: Card(
              margin: null,
              child: InkWell(
                child: Padding(
                  padding: EdgeInsets.all(20),
                ),
                onTap: () {},
              ),
            ),
            height: les["duration"] * timeFactor,
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
                                        color: i == DateTime.now().hour
                                            ? Colors.white
                                            : Colors.grey,
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
                                color: Color(userdata.get('accentColor')),
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
