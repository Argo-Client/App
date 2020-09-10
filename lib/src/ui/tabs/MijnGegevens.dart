part of main;

class MijnGegevens extends StatefulWidget {
  @override
  _MijnGegevens createState() => _MijnGegevens();
}

class _MijnGegevens extends State<MijnGegevens> {
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
        title: Text("Mijn Gegevens"),
      ),
      body: RefreshIndicator(
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
                            child: Icon(userdata.get("userIcon"), size: 60),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.fullName,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        Text(
                          account.klasCode,
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
                        color: userdata.get("accentColor"),
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Mentor(en)",
                    ),
                    subtitle: Text(
                      account.mentor,
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
                      account.username,
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
                      account.profiel,
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
                      account.klas,
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.only(left: 13, top: 10),
                    child: Text(
                      "Persoonlijk info",
                      style: TextStyle(
                        color: userdata.get("accentColor"),
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Officiële naam",
                    ),
                    subtitle: Text(
                      account.officialFullName,
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
                      account.birthdate,
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
                      account.phone,
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
                      account.email,
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
                      account.address,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        onRefresh: () async {
          await Magister().refreshProfileInfo();
          appState.setState(() {});
        },
      ),
    );
  }
}
