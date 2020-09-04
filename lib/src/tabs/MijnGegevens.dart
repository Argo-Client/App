part of main;

class MijnGegevens extends StatefulWidget {
  @override
  _MijnGegevens createState() => _MijnGegevens();
}

class _MijnGegevens extends State<MijnGegevens> {
  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Center(
        child: new RefreshIndicator(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    children: <Widget>[
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor:
                                  Theme.of(context).backgroundColor,
                              child: Icon(Icons.person, size: 60),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Sam Taen",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          Text(
                            "5v3",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Divider(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 13, top: 10),
                      child: Text(
                        "School info",
                        style: TextStyle(
                          color: Colors.orange,
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        "N. Bot",
                      ),
                      subtitle: Text(
                        "Mentor(en)",
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Divider(),
                    ),
                    ListTile(
                      title: Text(
                        "616068",
                      ),
                      subtitle: Text(
                        "Stamnummer",
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Divider(),
                    ),
                    ListTile(
                      title: Text(
                        "NG",
                      ),
                      subtitle: Text(
                        "Profiel",
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Divider(),
                    ),
                    ListTile(
                      title: Text(
                        "A VWO 5e leerjaar",
                      ),
                      subtitle: Text(
                        "Studie",
                      ),
                    ),
                    Divider(),
                    Padding(
                      padding: EdgeInsets.only(left: 13, top: 10),
                      child: Text(
                        "Persoonlijk info",
                        style: TextStyle(
                          color: Colors.orange,
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        "Samuel David Taen",
                      ),
                      subtitle: Text(
                        "Officiële naam",
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Divider(),
                    ),
                    ListTile(
                      title: Text(
                        "26 juli 2004",
                      ),
                      subtitle: Text(
                        "Geboortedatum",
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Divider(),
                    ),
                    ListTile(
                      title: Text(
                        "-",
                      ),
                      subtitle: Text(
                        "Mobiele nummer",
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Divider(),
                    ),
                    ListTile(
                      title: Text(
                        "Broekemalaan 20\n6703 GM, Wageningen",
                      ),
                      subtitle: Text(
                        "Adres",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          onRefresh: _refresh,
        ),
      ),
    );
  }
}

Future<void> _refresh() async {
  print('refreshing...');
}
