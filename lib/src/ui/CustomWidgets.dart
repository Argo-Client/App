import 'package:flutter/material.dart';
import 'package:Argo/main.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:clipboard/clipboard.dart';
import 'package:fluttertoast/fluttertoast.dart';

BorderSide greyBorderSide() {
  Color color;
  if (theme == Brightness.dark) {
    if (userdata.get("theme") == "OLED") {
      color = Color.fromARGB(
        255,
        50,
        50,
        50,
      );
    } else {
      color = Color.fromARGB(
        255,
        100,
        100,
        100,
      );
    }
  } else {
    color = Color.fromARGB(
      255,
      225,
      225,
      225,
    );
  }

  return BorderSide(color: color, width: 1);
}

// class StudieWijzer extends StatelessWidget {}

class ShowPeopleList extends StatelessWidget {
  final List people;
  final String title;

  ShowPeopleList(
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
            SeeCard(
              child: ListTileBorder(
                border: Border(
                  bottom: greyBorderSide(),
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

class WebContent extends StatelessWidget {
  final String htmlText;

  WebContent(this.htmlText);

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
      htmlText,
      onTapUrl: launch,
      customStylesBuilder: (e) {
        // print(e.localName);
        if (e.localName == "a") {
          return {'color': '#44b4fe'};
        }

        return null;
      },
    );
  }
}

class ContentHeader extends StatelessWidget {
  final String text;

  ContentHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 15,
        top: 12.5,
        bottom: 12.5,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: userdata.get("accentColor"),
        ),
      ),
    );
  }
}

class SeeCard extends Card {
  final Widget child;
  final EdgeInsets margin;
  Color color;
  final Border border;
  final double width;
  final List<Widget> column;

  SeeCard({
    this.width,
    this.margin,
    this.child,
    this.color,
    this.border,
    this.column,
  });

  @override
  Widget build(BuildContext context) {
    if (color == null && userdata.get("theme") == "OLED") {
      color = Colors.black;
    }

    return Container(
      width: width,
      decoration: border == null
          ? null
          : BoxDecoration(
              border: border,
            ),
      child: Card(
        margin: margin ?? EdgeInsets.zero,
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        color: color,
        child: column != null
            ? Column(
                children: column,
              )
            : child,
      ),
    );
  }
}

class ListTileBorder extends StatelessWidget {
  final Widget title;
  final Widget subtitle;
  final Widget leading;
  final Widget trailing;
  final Function onTap;
  final Border border;

  ListTileBorder({
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.border,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: border,
      ),
      child: ListTile(
        title: title,
        leading: leading,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
