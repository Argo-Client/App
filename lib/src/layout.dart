import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:after_layout/after_layout.dart';

import 'package:argo/main.dart';
import 'package:argo/src/utils/update.dart';
import 'package:argo/src/utils/account.dart';
import 'package:argo/src/utils/flushbar.dart';

import 'package:argo/src/utils/hive/adapters.dart';
import 'utils/boxes.dart';

import 'ui/Introduction.dart';
import 'utils/login.dart' as login;
import 'utils/tabs.dart';

class DrawerTools {
  final GlobalKey<ScaffoldState> key = GlobalKey();

  bool closeDrawer(BuildContext context) {
    if (key.currentState.isDrawerOpen) {
      Navigator.of(context).pop();
      return true;
    }
    return false;
  }

  void openDrawer() {
    key.currentState.openDrawer();
  }
}

DrawerTools drawer = DrawerTools();

class HomeState extends State<Home> with AfterLayoutMixin<Home> {
  static const defaultIndex = 1; // Agenda

  final tabs = Tabs(account()).children;

  final currentTab = ValueNotifier<TabItem>(null);
  final currentAccount = ValueNotifier(account());
  final accountsOpen = ValueNotifier(false);
  DateTime lastPopped;

  void afterFirstLayout(BuildContext context) {
    if (!userdata.containsKey("introduction")) {
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => App()));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Introduction()));
    }
  }

  HomeState() {
    if (tabs.isNotEmpty) {
      currentTab.value = tabs[defaultIndex];
    }

    currentTab.addListener(() {
      drawer.closeDrawer(context);
    });
  }

  void changeAccount(int id) {
    int index = accounts.toMap().entries.firstWhere((g) => g.value.id == id).key;
    if (userdata.get("accountIndex") != index) {
      userdata.put("accountIndex", index);
      update();
      currentAccount.value = account();
    }
  }

  void setStateAccountList() {
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    currentAccount.notifyListeners();
  }

  Widget _buildTabListTile(TabItem tab) {
    return ValueListenableBuilder<TabItem>(
      valueListenable: currentTab,
      builder: (context, current, _) {
        return ListTile(
          selected: tab == current,
          leading: userdata.get("colorsInDrawer")
              ? Material(
                  // padding: EdgeInsets.all(7.5),
                  child: Padding(
                    child: Icon(
                      tab.icon,
                      color: userdata.get("colorsInDrawer") ? Colors.white : null,
                    ),
                    padding: EdgeInsets.all(5.5),
                  ),
                  shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  color: tab.color,
                )
              : Icon(
                  tab.icon,
                ),
          title: Text(tab.name),
          onTap: () {
            currentTab.value = tab;
          },
        );
      },
    );
  }

  Widget _buildAccountListTile(Account acc) {
    return ListTile(
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
                  body: login.RefreshAccountView(acc, context, (account, context) async {
                    update();
                    successFlushbar(context, "$acc is ververst!");
                    await acc.magister.downloadProfilePicture();
                    setStateAccountList();
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
                    child: Text("Verwijder"),
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

                      if (acc.id == currentAccount.value.id) {
                        userdata.put("accountIndex", accounts.keys.first);
                        currentAccount.value = account();
                      }

                      setStateAccountList();
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
            child: Text('Verwijder'),
          ),
          const PopupMenuItem(
            value: "herlaad",
            child: Text('Herlaad'),
          ),
        ],
      ),
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).backgroundColor,
        backgroundImage: !userdata.get("useIcon") && acc.profilePicture != null ? Image.memory(base64Decode(acc.profilePicture)).image : null,
        child: userdata.get("useIcon")
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
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentAccount.value == null) {
      return Scaffold();
    }

    return WillPopScope(
      onWillPop: () {
        if (lastPopped != null && userdata.get("doubleBackAgenda")) {
          if (lastPopped.isAfter(DateTime.now().subtract(Duration(milliseconds: 500)))) {
            currentTab.value = tabs[defaultIndex];

            return Future.value(false);
          }
        }
        lastPopped = DateTime.now();

        if (!drawer.closeDrawer(context)) {
          if (!userdata.get("backOpensDrawer") || currentTab.value.overridesPop) return Future.value(true);
          drawer.openDrawer();
        }
        return Future.value(false);
      },
      child: Scaffold(
        key: drawer.key,
        body: ValueListenableBuilder<TabItem>(
          valueListenable: currentTab,
          builder: (context, tab, _) => tab.page,
        ),
        drawer: Drawer(
          child: Container(
            color: userdata.get("theme") == "OLED" ? Colors.black : null,
            child: ValueListenableBuilder<Account>(
                valueListenable: currentAccount,
                builder: (context, account, _) {
                  return ListView(
                    padding: EdgeInsets.all(0),
                    children: [
                      UserAccountsDrawerHeader(
                        onDetailsPressed: () => accountsOpen.value = !accountsOpen.value,
                        otherAccountsPictures: accounts.values
                            .where((acc) => account.id != acc.id)
                            .map((acc) => InkWell(
                                  onTap: () => changeAccount(acc.id),
                                  child: CircleAvatar(
                                    backgroundColor: Theme.of(context).backgroundColor,
                                    backgroundImage: !userdata.get("useIcon") && acc.profilePicture != null ? Image.memory(base64Decode(acc.profilePicture)).image : null,
                                    child: userdata.get("useIcon")
                                        ? Icon(
                                            Icons.person,
                                            size: 25,
                                          )
                                        : null,
                                  ),
                                ))
                            .toList(),
                        accountName: Text(account.fullName),
                        accountEmail: Text(account.klasCode),
                        currentAccountPicture: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircleAvatar(
                              backgroundColor: Theme.of(context).backgroundColor,
                              backgroundImage: !userdata.get("useIcon")
                                  ? Image.memory(
                                      base64Decode(account.profilePicture),
                                    ).image
                                  : null,
                              child: userdata.get("useIcon")
                                  ? Icon(
                                      Icons.person_outline,
                                      size: 50,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      ValueListenableBuilder(
                        valueListenable: accountsOpen,
                        builder: (context, open, _) {
                          if (open) {
                            return Column(
                              children: [
                                ...accounts.values.map((acc) => _buildAccountListTile(acc)).toList(),
                                ListTile(
                                  leading: Icon(Icons.add_outlined),
                                  title: Text("Account toevoegen"),
                                  onTap: () {
                                    login.MagisterLogin().launch(context, (Account newAccount, context, {String error}) async {
                                      setStateAccountList();
                                    }, title: "Nieuw Account");
                                  },
                                )
                              ],
                            );
                          }
                          return ListTileTheme(
                            style: ListTileStyle.drawer,
                            selectedColor: userdata.get('accentColor'),
                            child: Column(
                              children: [
                                for (var tab in tabs) ...[
                                  _buildTabListTile(tab),
                                  if (tab.dividerBelow) Divider(),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }),
          ),
        ),
      ),
    );
  }
}
