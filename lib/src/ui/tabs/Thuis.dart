import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:argo/src/layout.dart';

import 'package:argo/src/utils/hive/adapters.dart';
import 'package:argo/src/utils/boxes.dart';
import 'package:argo/src/utils/update.dart';
import 'package:argo/src/utils/handleError.dart';
import 'package:argo/src/utils/account.dart';

import 'package:argo/src/ui/components/ContentHeader.dart';

import 'Agenda.dart';
import 'Berichten.dart';
import 'Cijfers.dart';
import 'Studiewijzer.dart';

class FeedItem extends StatelessWidget {
  final List children;
  final String header;

  FeedItem({
    this.children,
    this.header,
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

class PopoutButton {
  final Function onPressed;
  final IconData icon;
  final String text;

  PopoutButton(this.text, {this.onPressed, this.icon});
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
      children: [
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

class Thuis extends StatefulWidget {
  @override
  _Thuis createState() => _Thuis();
}

class _Thuis extends State<Thuis> {
  DateTime lastMonday;

  // void afterFirstLayout(BuildContext context) => handleError(account.magister.leermiddelen.refresh, "Fout tijdens verversen van leermiddelen", context);
  @override
  Widget build(BuildContext context) {
    String username = account().username != null ? " | " + account().username : "";
    String klasCode = account().klasCode ?? "";
    return Scaffold(
      floatingActionButton: shortcutButton(),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              leading: IconButton(
                icon: Icon(Icons.menu),
                onPressed: drawer.openDrawer,
              ),
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                // title: Text(
                //   account.fullName,
                //   style: TextStyle(
                //     fontSize: 16.0,
                //   ),
                // ),
                background: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 15.0),
                      child: () {
                        bool useIcon = userdata.get("useIcon") || account().profilePicture == null;
                        return CircleAvatar(
                          backgroundColor: Theme.of(context).backgroundColor,
                          backgroundImage: useIcon
                              ? null
                              : Image.memory(
                                  base64Decode(account().profilePicture),
                                ).image,
                          child: !useIcon
                              ? null
                              : Icon(
                                  Icons.person_outline,
                                  size: 50,
                                ),
                          radius: 35.0,
                        );
                      }(),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 7.5),
                      child: Text(
                        account().fullName,
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: Text(klasCode + username),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: _page(),
      ),
    );
  }

  Widget shortcutButton() => PopoutFloat(
        icon: AnimatedIcons.menu_close,
        color: ColorTween(
          begin: userdata.get("accentColor"),
          end: Colors.red,
        ),
        children: [
          PopoutButton(
            "Afspraak toevoegen",
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddLesPagina(
                    DateTime.now(),
                  ),
                ),
              );
            },
            icon: Icons.event_outlined,
          ),
          PopoutButton(
            "Bericht opstellen",
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => NieuwBerichtPagina(null),
                ),
              );
            },
            icon: Icons.email,
          ),
        ],
      );

  Widget _page() {
    return RefreshIndicator(
      child: ValueListenableBuilder(
        valueListenable: updateNotifier,
        builder: (BuildContext context, _, _a) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListView(
              children: [
                _volgendeLes(),
                _pinnedItems(),
                _recenteCijfers(),
                _recenteBerichten(),
                _recenteAfwezigheid(),
              ],
            ),
          );
        },
      ),
      onRefresh: () async {
        await handleError(account().magister.berichten.refresh, "Fout tijdens verversen van vandaag", context);
      },
    );
  }

  Widget _pinnedItems() {
    List<List<Wijzer>> pinned = [];
    account().studiewijzers.forEach((hoofdwijzer) {
      if (hoofdwijzer.children != null) {
        pinned.addAll(
          hoofdwijzer.children.where((wijzer) => wijzer.pinned).map((e) => [hoofdwijzer, e]),
        );
      }
    });

    if (pinned.isEmpty) {
      return Container();
    }

    return FeedItem(
      header: "Gepinde items",
      children: [
        for (List<Wijzer> item in pinned.take(5))
          ListTile(
            title: Text(item[1].naam),
            subtitle: Text(item[0].naam),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => StudiewijzerTab(item[1]),
                ),
              );
            },
          )
      ],
    );
  }

  Widget _volgendeLes() {
    DateTime now = DateTime.now();
    Les nextLesson;

    DateTime lastMonday = now.subtract(
      Duration(
        days: now.weekday - 1,
      ),
    );

    String weekslug = formatDate.format(lastMonday);

    for (int i = now.weekday - 1; i < 6; i++) {
      if (account().lessons[weekslug] == null) {
        break;
      }

      for (Les les in account().lessons[weekslug][i]) {
        if (les.startDateTime.isAfter(now) && !les.uitval) {
          nextLesson = les;
          break;
        }
      }
      if (nextLesson != null) break;
    }

    if (nextLesson != null)
      return FeedItem(
        header: "Volgende les",
        children: [
          ListTile(
            title: Text(nextLesson.getName()),
            trailing: nextLesson.infoType != ""
                ? Material(
                    child: Padding(
                      child: Text(
                        nextLesson.infoType,
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      padding: EdgeInsets.all(4.5),
                    ),
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    color: userdata.get("accentColor"),
                  )
                : nextLesson.huiswerk != null
                    ? !nextLesson.huiswerkAf
                        ? Icon(
                            Icons.assignment_outlined,
                            size: 23,
                            color: Colors.grey,
                          )
                        : Icon(
                            Icons.assignment_turned_in_outlined,
                            size: 23,
                            color: Colors.green,
                          )
                    : null,
            subtitle: Text(
              nextLesson.information,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => LesPagina(nextLesson),
                ),
              );
            },
          )
        ],
      );
    else
      return Container();
  }

  Widget _recenteCijfers() {
    DateTime now = DateTime.now();

    if (account().recenteCijfers.isNotEmpty) {
      List recenteCijfers = account()
          .recenteCijfers
          .take(3)
          .where(
            (cijf) => cijf.ingevoerd.isAfter(
              now.subtract(
                Duration(
                  days: 3,
                ),
              ),
            ),
          )
          .toList();

      if (recenteCijfers.isNotEmpty)
        return FeedItem(
          header: "Recente cijfers",
          children: [
            for (Cijfer cijf in recenteCijfers)
              Stack(
                children: [
                  CijferTile(cijf, isRecent: true),
                ],
              ),
          ],
        );
    }

    return Container();
  }

  Widget _recenteAfwezigheid() {
    DateTime now = DateTime.now();
    if (account().afwezigheid.isNotEmpty) {
      List afwezigheid = account()
          .afwezigheid
          .take(3)
          .where(
            (afw) => afw.date.isAfter(
              now.subtract(
                Duration(
                  days: 3,
                ),
              ),
            ),
          )
          .toList();

      if (afwezigheid.isNotEmpty)
        return FeedItem(
          header: "Recente afwezigheid",
          children: [
            for (Absentie afw in afwezigheid)
              ListTile(
                trailing: Padding(
                  child: afw.geoorloofd
                      ? Icon(
                          Icons.check,
                          color: Colors.green,
                        )
                      : Icon(
                          Icons.error_outlined,
                          color: Colors.redAccent,
                        ),
                  padding: EdgeInsets.only(
                    top: 7,
                    left: 7,
                  ),
                ),
                subtitle: Text(afw.les.hour + "e - " + afw.les.getName()),
                title: Text(afw.type),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => LesPagina(afw.les),
                    ),
                  );
                },
              ),
          ],
        );
    }

    return Container();
  }

  Widget _recenteBerichten() {
    DateTime now = DateTime.now();
    if (account().berichten.isNotEmpty) {
      List berichten = account()
          .berichten
          .take(3)
          .where(
            (ber) => ber.date.isAfter(
              now.subtract(
                Duration(
                  days: 3,
                ),
              ),
            ),
          )
          .toList();

      if (berichten.isNotEmpty)
        return FeedItem(
          header: "Recente berichten",
          children: [
            for (Bericht ber in berichten)
              ListTile(
                title: Text(
                  ber.onderwerp,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: ber.prioriteit
                    ? Icon(
                        Icons.error,
                        color: Colors.redAccent,
                      )
                    : null,
                subtitle: Text(
                  ber.afzender.naam,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BerichtPagina(ValueNotifier(ber)),
                    ),
                  );
                },
              ),
          ],
        );
    }

    return Container();
  }
}
