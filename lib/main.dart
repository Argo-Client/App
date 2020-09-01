import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    title: 'Magistex',
    theme: ThemeData(
      primaryColor: Colors.blue,
    ),
    initialRoute: '/',
    routes: {
      '/': (context) => Agenda(),
      '/cijfers': (context) => Cijfers(),
    },
  ));
}

class Agenda extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Scaffold is a layout for the major Material Components.
    return Scaffold(
      drawer: DefaultDrawer(),
      appBar: AppBar(
        title: Text('Agenda'),
      ),
      body: Center(
        child: Text('Hier komt de agenda'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}

class Cijfers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DefaultDrawer(),
      body: Center(
        child: Text('Hier komen de cijfers'),
      ),
      appBar: AppBar(
        title: Text('Cijfers'),
      ),
    );
  }
}

class DefaultDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text('Name',
                style: TextStyle(color: Colors.white, fontSize: 30)),
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
        ],
      ),
    );
  }
}
