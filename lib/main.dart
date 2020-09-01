import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    title: 'Magistex',
    home: Agenda(),
  ));
}

void goToCijfers() {
  MaterialApp(
    title: 'Magistex',
    home: Cijfers(),
  );
}

class Agenda extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Scaffold is a layout for the major Material Components.
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              child: Text('Naam',
                  style: TextStyle(color: Colors.white, fontSize: 30)),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Row(
                children: [Icon(Icons.event), Text(' Agenda')],
              ),
              onTap: () {
                // goToAgenda();
                Navigator.pop(context);
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
                goToCijfers();
                Navigator.pop(context);
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
                children: [
                  Icon(Icons.assignment_turned_in),
                  Text(' Opdrachten')
                ],
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
      ),
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
      body: Center(
        child: Text('Hier komen de cijfers'),
      ),
    );
  }
}
