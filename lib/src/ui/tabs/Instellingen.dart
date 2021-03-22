import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:Argo/main.dart';
import 'package:Argo/src/ui/CustomWidgets.dart';

class Instellingen extends StatefulWidget {
  @override
  _Instellingen createState() => _Instellingen();
}

class InstellingenCategory extends StatelessWidget {
  final String category;
  final Widget Function(BuildContext, void Function(void Function())) builder;
  final IconData icon;

  InstellingenCategory({this.category, this.icon, this.builder});

  Widget build(BuildContext context) {
    return SeeCard(
      child: ListTileBorder(
        border: Border(
          top: greyBorderSide(),
        ),
        title: Text(category),
        leading: Icon(icon),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => InstellingPagina(category, builder),
            ),
          );
        },
      ),
    );
  }
}

class SwitchInstelling extends StatelessWidget {
  final String title;
  final String setting;
  final String subtitle;
  final Function onChange;
  final bool disabled;

  SwitchInstelling({this.title, this.setting, this.subtitle, this.onChange, this.disabled});

  Widget build(BuildContext context) {
    return SeeCard(
      border: Border(
        top: greyBorderSide(),
      ),
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return SwitchListTile(
            subtitle: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                subtitle,
                maxLines: 1,
              ),
            ),
            value: userdata.get(setting),
            activeColor: userdata.get("accentColor"),
            onChanged: disabled ?? false // sam grote dom
                ? null
                : (value) {
                    if (onChange != null) onChange();
                    setState(() {
                      userdata.put(setting, value);
                    });
                  },
            title: Text(title),
          );
        },
      ),
    );
  }
}

class CustomInstelling extends StatelessWidget {
  final String title;
  final String subtitle;
  final Function onTap;
  final Widget trailing;

  CustomInstelling({this.title, this.onTap, this.trailing, this.subtitle});

  Widget build(BuildContext context) {
    return SeeCard(
      border: Border(
        top: greyBorderSide(),
      ),
      child: ListTile(
        title: Text(title),
        onTap: onTap,
        trailing: trailing,
        subtitle: subtitle != null
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  subtitle,
                  maxLines: 1,
                ),
              )
            : null,
      ),
    );
  }
}

class InstellingPagina extends StatelessWidget {
  final String instelling;
  final Widget Function(BuildContext, void Function(void Function())) page;

  InstellingPagina(this.instelling, this.page);

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(instelling),
        ),
        body: StatefulBuilder(
          builder: page,
        ));
  }
}

class _Instellingen extends State<Instellingen> {
  Future showThemeMenu(setState) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
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
  }

  Future showColorPicker(pick) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Kies een kleur"),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            BlockPicker(
              pickerColor: userdata.get(pick),
              onColorChanged: (color) {
                appState.setState(() {
                  userdata.put(pick, color);
                });
              },
            ),
          ]),
          actions: <Widget>[
            FlatButton(
              child: Text(
                "Sluit",
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

  Future showColorAdvanced(pick) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Kies een kleur"),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            ColorPicker(
              enableAlpha: false,
              pickerColor: userdata.get(pick),
              onColorChanged: (color) {
                appState.setState(() {
                  userdata.put(pick, color);
                });
              },
            ),
          ]),
          actions: <Widget>[
            FlatButton(
              child: Text(
                "Sluit",
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
    return AppPage(
      title: Text("Instellingen"),
      body: ListView(
        children: [
          InstellingenCategory(
            icon: Icons.format_paint_outlined,
            category: "Uiterlijk",
            builder: (BuildContext context, StateSetter setState) {
              return ListView(
                children: [
                  CustomInstelling(
                    title: "Thema",
                    onTap: () {
                      showThemeMenu(setState);
                    },
                    trailing: Icon(Icons.brightness_2_outlined),
                    subtitle: userdata.get("theme").toString().capitalize + " thema",
                  ),
                  CustomInstelling(
                    title: 'Primaire kleur',
                    onTap: () => showColorPicker("primaryColor"),
                    subtitle: '#${Theme.of(context).primaryColor.value.toRadixString(16).substring(2, 8).toUpperCase()}',
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
                  CustomInstelling(
                    title: 'Secundaire kleur',
                    onTap: () => showColorPicker("accentColor"),
                    subtitle: '#${Theme.of(context).accentColor.value.toRadixString(16).substring(2, 8).toUpperCase()}',
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
                  SwitchInstelling(
                    title: "Icoon kleuren in sidebar",
                    subtitle: "Voeg kleur toe aan de icoontjes in de sidebar",
                    setting: "colorsInDrawer",
                    onChange: () => appState.setState(() {}),
                  )
                ],
              );
            },
          ),
          InstellingenCategory(
            icon: Icons.calendar_today_outlined,
            category: "Agenda",
            builder: (BuildContext context, StateSetter setState) {
              return ListView(
                children: [
                  CustomInstelling(
                    title: "Hoogte van één uur",
                    subtitle: "Hoe hoog een uur (in pixels) moet zijn",
                    trailing: CircleShape(
                      child: Text("${userdata.get("pixelsPerHour")}"),
                    ),
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
                    ).then(
                      (value) {
                        if (value != null)
                          setState(
                            () {
                              userdata.put("pixelsPerHour", value);
                            },
                          );
                      },
                    ),
                  ),
                  CustomInstelling(
                    subtitle: "Hoelaat je lesuren beginnen",
                    title: "Start tijd",
                    trailing: CircleShape(
                      child: Text("${userdata.get("agendaStartHour")}"),
                    ),
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
                    ).then(
                      (value) {
                        if (value != null)
                          setState(
                            () {
                              userdata.put("agendaStartHour", value);
                            },
                          );
                      },
                    ),
                  ),
                  CustomInstelling(
                    title: "Eind tijd",
                    subtitle: "Hoelaat je lesuren eindigen",
                    trailing: CircleShape(
                      child: Text("${userdata.get("agendaEndHour")}"),
                    ),
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
                    ).then(
                      (value) {
                        if (value != null)
                          setState(() {
                            userdata.put("agendaEndHour", value);
                          });
                      },
                    ),
                  ),
                  SwitchInstelling(
                    title: "Automatisch begin uur",
                    subtitle: "Laat Argo je start tijd berekenen",
                    setting: "agendaAutoBegin",
                  ),
                  SwitchInstelling(
                    title: "Automatisch eind uur",
                    subtitle: "Laat Argo je eind tijd berekenen",
                    setting: "agendaAutoEind",
                  )
                ],
              );
            },
          ),
          InstellingenCategory(
            icon: Icons.notifications_outlined,
            category: "Notificaties",
            builder: (BuildContext context, StateSetter setState) {
              return ListView(
                children: [
                  CustomInstelling(
                    title: "Notificatie voor de les",
                    subtitle: "Het aantal minuten dat je voor een les een notificatie krijgt",
                    trailing: CircleShape(
                      child: Text("${userdata.get("preNotificationMinutes")}"),
                    ),
                    onTap: () => showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return NumberPickerDialog.integer(
                          title: Text("Notificatie Tijd (minuten)"),
                          minValue: 0,
                          maxValue: 720,
                          initialIntegerValue: userdata.get("preNotificationMinutes"),
                        );
                      },
                    ).then((value) {
                      if (value != null)
                        setState(() {
                          userdata.put("preNotificationMinutes", value);
                          notifications.lessonNotifications(account.lessons);
                        });
                    }),
                  )
                ],
              );
            },
          ),
          InstellingenCategory(
            icon: Icons.build_outlined,
            category: "Overig",
            builder: (BuildContext context, StateSetter setState) {
              return ListView(
                children: [
                  SwitchInstelling(
                    title: "Zet je foto uit",
                    subtitle: "Voor als die niet zo goed gelukt is",
                    setting: "useIcon",
                    onChange: () => appState.setState(() {}),
                  ),
                  SwitchInstelling(
                    title: "Terugknop opent sidebar",
                    subtitle: "Open de sidebar als je één keer op de terugknop klikt",
                    setting: "backOpensDrawer",
                    onChange: () => appState.setState(() {}),
                  ),
                  SwitchInstelling(
                    disabled: !userdata.get("backOpensDrawer"),
                    title: "Dubbele terugknop voor agenda",
                    subtitle: "Open de agenda als je twee keer snel op de terugknop klikt",
                    setting: userdata.get("backOpensDrawer") ? "doubleBackAgenda" : "backOpensDrawer",
                    onChange: () => appState.setState(() {}),
                  ),
                  if (accounts.length > 1)
                    SwitchInstelling(
                      title: "Open altijd je hoofdaccount",
                      subtitle: "Open altijd je hoofd account als je de app opstart",
                      setting: "alwaysPrimary",
                      onChange: () => appState.setState(() {}),
                    ),
                  if (custom.isEmpty)
                    Container()
                  else
                    CustomInstelling(
                      title: "Verwijder alle zelfbedachte namen",
                      trailing: Padding(
                        padding: EdgeInsets.only(right: 15),
                        child: Icon(
                          Icons.delete,
                          color: Colors.red[400],
                        ),
                      ),
                      onTap: () => showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: Text("Weet je het zeker?"),
                          content: Text("Als je op verwijder klikt, worden al je zelfbedachte namen verwijderd."),
                          actions: [
                            FlatButton(
                              child: Text("Annuleer"),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            FlatButton(
                              child: Text("Verwijder"),
                              onPressed: () => setState(
                                () {
                                  custom.clear();
                                  handleError(account.magister.agenda.refresh, "Kon agenda niet herladen", context);
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          if (userdata.get("developerMode"))
            InstellingenCategory(
              icon: Icons.settings_ethernet,
              category: "Developer opties",
              builder: (BuildContext context, StateSetter setState) {
                return ListView(
                  children: [
                    SwitchInstelling(
                      title: "Developer opties",
                      subtitle: "Schakel developer opties uit",
                      setting: "developerMode",
                    ),
                    CustomInstelling(
                      title: 'Aangepaste primaire kleur',
                      onTap: () => showColorAdvanced("primaryColor"),
                      subtitle: '#${Theme.of(context).primaryColor.value.toRadixString(16).substring(2, 8).toUpperCase()}',
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
                    CustomInstelling(
                      title: 'Aangepaste secundaire kleur',
                      onTap: () => showColorAdvanced("accentColor"),
                      subtitle: '#${Theme.of(context).accentColor.value.toRadixString(16).substring(2, 8).toUpperCase()}',
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
                );
              },
            ),
        ],
      ),
    );
  }
}
