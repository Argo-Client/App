part of main;

class Instellingen extends StatefulWidget {
  @override
  _Instellingen createState() => _Instellingen();
}

class _Instellingen extends State<Instellingen> {
  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Kies een kleur"),
          content: BlockPicker(
            pickerColor: Theme.of(context).primaryColor,
            onColorChanged: (color) {
              DynamicTheme.of(context).setThemeData(
                new ThemeData(
                    primaryColor: color,
                    accentColor: Theme.of(context).accentColor,
                    brightness: Theme.of(context).brightness),
              );
            },
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Close"),
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
    var darkThemeOpt = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 15, top: 20),
          child: Text(
            "Uiterlijk",
            style: TextStyle(color: Colors.orange),
          ),
        ),
        ListTile(
          title: Text('Donker thema'),
          trailing: Switch.adaptive(
            value: darkThemeOpt,
            onChanged: (value) {
              setState(() => darkThemeOpt = value);
              DynamicTheme.of(context)
                  .setBrightness(value ? Brightness.dark : Brightness.light);
            },
          ),
        ),
        ListTile(
          title: Text('Primaire kleur'),
          subtitle: Text(
            '#${Theme.of(context).primaryColor.value.toRadixString(16).substring(2, 8).toUpperCase()}',
          ),
          onTap: _showColorPicker,
          trailing: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).primaryColor,
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
          onTap: _showColorPicker,
          trailing: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).accentColor,
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
            "Account",
            style: TextStyle(color: Colors.orange),
          ),
        ),
        Divider(),
        Padding(
          padding: EdgeInsets.only(left: 15, top: 20),
          child: Text(
            "Meldingen",
            style: TextStyle(color: Colors.orange),
          ),
        ),
        Divider(),
        Padding(
          padding: EdgeInsets.only(left: 15, top: 20),
          child: Text(
            "Overig",
            style: TextStyle(color: Colors.orange),
          ),
        ),
        ListTile(
          title: Text("Verander foto"),
          subtitle: Text("Verander je foto als die niet zo goed gelukt is."),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Kies een optie"),
                  content: DefaultTabController(
                    length: 3,
                    child: Scaffold(
                      backgroundColor: Colors.transparent,
                      appBar: TabBar(
                        tabs: [
                          Tab(icon: Icon(Icons.face)),
                          Tab(icon: Icon(Icons.file_upload)),
                          Tab(icon: Icon(Icons.person)),
                        ],
                      ),
                      body: TabBarView(
                        children: [
                          Icon(Icons.directions_car),
                          Icon(Icons.directions_transit),
                          Icon(Icons.directions_bike),
                        ],
                      ),
                    ),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Close"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
        )
      ],
    );
  }
}
