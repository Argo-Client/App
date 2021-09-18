import 'package:flutter/material.dart';

import 'package:share/share.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:numberpicker/numberpicker.dart';

import 'package:argo/main.dart';

import 'package:argo/src/utils/boxes.dart';
import 'package:argo/src/utils/capitalize.dart';
import 'package:argo/src/utils/handleError.dart';
import 'package:argo/src/utils/account.dart';
import 'package:argo/src/utils/notifications.dart';

import 'package:argo/src/ui/components/Card.dart';
import 'package:argo/src/ui/components/AppPage.dart';
import 'package:argo/src/ui/components/CircleShape.dart';
import 'package:argo/src/ui/components/ListTileDivider.dart';

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
    return MaterialCard(
      child: ListTile(
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
    return MaterialCard(
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
            onChanged: disabled ?? false // sam grote dom // huh maar ik vertelde jou toch dat je dit zo moest doen? Hoezo ben ik dan dom joh, kom vechten. // ja maar jij had t toen verkeerd gezegd en toen werkte t niet en toen moest ik t weer fixen
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
    return MaterialCard(
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
            TextButton(
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BlockPicker(
                pickerColor: userdata.get(pick),
                onColorChanged: (color) {
                  appState.setState(() {
                    userdata.put(pick, color);
                  });
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
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
          title: Text("Kleur"),
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
            TextButton(
              child: Text(
                "Sluiten",
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
        children: divideListTiles([
          InstellingenCategory(
            icon: Icons.format_paint_outlined,
            category: "Uiterlijk",
            builder: (BuildContext context, StateSetter setState) {
              return ListView(
                children: divideListTiles([
                  CustomInstelling(
                    title: "Thema",
                    onTap: () {
                      showThemeMenu(setState);
                    },
                    trailing: Icon(Icons.brightness_2_outlined),
                    subtitle: capitalize(userdata.get("theme").toString()),
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
                    subtitle: '#${Theme.of(context).colorScheme.secondary.value.toRadixString(16).substring(2, 8).toUpperCase()}',
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
                    title: "Gekleurde menupictogrammen",
                    subtitle: "Voegt kleur toe aan de picrogrammen in de zijbalk",
                    setting: "colorsInDrawer",
                    onChange: () => appState.setState(() {}),
                  ),
                  SwitchInstelling(
                    title: "Scrollanimatie",
                    subtitle: "Tegels verschijnen met een animatie",
                    setting: "liveList",
                    onChange: () => appState.setState(() {}),
                  )
                ]),
              );
            },
          ),
          InstellingenCategory(
            icon: Icons.calendar_today_outlined,
            category: "Agenda",
            builder: (BuildContext context, StateSetter setState) {
              return ListView(
                children: divideListTiles([
                  CustomInstelling(
                    title: "Agendaschaal",
                    subtitle: "De lengte van één uur in de agenda (in pixels)",
                    trailing: CircleShape(
                      child: Text("${userdata.get("pixelsPerHour")}"),
                    ),
                    onTap: () => showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return NumberPickerDialog.integer(
                          title: Text("Pixels"),
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
                    title: "Starttijd",
                    subtitle: "De tijd waarop je agenda begint",
                    trailing: CircleShape(
                      child: Text("${userdata.get("agendaStartHour")}"),
                    ),
                    onTap: () => showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return NumberPickerDialog.integer(
                          title: Text("Starttijd"),
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
                    title: "Eindtijd",
                    subtitle: "De tijd waarop je agenda ophoudt",
                    trailing: CircleShape(
                      child: Text("${userdata.get("agendaEndHour")}"),
                    ),
                    onTap: () => showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return NumberPickerDialog.integer(
                          title: Text("Eindtijd"),
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
                    title: "Automatische starttijd",
                    subtitle: "De starttijd van je agenda wordt gedetecteerd",
                    setting: "agendaAutoBegin",
                  ),
                  SwitchInstelling(
                    title: "Automatische eindtijd",
                    subtitle: "De eindtijd van je agenda wordt gedetecteerd",
                    setting: "agendaAutoEind",
                  ),
                  SwitchInstelling(
                    title: "Gebruik vak naam",
                    subtitle: "Gebruik de naam van het vak",
                    setting: "useVakName",
                  ),
                ]),
              );
            },
          ),
          InstellingenCategory(
            icon: Icons.notifications_outlined,
            category: "Notificaties",
            builder: (BuildContext context, StateSetter setState) {
              return ListView(
                children: divideListTiles([
                  CustomInstelling(
                    title: "Lesmelding",
                    subtitle: "Hoeveel minuten voor de les je een melding krijgt",
                    trailing: CircleShape(
                      child: Text(userdata.get("preNotificationMinutes").toString()),
                    ),
                    onTap: () => showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return NumberPickerDialog.integer(
                          title: Text("Minuten"),
                          minValue: 0,
                          maxValue: 720,
                          initialIntegerValue: userdata.get("preNotificationMinutes"),
                        );
                      },
                    ).then((value) {
                      if (value != null)
                        setState(() {
                          userdata.put("preNotificationMinutes", value);
                          notifications.lessonNotifications();
                        });
                    }),
                  )
                ]),
              );
            },
          ),
          InstellingenCategory(
            icon: Icons.build_outlined,
            category: "Overig",
            builder: (BuildContext context, StateSetter setState) {
              return ListView(
                children: divideListTiles([
                  SwitchInstelling(
                    title: "Verberg foto",
                    subtitle: "Vervangt je foto voor pictogram",
                    setting: "useIcon",
                    onChange: () => appState.setState(() {}),
                  ),
                  SwitchInstelling(
                    title: "Menu met terugknop",
                    subtitle: "Opent het menu met de terugknop",
                    setting: "backOpensDrawer",
                    onChange: () => appState.setState(() {}),
                  ),
                  SwitchInstelling(
                    disabled: !userdata.get("backOpensDrawer"),
                    title: "Agenda met 2× terugknop",
                    subtitle: "Opent de agenda met de terugknop",
                    setting: userdata.get("backOpensDrawer") ? "doubleBackAgenda" : "backOpensDrawer",
                    onChange: () => appState.setState(() {}),
                  ),
                  if (accounts.length > 1)
                    SwitchInstelling(
                      title: "Altijd hoofdaccount gebruiken",
                      subtitle: "Onthoud je account-keuze niet",
                      setting: "alwaysPrimary",
                      onChange: () => appState.setState(() {}),
                    ),
                  if (custom.isNotEmpty)
                    CustomInstelling(
                      title: "Alle aangepaste vaknamen wissen",
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
                          content: Text("Als je op Verwijderen klikt, worden al je aangepaste namen verwijderd."),
                          actions: [
                            TextButton(
                              child: Text("Annuleren"),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            TextButton(
                              child: Text("Verwijderen"),
                              onPressed: () => setState(
                                () {
                                  custom.clear();
                                  handleError(account().magister.agenda.refresh, "Kon agenda niet herladen", context);
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ]),
              );
            },
          ),
          if (userdata.get("developerMode"))
            InstellingenCategory(
              icon: Icons.settings_ethernet,
              category: "Ontwikkelaarsopties",
              builder: (BuildContext context, StateSetter setState) {
                return ListView(
                  children: divideListTiles([
                    SwitchInstelling(
                      title: "Ontwikkelaarsopties",
                      subtitle: "Schakel ontwikkelaarsopties uit",
                      setting: "developerMode",
                    ),
                    SwitchInstelling(
                      title: 'Onvoldoendekleur uitschakelen',
                      subtitle: 'Normale kleur voor onvoldoendes',
                      setting: "disableCijferColor",
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
                      subtitle: '#${Theme.of(context).colorScheme.secondary.value.toRadixString(16).substring(2, 8).toUpperCase()}',
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
                    CustomInstelling(
                      title: 'Instellingen',
                      subtitle: 'Lijst met je instellingen',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DataPagina(),
                          ),
                        );
                      },
                    ),
                    CustomInstelling(
                      title: 'Foutenlogboek',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => LogPagina(),
                          ),
                        );
                      },
                      subtitle: 'Bekijk het foutenlogboek van de app',
                    )
                  ]),
                );
              },
            ),
        ]),
      ),
    );
  }
}

class LogPagina extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Error log"),
        actions: [
          IconButton(
            icon: Icon(
              Icons.error_outline,
            ),
            onPressed: () {
              throw "Dit is een error";
            },
          ),
          IconButton(
            icon: Icon(
              Icons.share,
            ),
            onPressed: () {
              Share.share(errorLog.value.take(30).toString());
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: errorLog,
        builder: (BuildContext context, log, _a) => ListView(
          children: [
            for (FlutterErrorDetails error in errorLog.value.reversed)
              Column(
                children: [
                  ExpansionTile(
                    title: Text(error.exceptionAsString()),
                    subtitle: Text(error.context.toString()),
                    children: [
                      ListTile(
                        subtitle: Text(error.stack.toString()),
                      )
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

class DataPagina extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Instellingen"),
        actions: [
          IconButton(
            icon: Icon(
              Icons.share,
            ),
            onPressed: () {
              Share.share(userdata.values.toString());
            },
          ),
        ],
      ),
      body: MaterialCard(
        child: ListView(
          children: divideListTiles(
            userdata
                .toMap()
                .entries
                .map((e) => ListTile(
                      title: Text(e.key.toString()),
                      subtitle: Text(
                        e.value.toString(),
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}
