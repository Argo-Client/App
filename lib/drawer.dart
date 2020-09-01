part of main;

class DefaultDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text('Name', style: TextStyle(color: Colors.white, fontSize: 30)),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
          ),
          ListTile(
            title: Row(
              children: [Icon(Icons.event), Text(' Agenda')],
            ),
            onTap: () {
              Navigator.pushNamed(context, '/');
            },
          ),
          ListTile(
            title: Row(
              children: [Icon(Icons.assignment), Text(' Huiswerk')],
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Row(
              children: [Icon(Icons.check_circle), Text(' Afwezigheid')],
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Row(
              children: [Icon(Icons.looks_6), Text(' Cijfers')],
            ),
            onTap: () {
              Navigator.pushNamed(context, '/cijfers');
              // Navigator.pop(context);
            },
          ),
          ListTile(
            title: Row(
              children: [Icon(Icons.email), Text(' Berichten')],
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Row(
              children: [Icon(Icons.assignment_turned_in), Text(' Opdrachten')],
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Row(
              children: [Icon(Icons.description), Text(' Leermiddelen')],
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Row(
              children: [Icon(Icons.input), Text(' Open Introductie')],
            ),
            onTap: () {
              Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (context) => new Introduction()));
            },
          )
        ],
      ),
    );
  }
}
