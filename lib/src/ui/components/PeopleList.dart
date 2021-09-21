import 'package:argo/src/ui/components/ListTileDivider.dart';
import 'package:argo/src/utils/hive/adapters.dart';
import 'package:flutter/material.dart';

import 'package:clipboard/clipboard.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'Card.dart';

class PeopleList extends StatelessWidget {
  final List<Contact> people;
  final String title;

  PeopleList(
    this.people, {
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
        ),
        actions: [
          IconButton(
            tooltip: "Kopieer lijst",
            icon: Icon(
              Icons.copy,
            ),
            onPressed: () {
              FlutterClipboard.copy(
                people.map((e) => e.naam).join(" \r\n"),
              ).then((value) => {
                    Fluttertoast.showToast(
                      msg: "Gekopieerd ;)",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.white,
                      textColor: Colors.black,
                      fontSize: 16.0,
                    ),
                  });
            },
          ),
          Padding(
            padding: EdgeInsets.only(
              right: 5,
            ),
            child: Tooltip(
              message: "Lengte van de lijst",
              child: Row(
                children: [
                  Icon(
                    Icons.people,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 5,
                    ),
                    child: Text(
                      people.length.toString(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: MaterialCard(
        children: divideListTiles(
          people
              .map(
                (person) => ListTile(
                  leading: Icon(
                    Icons.person,
                  ),
                  title: Text(
                    person.naam,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
