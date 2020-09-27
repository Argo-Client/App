part of main;

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
          PopupMenuButton(
            onSelected: (result) {
              if (result == "instellingen") {}
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              const PopupMenuItem(
                value: "herlaad",
                child: Text('Herlaad'),
              ),
              const PopupMenuItem(
                value: "indeling",
                child: Text('Verander indeling'),
              ),
              const PopupMenuDivider(
                height: 15,
              ),
              const PopupMenuItem(
                value: "instellingen",
                child: Text('Instellingen'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (!account.lessons[DateTime.now().weekday - 1].isEmpty)
              Card(
                margin: EdgeInsets.only(
                  bottom: 20,
                ),
                child: Container(
                  width: double.maxFinite,
                  child: Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                            bottom: 20,
                          ),
                          child: Text(
                            "Vandaag",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            for (var les in account.lessons[DateTime.now().weekday - 1])
                              Container(
                                height: 75,
                                decoration: BoxDecoration(
                                  color: les["uitval"] ? (theme == Brightness.dark ? Color.fromARGB(255, 119, 66, 62) : Color.fromARGB(255, 255, 205, 210)) : Colors.transparent,
                                  border: Border(
                                    top: GreyBorderSide,
                                  ),
                                ),
                                child: ListTile(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => LesPagina(les),
                                      ),
                                    );
                                  },
                                  title: Text(les["title"]),
                                  leading: Container(
                                    height: 23,
                                    width: 23,
                                    decoration: les["hour"] == ""
                                        ? null
                                        : BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: userdata.get("accentColor"),
                                          ),
                                    padding: EdgeInsets.only(
                                      top: 4,
                                      left: 7.5,
                                    ),
                                    margin: EdgeInsets.only(
                                      top: 11,
                                      left: 10,
                                    ),
                                    child: Text(
                                      les["hour"],
                                    ),
                                  ),
                                  subtitle: Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          les["information"],
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: theme == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  trailing: les["description"].isEmpty
                                      ? null
                                      : Icon(
                                          Icons.assignment,
                                          color: Colors.grey,
                                        ),
                                ),
                              ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            Card(
              margin: EdgeInsets.only(
                bottom: 20,
              ),
              child: Container(
                width: double.maxFinite,
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
                              leading: Text("TP1"),
                              title: Text("7,5"),
                              subtitle: Text("Nederlands"),
                              trailing: Text("26-06-2020"),
                            ),
                            ListTile(
                              title: Text(
                                "5,7",
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
              ),
            ),
            if (account.berichten.isNotEmpty)
              Card(
                margin: EdgeInsets.only(
                  bottom: 20,
                ),
                child: Container(
                  width: double.maxFinite,
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
                ),
              ),
          ],
        ),
      ),
    );
  }
}
