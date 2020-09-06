part of main;

class MijnGegevens extends StatefulWidget {
  @override
  _MijnGegevens createState() => _MijnGegevens();
}

class _MijnGegevens extends State<MijnGegevens> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: RefreshIndicator(
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
                        "Mentor(en)",
                      ),
                      subtitle: Text(
                        "V. Mentor",
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Divider(),
                    ),
                    ListTile(
                      title: Text(
                        "Stamnummer",
                      ),
                      subtitle: Text(
                        "123456",
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Divider(),
                    ),
                    ListTile(
                      title: Text(
                        "Profiel",
                      ),
                      subtitle: Text(
                        "NG",
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Divider(),
                    ),
                    ListTile(
                      title: Text(
                        "Studie",
                      ),
                      subtitle: Text(
                        "A GYMNASIUM 6e leerjaar",
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
                        "Officiële naam",
                      ),
                      subtitle: Text(
                        "Zeer Officiële Naam",
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Divider(),
                    ),
                    ListTile(
                      title: Text(
                        "Geboortedatum",
                      ),
                      subtitle: Text(
                        "1 jan 1970",
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Divider(),
                    ),
                    ListTile(
                      title: Text(
                        "Mobiele nummer",
                      ),
                      subtitle: Text(
                        "-",
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Divider(),
                    ),
                    ListTile(
                      title: Text(
                        "Adres",
                      ),
                      subtitle: Text(
                        "1234 AB Amsterdam",
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
