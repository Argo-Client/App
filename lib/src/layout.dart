import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:after_layout/after_layout.dart';
import 'package:flushbar/flushbar_helper.dart';

import 'package:argo/main.dart';
import 'package:argo/src/utils/update.dart';
import 'package:argo/src/utils/account.dart';

import 'package:argo/src/utils/hive/adapters.dart';
import 'utils/boxes.dart';

import 'ui/Introduction.dart';
import 'utils/login.dart' as login;
import 'utils/tabs.dart';

int _currentIndex = 1;

class DrawerStates {
  static GlobalKey<ScaffoldState> layoutKey = new GlobalKey<ScaffoldState>();
  static GlobalKey<State> drawerState = new GlobalKey<State>();
}

class HomeState extends State<Home> with AfterLayoutMixin<Home> {
  bool _detailsPressed = false;
  void afterFirstLayout(BuildContext context) {
    if (!userdata.containsKey("introduction")) {
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => App()));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Introduction()));
    }
  }

  void changeIndex(int index) {
    _currentIndex = index;
    // homeState.setState(() {});
    Navigator.pop(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (account() == null) {
      return Scaffold();
    }
    List<Map> children = Tabs(account()).children;
    var child = children[_currentIndex];
    bool useIcon = userdata.get("useIcon");
    void changeAccount(int id) {
      int index = accounts.toMap().entries.firstWhere((g) => g.value.id == id).key;
      if (userdata.get("accountIndex") != index) {
        setState(() {
          userdata.put("accountIndex", index);
          update();
        });
      }
    }

    final List<Widget> _accountsDrawer = [
      for (Account acc in accounts.toMap().values)
        ListTile(
          trailing: PopupMenuButton(
            onSelected: (result) async {
              if (result == "herlaad") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: Text("Verversen"),
                      ),
                      body: login.RefreshAccountView(account(), context, (account, context) async {
                        update();
                        FlushbarHelper.createSuccess(message: "$acc is ververst!")..show(context);
                        await acc.magister.downloadProfilePicture();
                        setState(() {});
                      }),
                    ),
                  ),
                );
              } else {
                showDialog(
                  builder: (BuildContext context) => AlertDialog(
                    title: Text("Weet je het zeker?"),
                    content: Text("Als je het account verwijderd, moet je weer opnieuw inloggen om hem te kunnen gebruiken."),
                    actions: [
                      TextButton(
                        child: Text("Annuleer"),
                        onPressed: () => Navigator.pop(context),
                      ),
                      TextButton(
                        child: Text("Verwijderen"),
                        onPressed: () {
                          Navigator.pop(context);
                          accounts.delete(accounts.toMap().entries.firstWhere((a) => a.value.id == acc.id).key);
                          if (accounts.isEmpty) {
                            accounts.clear();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Introduction(),
                              ),
                            );
                            return;
                          }
                          userdata.put("accountsIndex", accounts.toMap().entries.first.key);
                          setState(() {});
                        },
                      )
                    ],
                  ),
                  context: context,
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              const PopupMenuItem(
                value: "verwijder",
                child: Text('Verwijderen'),
              ),
              const PopupMenuItem(
                value: "herlaad",
                child: Text('Herladen'),
              ),
            ],
          ),
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).backgroundColor,
            backgroundImage: !useIcon && acc.profilePicture != null ? Image.memory(base64Decode(acc.profilePicture)).image : null,
            child: useIcon
                ? Icon(
                    Icons.person,
                    size: 25,
                  )
                : null,
          ),
          title: Text(
            acc.fullName,
          ),
          subtitle: Text(
            acc.klasCode,
          ),
          onTap: () => changeAccount(acc.id),
        ),
      ListTile(
        leading: Icon(Icons.add_outlined),
        title: Text("Account toevoegen"),
        onTap: () {
          login.MagisterLogin().launch(context, (Account newAccount, context, {String error}) async {
            setState(() {});
          }, title: "Nieuw Account");
        },
      ),
    ];

    final List<Widget> _drawer = [];

    for (int i = 0; i < children.length; i++) {
      if (children[i]["divider"] ?? false) {
        _drawer.add(Divider());
      } else {
        _drawer.add(
          ListTile(
            selected: i == _currentIndex,
            leading: userdata.get("colorsInDrawer")
                ? Material(
                    // padding: EdgeInsets.all(7.5),
                    child: Padding(
                      child: Icon(
                        children[i]["icon"],
                        color: userdata.get("colorsInDrawer") ? Colors.white : null,
                      ),
                      padding: EdgeInsets.all(5.5),
                    ),
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    color: children[i]["color"],
                  )
                : Icon(
                    children[i]["icon"],
                  ),
            title: children[i]["name"],
            onTap: () {
              changeIndex(i);
            },
          ),
        );
      }
    }

    DateTime lastPopped;
    return WillPopScope(
      onWillPop: () {
        if (lastPopped != null && userdata.get("doubleBackAgenda")) {
          if (lastPopped.isAfter(DateTime.now().subtract(Duration(milliseconds: 500)))) {
            changeIndex(1);
            if (DrawerStates.layoutKey.currentState.isDrawerOpen) {
              Navigator.of(context).pop();
            }
            return Future.value(false);
          }
        }
        lastPopped = DateTime.now();
        if (!userdata.get("backOpensDrawer") || child["overridePop"] != null) return Future.value(true);
        if (DrawerStates.layoutKey.currentState.isDrawerOpen) {
          Navigator.of(context).pop();
        } else {
          DrawerStates.layoutKey.currentState.openDrawer();
        }
        return Future.value(false);
      },
      child: Scaffold(
        key: DrawerStates.layoutKey,
        body: child["page"],
        drawer: Drawer(
          child: Container(
            color: userdata.get("theme") == "OLED" ? Colors.black : null,
            child: ListView(
              padding: EdgeInsets.all(0),
              children: [
                UserAccountsDrawerHeader(
                  onDetailsPressed: () => {
                    DrawerStates.drawerState.currentState.setState(
                      () {
                        _detailsPressed = !_detailsPressed;
                      },
                    ),
                  },
                  otherAccountsPictures: [
                    for (Account acc in accounts.toMap().values)
                      if (acc.id != account().id)
                        InkWell(
                          onTap: () => changeAccount(acc.id),
                          child: CircleAvatar(
                            backgroundColor: Theme.of(context).backgroundColor,
                            backgroundImage: !useIcon && acc.profilePicture != null ? Image.memory(base64Decode(acc.profilePicture)).image : null,
                            child: useIcon
                                ? Icon(
                                    Icons.person,
                                    size: 25,
                                  )
                                : null,
                          ),
                        ),
                  ],
                  accountName: Text(account().fullName),
                  accountEmail: Text(account().klasCode),
                  currentAccountPicture: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).backgroundColor,
                        backgroundImage: !useIcon
                            ? Image.memory(
                                base64Decode(account().profilePicture),
                              ).image
                            : null,
                        child: useIcon
                            ? Icon(
                                Icons.person_outline,
                                size: 50,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
                StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Container(
                      child: _detailsPressed
                          ? Column(children: _accountsDrawer)
                          : ListTileTheme(
                              style: ListTileStyle.drawer,
                              selectedColor: userdata.get('accentColor'),
                              child: Column(
                                children: _drawer,
                              ),
                            ),
                    );
                  },
                  key: DrawerStates.drawerState,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
