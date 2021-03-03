import 'package:Argo/src/layout.dart';
import 'package:flutter/material.dart';
import 'package:Argo/main.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:clipboard/clipboard.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:auto_animated/auto_animated.dart';

import 'package:Argo/src/utils/hive/adapters.dart';

import 'package:filesize/filesize.dart';

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

// ignore: must_be_immutable
class SeeCard extends Card {
  final Widget child;
  final EdgeInsets margin;
  Color color;
  final Border border;
  final double width;
  final double height;
  final List<Widget> column;
  final EdgeInsets padding;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;

  SeeCard({
    this.width,
    this.height,
    this.margin,
    this.child,
    this.color,
    this.border,
    this.column,
    this.padding,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    if (color == null && userdata.get("theme") == "OLED") {
      color = Colors.black;
    }

    return Container(
      width: width,
      height: height,
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
        child: Container(
          padding: padding,
          child: column != null
              ? Column(
                  mainAxisAlignment: mainAxisAlignment,
                  crossAxisAlignment: crossAxisAlignment,
                  children: column,
                )
              : child,
        ),
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

class AppPage extends StatelessWidget {
  final Widget title;
  final List<Widget> actions;
  final Widget body;
  final PreferredSizeWidget bottom;

  AppPage({this.title, this.actions, this.body, this.bottom});

  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: actions,
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              DrawerStates.layoutKey.currentState.openDrawer();
            },
          ),
          title: title,
          bottom: bottom,
        ),
        body: body,
      );
}

class BijlageItem extends StatelessWidget {
  final Bron bijlage;
  final Function onTap;
  final Border border;

  BijlageItem(this.bijlage, {this.onTap, this.border});
  Widget build(BuildContext context) {
    List<String> splittedNaam = bijlage.naam.split(".");
    return Tooltip(
      child: ListTileBorder(
        onTap: onTap,
        leading: bijlage.isFolder
            ? Icon(Icons.folder_outlined)
            : Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: 5,
                    ),
                    child: Icon(
                      Icons.insert_drive_file_outlined,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: 7.5,
                    ),
                    child: Text(
                      splittedNaam.length > 1 ? splittedNaam.last.toUpperCase() : bijlage.naam,
                      style: TextStyle(
                        fontSize: 12.5,
                      ),
                    ),
                  )
                ],
              ),
        subtitle: bijlage.isFolder
            ? null
            : Padding(
                child: Text(
                  filesize(bijlage.size),
                ),
                padding: EdgeInsets.only(
                  bottom: 5,
                ),
              ),
        title: Padding(
          child: Text(
            splittedNaam.length > 1 ? splittedNaam.take(splittedNaam.length - 1).join(".") : bijlage.naam,
            overflow: TextOverflow.ellipsis,
          ),
          padding: EdgeInsets.symmetric(
            vertical: 10,
          ),
        ),
        trailing: bijlage.isFolder
            ? Icon(
                Icons.arrow_forward_ios,
                size: 14,
              )
            : bijlage.downloadCount == bijlage.size
                ? Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  )
                : bijlage.downloadCount == null
                    ? Icon(
                        Icons.cloud_download,
                        size: 22,
                      )
                    : CircularProgressIndicator(),
        border: border,
      ),
      message: bijlage.naam,
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
  final Border border;

  CijferTile(this.cijfer, {this.isRecent, this.border});

  @override
  Widget build(BuildContext build) {
    return ListTileBorder(
      border: border,
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

class CircleShape extends StatelessWidget {
  final Widget child;

  CircleShape({this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: userdata.get("accentColor")),
      ),
      width: 45,
      height: 45,
      child: Center(
        child: child,
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

class EmptyPage extends StatelessWidget {
  final String text;
  final IconData icon;

  EmptyPage({
    this.text,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: bodyHeight(context),
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 100,
            color: Colors.grey[400],
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}
