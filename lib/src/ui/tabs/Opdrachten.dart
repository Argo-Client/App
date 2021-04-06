import 'package:argo/src/utils/hive/adapters.dart';
import 'package:argo/src/ui/CustomWidgets.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';

class Opdrachten extends StatefulWidget {
  @override
  _OpdrachtenState createState() => _OpdrachtenState();
}

DateFormat dateFormatter = DateFormat('dd-MM-yyyy HH:mm');

class _OpdrachtenState extends State<Opdrachten> {
  Widget opdracht(Opdracht opdracht) {
    return SeeCard(
      child: ListTileBorder(
        border: Border(top: greyBorderSide()),
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
          children: [
            for (int i = 0; i < opdrachten.length; i++)
              opdracht(
                opdrachten[i],
              ),
          ],
        ),
      ),
    );
  }
}

//ignore: must_be_immutable
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
        children: [
          if (opdracht.ingeleverdOp == null)
            SeeCard(
              child: ListTileBorder(
                leading: Icon(Icons.calendar_today_outlined),
                title: Text(
                  dateFormatter.format(opdracht.inleverDatum),
                ),
                subtitle: Text("Inleverdatum"),
              ),
            ),
          if (opdracht.ingeleverdOp != null)
            SeeCard(
              child: ListTileBorder(
                border: Border(top: greyBorderSide()),
                leading: Icon(Icons.assignment_returned_outlined),
                title: Text(
                  dateFormatter.format(opdracht.ingeleverdOp),
                ),
                subtitle: Text("Ingeleverd op"),
              ),
            ),
          SeeCard(
            child: ListTileBorder(
              border: Border(
                top: greyBorderSide(),
              ),
              leading: Icon(Icons.grade_outlined),
              title: Text(opdracht.status),
              subtitle: Text("Status"),
            ),
          ),
          if (opdracht.leerlingOpmerking != null && opdracht.leerlingOpmerking.isNotEmpty)
            SeeCard(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.only(top: 20),
              crossAxisAlignment: CrossAxisAlignment.start,
              column: [
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
        ],
      ),
    );
  }
}
