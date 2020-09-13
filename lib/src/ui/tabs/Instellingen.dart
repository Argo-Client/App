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
      body: ValueListenableBuilder(
        valueListenable: userdata.listenable(),
        builder: (context, box, widget) {
          return ListView(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 15, top: 20),
                child: Text(
                  "Uiterlijk",
                  style: TextStyle(color: userdata.get("accentColor")),
                ),
              ),
              ListTile(
                title: Text('Donker thema'),
                trailing: Switch.adaptive(
                  value: box.get('darkMode'),
                  onChanged: (value) {
                    appState.setState(() {
                      box.put("darkMode", value);
                    });
                  },
                ),
              ),
              ListTile(
                title: Text('Primaire kleur'),
                subtitle: Text(
                  '#${Theme.of(context).primaryColor.value.toRadixString(16).substring(2, 8).toUpperCase()}',
                ),
                onTap: () => _showColorPicker((color) => appState.setState(() {
                      box.put("primaryColor", color);
                    })),
                trailing: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: box.get("primaryColor"),
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
                      box.put("accentColor", color);
                    })),
                trailing: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: box.get("accentColor"),
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
                  style: TextStyle(color: box.get("accentColor")),
                ),
              ),
              Divider(),
              Padding(
                padding: EdgeInsets.only(left: 15, top: 20),
                child: Text(
                  "Meldingen",
                  style: TextStyle(color: box.get("accentColor")),
                ),
              ),
              Divider(),
              Padding(
                padding: EdgeInsets.only(left: 15, top: 20),
                child: Text(
                  "Overig",
                  style: TextStyle(color: box.get("accentColor")),
                ),
              ),
              ListTile(
                title: Text("Verander foto"),
                subtitle: Text("Verander je foto als die niet zo goed gelukt is."),
                trailing: CircleAvatar(
                  backgroundColor: Theme.of(context).backgroundColor,
                  child: userdata.get("userIcon") != Icons.person || account.profilePicture == null
                      ? Icon(
                          userdata.get("userIcon"),
                          size: 30,
                        )
                      : Image.memory(base64Decode(account.profilePicture)),
                ),
                onTap: () {
                  FlutterIconPicker.showIconPicker(
                    context,
                    title: Text("Kies een icoontje"),
                    closeChild: Text(
                      'Sluit',
                      textScaleFactor: 1.25,
                    ),
                    // iconPackMode: IconPack.materialOutline,
                  ).then((icon) {
                    if (icon != null)
                      appState.setState(() {
                        userdata.put("userIcon", icon);
                      });
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.input),
                title: Text('Open Introductie'),
                onTap: () {
                  // Navigator.pushNamed(context, "Introduction");
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Introduction()));
                },
              ),
              ListTile(
                leading: Icon(Icons.group_add),
                title: Text("Voeg account toe"),
                onTap: () {
                  magisterAuth.fullLogin((tokenSet) async {
                    if (tokenSet != null) {
                      Account newAccount = Account();
                      newAccount.saveTokens(tokenSet);
                      await newAccount.magister.refresh();
                      if (newAccount.id != null && !accounts.values.any((acc) => acc.id == newAccount.id)) {
                        accounts.add(newAccount);
                        userdata.put("accountIndex", accounts.length - 1);
                        account = newAccount;
                        print('$account is toegevoegd');
                      } else {
                        print("Account bestaat al");
                      }
                    }
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text("Kies account"),
                onTap: () {
                  SimpleDialog(
                    title: Text("Kies account"),
                    children: [Text("ewa")],
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.refresh),
                title: Text("Ververs account"),
                onTap: () async {
                  print(account.magister);
                  await account.magister.refresh();
                  appState.setState(() {});
                },
              )
            ],
          );
        },
      ),
    );
  }
}
