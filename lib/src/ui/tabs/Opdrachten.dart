import 'package:argo/src/ui/components/ListTileDivider.dart';
import 'package:argo/src/utils/hive/adapters.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';

import 'package:argo/src/ui/components/Card.dart';
import 'package:argo/src/ui/components/AppPage.dart';
import 'package:argo/src/ui/components/WebContent.dart';
import 'package:argo/src/ui/components/CircleShape.dart';

class Opdrachten extends StatefulWidget {
  @override
  _OpdrachtenState createState() => _OpdrachtenState();
}

DateFormat dateFormatter = DateFormat('dd-MM-yyyy HH:mm');

class _OpdrachtenState extends State<Opdrachten> {
  Widget opdracht(Opdracht opdracht) {
    return MaterialCard(
      child: ListTile(
        title: opdracht.titel == null ? null : Text(opdracht.titel),
        subtitle: opdracht.status == null || opdracht.inleverDatum == null
            ? null
            : Text(
                "${opdracht.status} | ${dateFormatter.format(opdracht.inleverDatum)}",
                style: TextStyle(
                  color: DateTime.now().isAfter(opdracht.inleverDatum) ? Colors.red : null,
                ),
              ),
        leading: opdracht.vak == null
            ? null
            : Padding(
                child: Text(
                  opdracht.vak,
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.grey[400],
                  ),
                ),
                padding: EdgeInsets.only(left: 10, top: 10),
              ),
        trailing: opdracht.beoordeling == null
            ? null
            : CircleShape(
                child: Text(opdracht.beoordeling),
              ),
        onTap: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OpdrachtPagina(opdracht),
            ),
          ),
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Opdracht> opdrachten = [];

    return AppPage(
      title: Text("Opdrachten"),
      body: Scaffold(
        body: ListView(
          children: divideListTiles(opdrachten.map(opdracht)),
        ),
      ),
    );
  }
}

class OpdrachtPagina extends StatelessWidget {
  final Opdracht opdracht;

  OpdrachtPagina(this.opdracht);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(opdracht.titel),
      ),
      body: ListView(
        children: divideListTiles([
          if (opdracht.ingeleverdOp == null)
            MaterialCard(
              child: ListTile(
                leading: Icon(Icons.calendar_today_outlined),
                title: Text(
                  dateFormatter.format(opdracht.inleverDatum),
                ),
                subtitle: Text("Inleverdatum"),
              ),
            ),
          if (opdracht.ingeleverdOp != null)
            MaterialCard(
              child: ListTile(
                leading: Icon(Icons.assignment_returned_outlined),
                title: Text(
                  dateFormatter.format(opdracht.ingeleverdOp),
                ),
                subtitle: Text("Ingeleverd op"),
              ),
            ),
          MaterialCard(
            child: ListTile(
              leading: Icon(Icons.grade_outlined),
              title: Text(opdracht.status),
              subtitle: Text("Status"),
            ),
          ),
          if (opdracht.leerlingOpmerking != null && opdracht.leerlingOpmerking.isNotEmpty)
            MaterialCard(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.only(top: 20),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                    "Door jou ingeleverd",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                WebContent(opdracht.leerlingOpmerking),
              ],
            ),
        ]),
      ),
    );
  }
}
