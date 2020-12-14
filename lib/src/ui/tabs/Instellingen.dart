import 'package:flutter/material.dart';

import 'package:numberpicker/numberpicker.dart';

import 'package:Argo/main.dart';
import 'package:Argo/src/layout.dart';
import 'package:Argo/src/ui/CustomWidgets.dart';

import 'package:Argo/src/utils/instellingen.dart';

enum InstellingType { checkBox, number, custom }

class Instelling extends StatelessWidget {
  final String title;
  final String description;
  final InstellingType type;
  final bool value;
  final Function onTap;
  final Widget trailing;

  Instelling({
    this.title = "",
    this.description = "",
    this.trailing,
    this.type,
    this.onTap,
    this.value,
  });

  Widget build(BuildContext context) {
    return SeeCard(
      child: ListTileBorder(
        title: Text(title),
        trailing: trailing,
        subtitle: Text(description),
        onTap: onTap,
      ),
    );
  }
}

class InstellingCategory extends StatelessWidget {
  final String name;
  final IconData icon;
  final List<Instelling> children;

  InstellingCategory({
    this.name,
    this.icon,
    this.children,
  });

  Widget build(BuildContext context) {
    return ListTileBorder(
      title: Text(name),
      leading: Icon(icon),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => InstellingPagina(this),
          ),
        );
      },
    );
  }
}

class Instellingen extends StatefulWidget {
  @override
  _Instellingen createState() => _Instellingen();
}

class _Instellingen extends State<Instellingen> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            DrawerStates.layoutKey.currentState.openDrawer();
          },
        ),
        title: Text("Instellingen"),
      ),
      body: ListView(
        children: [
          InstellingenList(),
          ContentHeader("Uiterlijk"),
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
              onChanged: (value) => appState.setState(
                () {
                  setState(
                    () {
                      userdata.put("colorsInDrawer", value);
                    },
                  );
                },
              ),
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
              ListTileBorder(
                border: Border(
                  bottom: greyBorderSide(),
                ),
                title: Text("Standaard eindtijd."),
                subtitle: Text("Hoelaat je agenda moet eindigen."),
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
                ).then((value) {
                  if (value != null)
                    setState(() {
                      userdata.put("agendaEndHour", value);
                    });
                }),
              ),
              Container(
                child: CheckboxListTile(
                  title: Text("Automatisch begin uur"),
                  subtitle: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 5,
                    ),
                    child: Text("Of je agenda wilt laten starten wanneer je eerste les begint of bij je start tijd."),
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
                title: Text("Automatisch eind uur"),
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
          ContentHeader("Meldingen"),
          SeeCard(
            column: [
              ListTile(
                title: Text("Notificatie Tijd"),
                subtitle: Text("Hoeveel minuten je voor een les een notificatie krijgt."),
                trailing: CircleShape(
                  child: Text("${userdata.get("preNotificationMinutes")}"),
                ),
                onTap: () => showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return NumberPickerDialog.integer(
                      title: Text("Notificatie Tijd (minuten)"),
                      minValue: -120,
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
              ),
            ],
          ),
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
                  onChanged: (value) => setState(() {
                    userdata.put("backOpensDrawer", value);
                  }),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: greyBorderSide(),
                  ),
                ),
                child: CheckboxListTile(
                  title: Text("Dubbele Terugknop voor agenda"),
                  activeColor: userdata.get("accentColor"),
                  subtitle: Text("Als je twee keer snel op de terugknop klikt, open dan je agenda."),
                  value: userdata.get("doubleBackAgenda"),
                  onChanged: (value) => setState(() {
                    userdata.put("doubleBackAgenda", value);
                  }),
                ),
              ),
              if (accounts.length > 1)
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: greyBorderSide(),
                    ),
                  ),
                  child: CheckboxListTile(
                    title: Text("Open altijd je hoofdaccount"),
                    activeColor: userdata.get("accentColor"),
                    subtitle: Text("Open altijd je eerste account als je de app opstart."),
                    value: userdata.get("alwaysPrimary"),
                    onChanged: (value) => setState(() {
                      userdata.put("alwaysPrimary", value);
                    }),
                  ),
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

class InstellingPagina extends StatelessWidget {
  final InstellingCategory category;

  InstellingPagina(this.category);
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          category.name,
        ),
      ),
      body: ListView(
        children: category?.children ?? [],
      ),
    );
  }
}
