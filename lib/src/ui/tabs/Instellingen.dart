import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:argo/main.dart';
import 'package:share/share.dart';

import 'package:argo/src/ui/components/Card.dart';
import 'package:argo/src/ui/components/Utils.dart';
import 'package:argo/src/ui/components/ListTileBorder.dart';
import 'package:argo/src/ui/components/AppPage.dart';
import 'package:argo/src/ui/components/CircleShape.dart';

class Instellingen extends StatefulWidget {
  @override
  _Instellingen createState() => _Instellingen();
}

class InstellingenCategory extends StatelessWidget {
  final String category;
  final Widget Function(BuildContext, void Function(void Function())) builder;
  final IconData icon;
  final bool border;

  InstellingenCategory({this.category, this.icon, this.builder, this.border = true});

  Widget build(BuildContext context) {
    return MaterialCard(
      child: ListTileBorder(
        border: !border
            ? null
            : Border(
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
  final bool border;

  SwitchInstelling({this.title, this.setting, this.subtitle, this.onChange, this.disabled, this.border = true});

  Widget build(BuildContext context) {
    return MaterialCard(
      border: !border
          ? null
          : Border(
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
  final bool border;

  CustomInstelling({this.title, this.onTap, this.trailing, this.subtitle, this.border = true});

  Widget build(BuildContext context) {
    return MaterialCard(
      border: !border
          ? null
          : Border(
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
        children: [
          InstellingenCategory(
            border: false,
            icon: Icons.format_paint_outlined,
            category: "Uiterlijk",
            builder: (BuildContext context, StateSetter setState) {
              return ListView(
                children: [
                  CustomInstelling(
                    border: false,
                    title: "Thema",
                    onTap: () {
                      showThemeMenu(setState);
                    },
                    trailing: Icon(Icons.brightness_2_outlined),
                    subtitle: userdata.get("theme").toString().capitalize,
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
                    border: false,
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
                    border: false,
                    title: "Lesmelding",
                    subtitle: "Hoeveel minuten voor de les je een melding krijgt",
                    trailing: CircleShape(
                      child: Text("${userdata.get("preNotificationMinutes")}"),
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
                    border: false,
                    title: "Foto verbergen",
                    subtitle: "Voor als die niet zo goed gelukt is",
                    setting: "useIcon",
                    onChange: () => appState.setState(() {}),
                  ),
                  SwitchInstelling(
                    title: "Menu openen met terugknop",
                    subtitle: "Opent de zijbalk bij één keer gebruiken terugknop",
                    setting: "backOpensDrawer",
                    onChange: () => appState.setState(() {}),
                  ),
                  SwitchInstelling(
                    disabled: !userdata.get("backOpensDrawer"),
                    title: "Agenda openen met 2× terugknop",
                    subtitle: "Opent de agenda bij twee keer gebruiken terugknop",
                    setting: userdata.get("backOpensDrawer") ? "doubleBackAgenda" : "backOpensDrawer",
                    onChange: () => appState.setState(() {}),
                  ),
                  if (accounts.length > 1)
                    SwitchInstelling(
                      title: "Altijd hoofdaccount gebruiken",
                      subtitle: "Opent altijd je hoofdaccount als je de app opstart",
                      setting: "alwaysPrimary",
                      onChange: () => appState.setState(() {}),
                    ),
                  if (custom.isEmpty)
                    Container()
                  else
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
              category: "Ontwikkelaarsopties",
              builder: (BuildContext context, StateSetter setState) {
                return ListView(
                  children: [
                    SwitchInstelling(
                      border: false,
                      title: "Ontwikkelaarsopties",
                      subtitle: "Schakel ontwikkelaarsopties uit",
                      setting: "developerMode",
                    ),
                    SwitchInstelling(
                      title: 'Onvoldoendekleur uitschakelen',
                      subtitle: 'Zorgt ervoor dat onvoldoendes niet rood verschijnen',
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
                    CustomInstelling(
                      title: 'Gebruikersgegevens',
                      subtitle: 'Gebruikersgegevens inzien',
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
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class LogPagina extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Logboek"),
        actions: [
          IconButton(
            icon: Icon(
              Icons.error_outline,
            ),
            onPressed: () {
              throw "Manually generated error";
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
        title: Text("Gebruikersgegevens"),
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
      body: ListView(
        children: () {
          return userdata
              .toMap()
              .entries
              .map((e) => ListTile(
                    title: Text(e.key.toString()),
                    subtitle: Text(
                      e.value.toString(),
                    ),
                  ))
              .toList();
        }(),
      ),
    );
  }
}
