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
            title: Row(
              children: [
                Icon(Icons.event),
                Text('      Agenda'),
              ],
            ),
            onTap: () {
              Navigator.pushReplacementNamed(context, 'Agenda');
            },
          ),
          ListTile(
            title: Row(
              children: [
                Icon(Icons.assignment),
                Text('      Huiswerk'),
              ],
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Row(
              children: [
                Icon(Icons.check_circle),
                Text('      Afwezigheid'),
              ],
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.looks_6),
            title: Text('Cijfers'),
            onTap: () {
              Navigator.pushReplacementNamed(context, 'Cijfers');
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
                title: Text(' Studiewijzer'),
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
                title: Row(
                  children: [
                    Icon(Icons.description),
                    Text('      Leermiddelen'),
                  ],
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Row(
                  children: [
                    Icon(Icons.folder),
                    Text('      Bronnen'),
                  ],
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          ListTile(
            title: Row(
              children: [
                Icon(Icons.person),
                Text('      Mijn gegevens'),
              ],
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Row(
              children: [
                Icon(Icons.settings),
                Text('      Instellingen'),
              ],
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
