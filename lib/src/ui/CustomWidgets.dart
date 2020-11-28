import 'package:flutter/material.dart';
import 'package:Argo/main.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:clipboard/clipboard.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:auto_animated/auto_animated.dart';

import 'package:Argo/src/utils/hive/adapters.dart';

final options = LiveOptions(
  // delay: Duration(milliseconds: 1),
  showItemInterval: Duration(milliseconds: 10),
  showItemDuration: Duration(milliseconds: 200),
  visibleFraction: 0.5,
  reAnimateOnVisibility: false,
);

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

class PopoutFloat extends StatefulWidget {
  final List<PopoutButton> children;
  final AnimatedIconData icon;
  final ColorTween color;

  PopoutFloat({this.children, this.icon, this.color});

  @override
  _PopoutFloatState createState() => _PopoutFloatState(icon: icon, children: children, color: color);
}

class _PopoutFloatState extends State<PopoutFloat> with SingleTickerProviderStateMixin {
  final List<PopoutButton> children;
  final AnimatedIconData icon;
  final ColorTween color;

  _PopoutFloatState({this.children, this.icon, this.color});

  bool isOpened = false;
  AnimationController _animationController;
  Animation<double> _translateButton;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Animation<double> _textOpacity;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 56.0;

  @override
  initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    )..addListener(() {
        setState(() {});
      });

    _animateIcon = Tween<double>(begin: 0.0, end: 1.0).animate(
      _animationController,
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      _animationController,
    );

    _buttonColor = color.animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));

    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -14.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));

    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        if (children != null)
          for (int i = children.length - 1; i >= 0; i--)
            Transform(
              transform: Matrix4.translationValues(
                0.0,
                _translateButton.value * (i + 1),
                0.0,
              ),
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      child: FadeTransition(
                        opacity: _textOpacity,
                        child: Text(
                          children[i].text,
                        ),
                      ),
                      padding: EdgeInsets.only(
                        right: 15,
                      ),
                    ),
                    FloatingActionButton(
                      heroTag: "PopoutButton-$i",
                      onPressed: children[i].onPressed,
                      child: Icon(
                        children[i].icon,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: "PopoutFloat",
              onPressed: animate,
              backgroundColor: _buttonColor.value,
              child: AnimatedIcon(
                icon: icon,
                progress: _animateIcon,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class PopoutButton {
  final Function onPressed;
  final IconData icon;
  final String text;

  PopoutButton(this.text, {this.onPressed, this.icon});
}

class CijferTile extends StatelessWidget {
  final Cijfer cijfer;
  final bool isRecent;

  CijferTile(this.cijfer, {this.isRecent});

  @override
  Widget build(BuildContext build) {
    return ListTile(
      trailing: cijfer.cijfer.length > 4
          ? null
          : Stack(
              children: [
                Text(
                  cijfer.cijfer,
                  style: TextStyle(
                    fontSize: 17,
                    color: cijfer.voldoende ? null : Colors.red,
                  ),
                ),
                Transform.translate(
                  offset: Offset(10, -15),
                  child: Text(
                    "${cijfer.weging}x",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                )
              ],
            ),
      subtitle: cijfer.cijfer.length <= 4
          ? Text(isRecent == null ? formatDate.format(cijfer.ingevoerd) : cijfer.vak.naam)
          : Padding(
              padding: EdgeInsets.symmetric(
                vertical: 8,
              ),
              child: Text(
                cijfer.cijfer,
              ),
            ),
      title: Text(cijfer.title),
    );
  }
}

class FeedItem extends StatelessWidget {
  final List children;
  final String header;
  final Widget title;
  final Widget subtitle;
  final Widget trailing;
  final Function onTap;

  FeedItem({
    this.children,
    this.header,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ContentHeader(header),
        for (Widget child in children)
          Card(
            child: child,
          )
      ],
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

Widget buildLiveList(list, loaded) {
  return LiveList.options(
      itemCount: list.length,
      options: options,
      itemBuilder: (
        BuildContext context,
        int index,
        Animation<double> animation,
      ) {
        if (index <= loaded)
          return list[index];
        else
          return FadeTransition(
            opacity: Tween<double>(
              begin: 0,
              end: 1,
            ).animate(animation),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0, -0.1),
                end: Offset.zero,
              ).animate(animation),
              child: list[index],
            ),
          );
      });
}
