import 'package:flutter/material.dart';
// import 'package:flutter_colorpicker/flutter_colorpicker.dart';
// import 'package:numberpicker/numberpicker.dart';
import 'package:Argo/main.dart';
import 'package:Argo/src/ui/CustomWidgets.dart';

class Instellingen extends StatefulWidget {
  @override
  _Instellingen createState() => _Instellingen();
}

class InstellingenCategory extends StatelessWidget {
  final String category;
  final List<Widget> children;
  final IconData icon;

  InstellingenCategory({this.category, this.icon, this.children});

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
              builder: (context) => InstellingPagina(category.toLowerCase(), children),
            ),
          );
        },
      ),
    );
  }
}

class SwitchInstelling extends StatelessWidget {
  final String title;
  final Function onUpdate;
  final bool value;

  SwitchInstelling({this.title, this.onUpdate, this.value});
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onUpdate,
      title: Text(title),
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
        subtitle: Text(subtitle),
      ),
    );
  }
}

class InstellingPagina extends StatelessWidget {
  final String instelling;
  final List<Widget> page;

  InstellingPagina(this.instelling, this.page);

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Instellingen voor $instelling"),
      ),
      body: ListView(
        children: page,
      ),
    );
  }
}

class _Instellingen extends State<Instellingen> {
  Future showThemeMenu() {
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
  }

  // void _showColorPicker(pick) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text("Kies een kleur"),
  //         content: Column(mainAxisSize: MainAxisSize.min, children: [
  //           ColorPicker(
  //             pickerColor: userdata.get(pick),
  //             onColorChanged: (color) {
  //               appState.setState(() {
  //                 userdata.put(pick, color);
  //               });
  //             },
  //           ),
  //         ]),
  //         actions: <Widget>[
  //           FlatButton(
  //             child: Text(
  //               "Sluit",
  //             ),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Widget build(BuildContext context) {
    return AppPage(
      title: Text("Instellingen"),
      body: ListView(
        children: [
          InstellingenCategory(
            icon: Icons.format_paint_outlined,
            category: "Uiterlijk",
            children: [
              // CustomInstelling(
              //   title: "Thema",
              //   onTap: () {
              //     showThemeMenu();
              //   },
              //   trailing: Icon(Icons.brightness_3),
              //   subtitle: userdata.get("theme").toString().capitalize + " thema",
              // ),

              // CustomInstelling
            ],
          ),
          InstellingenCategory(
            icon: Icons.calendar_today_outlined,
            category: "Agenda",
            children: [
              CustomInstelling(
                title: "Automatisch start uur",
              ),
            ],
          ),
          InstellingenCategory(
            icon: Icons.notifications_outlined,
            category: "Notificaties",
            children: [],
          ),
          InstellingenCategory(
            icon: Icons.miscellaneous_services,
            category: "Overig",
            children: [],
          ),
        ],
      ),
    );
  }
}
