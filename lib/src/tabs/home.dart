part of main;

bool openedIntroduction = false;

class _Home extends State<Home> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    Agenda(),
    // Huiswerk(),
    // Afwezigheid(),
    Cijfers(),
    // Berichten(),
  ];

  void changeIndex(int index) {
    setState(() {
      _currentIndex = index;
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    void runIntroduction() async {
      openedIntroduction = true;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool _seen = (prefs.getBool('seen') ?? false);
      if (!_seen) {
        Introduction();
      }
    }

    if (!openedIntroduction) {
      runIntroduction();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('My Flutter App'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text("Guus van Meerveld"),
              accountEmail: Text("616258"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Theme.of(context).backgroundColor,
                child: Icon(Icons.person, size: 50),
              ),
            ),
            ListTile(
              leading: Icon(Icons.event),
              title: Text('Agenda'),
              onTap: () {
                changeIndex(0);
              },
            ),
            ListTile(
              leading: Icon(Icons.assignment),
              title: Text('Huiswerk'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.check_circle),
              title: Text('Afwezigheid'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
                leading: Icon(Icons.looks_6),
                title: Text('Cijfers'),
                onTap: () {
                  changeIndex(1);
                }),
            ListTile(
              leading: Icon(Icons.email),
              title: Text('Berichten'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ExpansionTile(
              leading: Icon(Icons.folder),
              title: Text("ELO"),
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.work),
                  title: Text('Studiewijzer'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.assignment_turned_in),
                  title: Text('Opdrachten'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.description),
                  title: Text('Leermiddelen'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.folder_shared),
                  title: Text('Bronnen'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Mijn gegevens'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Instellingen'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.input),
              title: Text('Open Introductie'),
              onTap: () {
                // Navigator.push(Introduction());
              },
            )
          ],
        ),
      ),
      body: _children[_currentIndex],
    );
  }
}

// Scaffold(
//         drawer: DefaultDrawer(),
//         appBar: AppBar(
//           title: GestureDetector(
//               onTap: () {},
//               child: Row(
//                 children: [
//                   Text('Agenda'),
//                   Icon(
//                     Icons.arrow_drop_down,
//                     size: 26.0,
//                   ),
//                 ],
//               )),
//           actions: [
//             Padding(
//                 padding: EdgeInsets.only(right: 20.0),
//                 child: GestureDetector(
//                   onTap: () {},
//                   child: Icon(
//                     Icons.add,
//                     size: 26.0,
//                   ),
//                 )),
//           ],
//         ),
//         body: Center(
//           child: Text('Hier komt de agenda'),
//         ),
// ),
