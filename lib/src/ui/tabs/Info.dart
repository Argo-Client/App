part of main;

class Info extends StatefulWidget {
  @override
  _Info createState() => _Info();
}

class _Info extends State<Info> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              _layoutKey.currentState.openDrawer();
            },
          ),
          bottom: TabBar(
            tabs: [
              Tab(
                text: "Over",
              ),
              Tab(
                text: "Credits",
              ),
            ],
          ),
          title: Text("Info"),
        ),
        body: TabBarView(
          children: [
            ListView(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: 15,
                    top: 20,
                    bottom: 15,
                  ),
                  child: Text(
                    "Algemeen",
                    style: TextStyle(
                      color: userdata.get("accentColor"),
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.verified_user_outlined),
                  title: Text('Versie'),
                  subtitle: Text('0.1'),
                ),
                ListTile(
                  leading: Icon(Icons.device_hub_outlined),
                  title: Text('Github'),
                  subtitle: Text("Source code"),
                  onTap: () => launch("https://argo-magister.net/github/"),
                ),
                ListTile(
                  leading: Icon(Icons.chat_outlined),
                  title: Text('Discord'),
                  subtitle: Text("Gezelligheid"),
                  onTap: () => launch("https://argo-magister.net/discord/"),
                ),
                ListTile(
                  leading: Icon(Icons.feedback_outlined),
                  title: Text('Feedback'),
                  subtitle: Text("Klik hier als je feedback wil geven over deze app"),
                  onTap: () => {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        bool checked = false;
                        return AlertDialog(
                          title: Text("Schrijf je feedback"),
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  decoration: InputDecoration(labelText: 'Feedback'),
                                  maxLines: 1,
                                ),
                                CheckboxListTile(
                                  activeColor: userdata.get('accentColor'),
                                  title: Text('Anoniem'),
                                  value: checked,
                                  onChanged: (bool value) {
                                    setState(() {
                                      checked = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            FlatButton(
                              child: new Text("Sluit"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.send_outlined),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 15,
                    top: 20,
                    bottom: 15,
                  ),
                  child: Text(
                    "Tools",
                    style: TextStyle(
                      color: userdata.get("accentColor"),
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.android_outlined),
                  title: Text('Flutter'),
                  subtitle: Text("Platform gebruikt om de app te maken"),
                  onTap: () => launch("https://flutter.dev/"),
                ),
              ],
            ),
            ListView(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: 15,
                    top: 20,
                    bottom: 15,
                  ),
                  child: Text(
                    "Makers",
                    style: TextStyle(
                      color: userdata.get("accentColor"),
                    ),
                  ),
                ),
                ExpansionTile(
                  leading: Icon(Icons.person_outlined),
                  title: Text('Guus van Meerveld'),
                  subtitle: Text('Bijdrage: UI'),
                  children: [
                    ListTile(
                      leading: Icon(Icons.public_outlined),
                      title: Text("Website"),
                      onTap: () {
                        launch("https://g-vm.nl");
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.device_hub_outlined),
                      title: Text("Github"),
                      onTap: () {
                        launch("https://github.com/guusvanmeerveld");
                      },
                    ),
                  ],
                ),
                ExpansionTile(
                  leading: Icon(Icons.person_outlined),
                  title: Text('Sam Taen'),
                  subtitle: Text('Bijdrage: Backend'),
                  children: [
                    ListTile(
                      leading: Icon(Icons.public_outlined),
                      title: Text("Website"),
                      onTap: () {
                        launch("https://samtaen.nl");
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.device_hub_outlined),
                      title: Text("Github"),
                      onTap: () {
                        launch("https://github.com/netfloex");
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 15,
                    top: 20,
                    bottom: 15,
                  ),
                  child: Text(
                    "Support",
                    style: TextStyle(
                      color: userdata.get("accentColor"),
                    ),
                  ),
                ),
                ExpansionTile(
                  leading: Icon(Icons.person_outlined),
                  title: Text('Martijn Oosterhuis'),
                  subtitle: Text('Bijdrage: Emotionele support'),
                  children: [
                    ListTile(
                      leading: Icon(Icons.public_outlined),
                      title: Text("Website"),
                      onTap: () {
                        launch("https://mb-o.nl");
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.device_hub_outlined),
                      title: Text("Github"),
                      onTap: () {
                        launch("https://github.com/devostex");
                      },
                    ),
                  ],
                ),
                ExpansionTile(
                  leading: Icon(Icons.person_outlined),
                  title: Text('Sjoerd Bolten'),
                  subtitle: Text('Bijdrage: Alles'),
                  children: [
                    ListTile(
                      leading: Icon(Icons.public_outlined),
                      title: Text("Website"),
                      onTap: () {
                        launch("https://netlob.dev");
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.device_hub_outlined),
                      title: Text("Github"),
                      onTap: () {
                        launch("https://github.com/netlob");
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
