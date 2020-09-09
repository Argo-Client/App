part of main;

var dayOfWeek = 1;
DateTime date = DateTime.now();
var lastMondayUnformat = date.subtract(Duration(days: date.weekday - dayOfWeek));
DateFormat numFormatter = DateFormat('dd');
DateFormat dayFormatter = DateFormat('E');

final List dayAbbr = ["Ma", "Di", "Wo", "Do", "Vr", "Za", "Zo"];

class Agenda extends StatefulWidget {
  final int initialPage = 0;
  @override
  _Agenda createState() => _Agenda();
}

class _Agenda extends State<Agenda> with SingleTickerProviderStateMixin {
  final timeFactor = 5 / 3;
  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetRooster = [];
    List _rooster = [
      {
        "duration": 90,
      },
      {
        "title": "yeet",
        "duration": 75,
      },
      {
        "title": "hi",
        "duration": 60,
      },
    ];

    for (var les in _rooster) {
      if (les["title"] == null) {
        widgetRooster.add(
          Container(
            margin: null,
            width: MediaQuery.of(context).size.width - 30,
            height: les["duration"] * timeFactor,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: .75,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        );
      } else {
        widgetRooster.add(
          Container(
            width: MediaQuery.of(context).size.width - 30,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(20),
              ),
            ),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: .75,
                  color: Colors.grey,
                ),
              ),
            ),
            height: les["duration"] * timeFactor,
          ),
        );
      }
    }

    @override
    Widget build(BuildContext context) {
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
                  onRefresh: () async {},
                  child: SingleChildScrollView(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            for (int i = 8; i <= 17; i++)
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
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Column(
                          children: widgetRooster,
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
}
