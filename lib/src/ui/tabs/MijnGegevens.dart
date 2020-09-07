part of main;

class MijnGegevens extends StatefulWidget {
  @override
  _MijnGegevens createState() => _MijnGegevens();
}

class _MijnGegevens extends State<MijnGegevens> {
  Box user = Hive.box("magisterData");
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
                              backgroundColor: Theme.of(context).backgroundColor,
                              child: Icon(Icons.person, size: 60),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            user.get("fullName", defaultValue: "Laden..."),
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          Text(
                            user.get("klasCode", defaultValue: "Laden..."),
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
                        user.get("mentor", defaultValue: "Laden..."),
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
                        user.get("username", defaultValue: "Laden..."),
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
                        user.get("profiel", defaultValue: "Laden..."),
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
                        user.get("klas", defaultValue: "Laden..."),
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
                        user.get("officialFullName", defaultValue: "Laden..."),
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
                        user.get("birthdate", defaultValue: "Laden..."),
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
                        user.get("phone", defaultValue: "Laden..."),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Divider(),
                    ),
                    ListTile(
                      title: Text(
                        "Email Adres",
                      ),
                      subtitle: Text(
                        user.get("email", defaultValue: "Laden..."),
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
                        user.get("address", defaultValue: "Laden..."),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          onRefresh: () async {
            await Magister().refresh();
            setState(() {});
          },
        ),
      ),
    );
  }
}
