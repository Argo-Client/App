import 'package:flutter/material.dart';

import 'package:clipboard/clipboard.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'Card.dart';
import 'greyBorderSize.dart';
import 'ListTileBorder.dart';

class PeopleList extends StatelessWidget {
  final List people;
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
                people.join(" \r\n"),
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
      body: ListView(
        children: [
          for (int i = 0; i < people.length; i++)
            MaterialCard(
              child: ListTileBorder(
                border: Border(
                  top: greyBorderSide(),
                ),
                leading: Icon(
                  Icons.person,
                ),
                title: Text(
                  people[i].toString(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
