part of main;

enum HomeMenu { herlaad, indeling, instellingen }

class Thuis extends StatefulWidget {
  @override
  _Thuis createState() => _Thuis();
}

class _Thuis extends State<Thuis> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _layoutKey.currentState.openDrawer();
          },
        ),
        title: Text("Home"),
        actions: [
          PopupMenuButton<HomeMenu>(
            onSelected: (HomeMenu result) {
              switch (result) {
                case HomeMenu.instellingen:
                  // Navigator.push(context, Instellingen());
                  break;
                default:
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<HomeMenu>>[
              const PopupMenuItem<HomeMenu>(
                value: HomeMenu.herlaad,
                child: Text('Herlaad'),
              ),
              const PopupMenuItem<HomeMenu>(
                value: HomeMenu.indeling,
                child: Text('Verander indeling'),
              ),
              const PopupMenuDivider(
                height: 15,
              ),
              const PopupMenuItem<HomeMenu>(
                value: HomeMenu.instellingen,
                child: Text('Instellingen'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              width: double.maxFinite,
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        "Vandaag",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      // InkWell(
                      //   child: Stack(
                      //     children: [
                      //       Align(
                      //         alignment: Alignment.topLeft,
                      //         child: Padding(
                      //           padding: EdgeInsets.only(
                      //             top: 5,
                      //             left: 5,
                      //           ),
                      //           child: Text(
                      //             lesUur,
                      //             style: TextStyle(
                      //               color: userdata.get('darkMode') ? Colors.grey.shade400 : Colors.grey.shade600,
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //       Padding(
                      //         padding: EdgeInsets.only(top: 20, left: 20),
                      //         child: Column(
                      //           children: [
                      //             Row(
                      //               children: [
                      //                 Text(
                      //                   les["title"],
                      //                   style: TextStyle(
                      //                     fontSize: 16,
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //             Row(
                      //               children: [
                      //                 Padding(
                      //                   padding: EdgeInsets.only(
                      //                     top: 5,
                      //                   ),
                      //                   child: Text(
                      //                     les["location"] + " • " + les["startTime"] + " - " + les["endTime"],
                      //                     style: TextStyle(
                      //                       color: userdata.get('darkMode') ? Colors.grey.shade400 : Colors.grey.shade600,
                      //                     ),
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      //   onTap: () {},
                      // ),
                    ],
                  ),
                ),
                elevation: 10,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              width: double.maxFinite,
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        "Recente cijfers",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      Container(
                        height: 200,
                        child: ListView(
                          children: [
                            ListTile(
                              title: Text("7,5"),
                              subtitle: Text("Nederlands"),
                              trailing: Text("26-06-2020"),
                            ),
                            ListTile(
                              title: Text(
                                "3,4",
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                              trailing: Text("26-06-2020"),
                              subtitle: Text("Wiskunde"),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                elevation: 10,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              width: double.maxFinite,
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        "Berichten",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                elevation: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
