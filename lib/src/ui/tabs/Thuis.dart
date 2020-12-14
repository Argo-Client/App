import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:Argo/main.dart';
import 'package:Argo/src/layout.dart';
import 'package:Argo/src/utils/hive/adapters.dart';
import 'package:Argo/src/ui/CustomWidgets.dart';

import 'Agenda.dart';
import 'Berichten.dart';

class Thuis extends StatefulWidget {
  @override
  _Thuis createState() => _Thuis();
}

class _Thuis extends State<Thuis> {
  DateTime now, lastMonday;
  // void afterFirstLayout(BuildContext context) => handleError(account.magister.leermiddelen.refresh, "Fout tijdens verversen van leermiddelen", context);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: PopoutFloat(
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
            "Nieuw bericht",
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
      ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              leading: IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  DrawerStates.layoutKey.currentState.openDrawer();
                },
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
                      child: CircleAvatar(
                        backgroundImage: Image.memory(
                          base64Decode(account.profilePicture),
                        ).image,
                        radius: 35.0,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 7.5),
                      child: Text(
                        account.fullName,
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: Text("${account.klasCode} | ${account.username}"),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: RefreshIndicator(
          child: ValueListenableBuilder(
              valueListenable: updateNotifier,
              builder: (BuildContext context, _, _a) {
                DateTime now = DateTime.now();
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListView(
                    children: [
                      (() {
                        Les nextLesson;
                        DateTime lastMonday = now.subtract(
                          Duration(
                            days: now.weekday - 1,
                          ),
                        );

                        String weekslug = formatDate.format(lastMonday);

                        for (int i = now.weekday - 1; i < 6; i++) {
                          for (Les les in account.lessons[weekslug][i]) {
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
                                title: Text(nextLesson.title),
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
                      })(),
                      (() {
                        if (account.recenteCijfers.isNotEmpty) {
                          List recenteCijfers = account.recenteCijfers
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
                      })(),

                      /// [Recente berichten]
                      (() {
                        if (account.berichten.isNotEmpty) {
                          List berichten = account.berichten
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
                                      ber.afzender,
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
                      })(),
                      (() {
                        if (account.afwezigheid.isNotEmpty) {
                          List afwezigheid = account.afwezigheid
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
                                    subtitle: Text(afw.les.hour + "e - " + afw.les.title),
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
                      })(),
                    ],
                  ),
                );
              }),
          onRefresh: () async {
            await handleError(account.magister.berichten.refresh, "Fout tijdens verversen van vandaag", context);
          },
        ),
      ),
    );
  }
}
