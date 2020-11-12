part of main;

class Instellingen extends StatefulWidget {
  @override
  _Instellingen createState() => _Instellingen();
}

class _Instellingen extends State<Instellingen> {
  void _showColorPicker(pick) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Kies een kleur"),
          content: BlockPicker(
            pickerColor: userdata.get(pick),
            onColorChanged: (color) {
              appState.setState(() {
                userdata.put(pick, color);
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
          ContentHeader("Uiterlijk"),
          SeeCard(
            column: [
              ListTileBorder(
                border: Border(
                  bottom: greyBorderSide(),
                ),
                // Geen icoontje want dat is lelijk // Je bent zelf lelijk we doen lekker wel icoontje // Dankuwel meneer
                trailing: Icon(Icons.brightness_4_outlined),
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
                                    title: Text("OLED"),
                                    activeColor: userdata.get('accentColor'),
                                    value: "OLED",
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
                                      appState.setState(
                                        () {
                                          setState(
                                            () {
                                              userdata.put("theme", value);
                                            },
                                          );
                                        },
                                      );
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
              ListTileBorder(
                border: Border(
                  bottom: greyBorderSide(),
                ),
                title: Text('Primaire kleur'),
                subtitle: Text(
                  '#${Theme.of(context).primaryColor.value.toRadixString(16).substring(2, 8).toUpperCase()}',
                ),
                onTap: () => _showColorPicker("primaryColor"),
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
              ListTileBorder(
                border: Border(
                  bottom: greyBorderSide(),
                ),
                title: Text('Secundaire kleur'),
                subtitle: Text(
                  '#${Theme.of(context).accentColor.value.toRadixString(16).substring(2, 8).toUpperCase()}',
                ),
                onTap: () => _showColorPicker("accentColor"),
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
            ],
          ),
          SeeCard(
            child: CheckboxListTile(
              title: Text(
                "Kleurtjes in de drawer",
              ),
              subtitle: Text(
                "Maak je drawer wat vrolijker.",
              ),
              activeColor: userdata.get("accentColor"),
              value: userdata.get("colorsInDrawer"),
              onChanged: (value) => appState.setState(() {
                setState(() {
                  userdata.put("colorsInDrawer", value);
                });
              }),
            ),
          ),

          ContentHeader("Agenda"),

          SeeCard(
            column: [
              ListTileBorder(
                border: Border(
                  bottom: greyBorderSide(),
                ),
                title: Text("Aantal pixels per uur"),
                subtitle: Text("Hoe hoog een uur is in de agenda."),
                trailing: Text("${userdata.get("pixelsPerHour")}"),
                onTap: () => showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return NumberPickerDialog.integer(
                      title: Text("Pixels per uur"),
                      minValue: 50,
                      maxValue: 500,
                      initialIntegerValue: userdata.get("pixelsPerHour"),
                    );
                  },
                ).then((value) {
                  if (value != null)
                    setState(() {
                      userdata.put("pixelsPerHour", value);
                    });
                }),
              ),
              ListTileBorder(
                border: Border(
                  bottom: greyBorderSide(),
                ),
                title: Text("Standaard starttijd."),
                subtitle: Text("Hoelaat je agenda moet beginnen."),
                trailing: Text("${userdata.get("agendaStartHour")}"),
                onTap: () => showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return NumberPickerDialog.integer(
                      title: Text("Agenda starttijd"),
                      minValue: 0,
                      maxValue: userdata.get("agendaEndHour"),
                      initialIntegerValue: userdata.get("agendaStartHour"),
                    );
                  },
                ).then((value) {
                  if (value != null)
                    setState(() {
                      userdata.put("agendaStartHour", value);
                    });
                }),
              ),
              ListTileBorder(
                border: Border(
                  bottom: greyBorderSide(),
                ),
                title: Text("Standaard eindtijd."),
                subtitle: Text("Hoelaat je agenda moet eindigen."),
                trailing: Text("${userdata.get("agendaEndHour")}"),
                onTap: () => showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return NumberPickerDialog.integer(
                      title: Text("Agenda eindtijd"),
                      minValue: userdata.get("agendaStartHour"),
                      maxValue: 23,
                      initialIntegerValue: userdata.get("agendaEndHour"),
                    );
                  },
                ).then((value) {
                  if (value != null)
                    setState(() {
                      userdata.put("agendaEndHour", value);
                    });
                }),
              ),
              Container(
                child: CheckboxListTile(
                  title: Text("Niet automatisch begin uur"),
                  subtitle: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 5,
                    ),
                    child: Text("Of je agenda wilt laten startten wanneer je eerste les begint of je start tijd."),
                  ),
                  activeColor: userdata.get("accentColor"),
                  value: userdata.get("agendaAutoBegin"),
                  onChanged: (value) => setState(
                    () {
                      userdata.put("agendaAutoBegin", value);
                    },
                  ),
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: greyBorderSide(),
                  ),
                ),
              ),
              CheckboxListTile(
                title: Text("Niet automatisch eind uur"),
                subtitle: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 5,
                  ),
                  child: Text("Of je door wilt kunnen scrollen tot je eindtijd of bij je laatste les al stopt."),
                ),
                activeColor: userdata.get("accentColor"),
                value: userdata.get("agendaAutoEind"),
                onChanged: (value) => setState(
                  () {
                    userdata.put("agendaAutoEind", value);
                  },
                ),
              ),
            ],
            margin: EdgeInsets.zero,
          ),
          // Padding(
          //   padding: EdgeInsets.only(
          //     left: 10,
          //     top: 10,
          //     bottom: 10,
          //   ),
          //   child: Text(
          //     "Meldingen",
          //     style: TextStyle(color: userdata.get("accentColor")),
          //   ),
          // ),
          //SeeCard(
          //   child: Column(
          //     children: [],
          //   ),
          //   margin: EdgeInsets.zero,
          // ),
          ContentHeader("Overig"),

          SeeCard(
            column: [
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: greyBorderSide(),
                  ),
                ),
                child: CheckboxListTile(
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
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: greyBorderSide(),
                  ),
                ),
                child: CheckboxListTile(
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
              ),
              ListTile(
                leading: Icon(Icons.input_outlined),
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
              ),
              if (custom.length != 0)
                ListTile(
                  title: Text("Verwijder alle zelfbedachte namen."),
                  leading: Icon(Icons.delete),
                  onTap: () => setState(() {
                    custom.clear();
                    handleError(account.magister.agenda.refresh, "Kon agenda niet herladen", context);
                  }),
                )
            ],
          ),
        ],
      ),
    );
  }
}
