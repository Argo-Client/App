part of main;

class Instellingen extends StatefulWidget {
  @override
  _Instellingen createState() => _Instellingen();
}

class _Instellingen extends State<Instellingen> {
  void _showColorPicker(Function cb) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Kies een kleur"),
          content: BlockPicker(
            pickerColor: Theme.of(context).primaryColor,
            onColorChanged: (color) {
              setState(() {
                cb(color);
              });
            },
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                "Sluit",
                textScaleFactor: 1.25,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _layoutKey.currentState.openDrawer();
          },
        ),
        title: Text("Instellingen"),
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 15, top: 20),
            child: Text(
              "Uiterlijk",
              style: TextStyle(color: userdata.get("accentColor")),
            ),
          ),
          ListTile(
            // Geen icoontje want dat is lelijk // Je bent zelf lelijk we doen lekker wel icoontje
            trailing: Icon(Icons.brightness_4),
            title: Text("Thema"),
            subtitle: Text(userdata.get("theme").toString().capitalize + " thema"),
            onTap: () {
              return showDialog(
                context: context,
                builder: (BuildContext context) {
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return AlertDialog(
                        title: Text("Selecteer je thema"),
                        actions: [
                          FlatButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Sluit",
                            ),
                          )
                        ],
                        content: SingleChildScrollView(
                          child: Column(
                            children: [
                              RadioListTile(
                                title: Text("Licht"),
                                activeColor: userdata.get('accentColor'),
                                value: "licht",
                                groupValue: userdata.get("theme"),
                                onChanged: (value) {
                                  appState.setState(() {
                                    setState(() {
                                      userdata.put("theme", value);
                                    });
                                  });
                                },
                              ),
                              RadioListTile(
                                title: Text("Donker"),
                                activeColor: userdata.get('accentColor'),
                                value: "donker",
                                groupValue: userdata.get("theme"),
                                onChanged: (value) {
                                  appState.setState(() {
                                    setState(() {
                                      userdata.put("theme", value);
                                    });
                                  });
                                },
                              ),
                              RadioListTile(
                                title: Text("Systeem kleur"),
                                activeColor: userdata.get('accentColor'),
                                value: "systeem",
                                groupValue: userdata.get("theme"),
                                onChanged: (value) {
                                  appState.setState(() {
                                    setState(() {
                                      userdata.put("theme", value);
                                    });
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
          ListTile(
            title: Text('Primaire kleur'),
            subtitle: Text(
              '#${Theme.of(context).primaryColor.value.toRadixString(16).substring(2, 8).toUpperCase()}',
            ),
            onTap: () => _showColorPicker((color) => appState.setState(() {
                  userdata.put("primaryColor", color);
                })),
            trailing: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: userdata.get("primaryColor"),
                border: Border.all(
                  color: Colors.black,
                ),
              ),
            ),
          ),
          ListTile(
            title: Text('Secundaire kleur'),
            subtitle: Text(
              '#${Theme.of(context).accentColor.value.toRadixString(16).substring(2, 8).toUpperCase()}',
            ),
            onTap: () => _showColorPicker((color) => appState.setState(() {
                  userdata.put("accentColor", color);
                })),
            trailing: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: userdata.get("accentColor"),
                border: Border.all(
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.only(left: 15, top: 20),
            child: Text(
              "Agenda",
              style: TextStyle(color: userdata.get("accentColor")),
            ),
          ),
          ListTile(
            title: Text("Aantal pixels per uur"),
            subtitle: Text("Hoe hoog een uur is in de agenda"),
            onTap: () => showDialog(
                context: context,
                builder: (BuildContext context) {
                  return NumberPickerDialog.integer(
                    title: Text("Pixels per uur"),
                    minValue: 50,
                    maxValue: 500,
                    initialIntegerValue: userdata.get("pixelsPerHour"),
                  );
                }).then((value) {
              if (value != null) {
                userdata.put("pixelsPerHour", value);
              }
            }),
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.only(left: 15, top: 20),
            child: Text(
              "Meldingen",
              style: TextStyle(color: userdata.get("accentColor")),
            ),
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.only(left: 15, top: 20),
            child: Text(
              "Overig",
              style: TextStyle(color: userdata.get("accentColor")),
            ),
          ),
          CheckboxListTile(
            title: Text("Zet je foto uit"),
            activeColor: userdata.get("accentColor"),
            subtitle: Text("Voor als die niet zo goed gelukt is."),
            value: userdata.get("useIcon"),
            onChanged: (value) {
              userdata.put("useIcon", value);
              setState(() {});
              appState.setState(() {});
            },
          ),
          CheckboxListTile(
            title: Text("Terugknop"),
            activeColor: userdata.get("accentColor"),
            subtitle: Text("Als je op de terugknop klikt, open dan de drawer."),
            value: userdata.get("backOpensDrawer"),
            onChanged: (value) => setState(
              () {
                userdata.put("backOpensDrawer", value);
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.input),
            title: Text('Open Introductie'),
            onTap: () {
              // Navigator.pushNamed(context, "Introduction");
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => Introduction(),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
