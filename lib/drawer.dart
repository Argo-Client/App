part of main;

class DefaultDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text("Guus van Meerveld"),
            accountEmail: Text("616258"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).backgroundColor,
              child: Icon(Icons.person, size: 50),
            ),
          ),
          ListTile(
            leading: Icon(Icons.event),
            title: Text('Agenda'),
            onTap: () {
              Navigator.pushNamed(context, '/');
            },
          ),
          ListTile(
            leading: Icon(Icons.assignment),
            title: Text('Huiswerk'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.check_circle),
            title: Text('Afwezigheid'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.looks_6),
            title: Text('Cijfers'),
            onTap: () {
              Navigator.pushNamed(context, 'Cijfers');
              // Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.email),
            title: Text('Berichten'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ExpansionTile(
            leading: Icon(Icons.ac_unit),
            title: Text("ELO"),
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.work),
                title: Text('Studiewijzer'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.assignment_turned_in),
                title: Text('Opdrachten'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.description),
                title: Text('Leermiddelen'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.folder),
                title: Text('Bronnen'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Mijn gegevens'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Instellingen'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.input),
            title: Text('Open Introductie'),
            onTap: () {
              Navigator.pushNamed(context, 'Introduction');
            },
          )
        ],
      ),
    );
  }
}
