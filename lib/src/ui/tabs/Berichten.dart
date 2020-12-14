import 'package:flutter/material.dart';

import 'package:after_layout/after_layout.dart';
import 'package:futuristic/futuristic.dart';
import 'package:dio/dio.dart';

import 'package:Argo/main.dart';
import 'package:Argo/src/layout.dart';
import 'package:Argo/src/utils/hive/adapters.dart';
import 'package:Argo/src/ui/CustomWidgets.dart';

class Berichten extends StatefulWidget {
  @override
  _Berichten createState() => _Berichten();
}

class _Berichten extends State<Berichten> with AfterLayoutMixin<Berichten> {
  void afterFirstLayout(BuildContext context) => handleError(account.magister.berichten.refresh, "Fout tijdens verversen van berichten", context);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            DrawerStates.layoutKey.currentState.openDrawer();
          },
        ),
        title: Text("Berichten"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => NieuwBerichtPagina(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        child: ValueListenableBuilder(
          valueListenable: updateNotifier,
          builder: (BuildContext context, box, Widget child) {
            List<Widget> berichten = [];
            String lastDay;
            for (int i = 0; i < account.berichten.length; i++) {
              ValueNotifier<Bericht> ber = ValueNotifier(account.berichten[i]);
              if (lastDay != ber.value.dag) {
                berichten.add(
                  ContentHeader(ber.value.dag),
                );
              }
              berichten.add(
                SeeCard(
                  border: account.berichten.length - 1 == i || account.berichten[i + 1].dag != ber.value.dag
                      ? null
                      : Border(
                          bottom: greyBorderSide(),
                        ),
                  child: Stack(
                    children: [
                      ValueListenableBuilder(
                        valueListenable: ber,
                        builder: (c, ber, _) {
                          if (ber.read)
                            return Container();
                          else
                            return Padding(
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: userdata.get("accentColor"),
                                  ),
                                ),
                              ),
                              padding: EdgeInsets.all(
                                10,
                              ),
                            );
                        },
                      ),
                      ListTile(
                        trailing: Padding(
                          child: ber.value.prioriteit ? Icon(Icons.error, color: Colors.redAccent) : null,
                          padding: EdgeInsets.only(
                            top: 7,
                            left: 7,
                          ),
                        ),
                        subtitle: Text(
                          ber.value.afzender,
                        ),
                        title: Text(
                          ber.value.onderwerp,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => BerichtPagina(ber),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
              lastDay = ber.value.dag;
            }
            return buildLiveList(berichten, 10);
          },
        ),
        onRefresh: () async {
          await handleError(account.magister.berichten.refresh, "Kon berichten niet verversen", context);
        },
      ),
    );
  }
}

class BerichtPagina extends StatelessWidget {
  final ValueNotifier<Bericht> ber;
  const BerichtPagina(this.ber);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ber.value.onderwerp,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.reply),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => NieuwBerichtPagina(ber.value),
                ),
              );
            },
          ),
        ],
      ),
      body: Futuristic(
        autoStart: true,
        futureBuilder: () async {
          if (ber.value.inhoud != null) {
            List returnable = [ber.value];
            if (ber.value.heeftBijlagen && ber.value.bijlagen != null) {
              returnable.add(ber.value.bijlagen);
            }
            return Future.value(returnable);
          }
          return Future.wait([
            account.magister.berichten.getBerichtFrom(ber.value),
            if (ber.value.heeftBijlagen) account.magister.berichten.bijlagen(ber.value),
          ]);
        },
        onData: (bericht) {
          ber.value.read = bericht[0].read;
          // ignore: invalid_use_of_visible_for_testing_member,invalid_use_of_protected_member
          ber.notifyListeners();
        },
        busyBuilder: (context) => Center(
          child: CircularProgressIndicator(),
        ),
        onError: (error, retry) {
          if (!(error is DioError)) throw (error);
        },
        errorBuilder: (context, error, retry) {
          if (!(error is DioError))
            return Text("Dit zou je nooit moeten zien, error: \n\n $error");
          else
            return RefreshIndicator(
              onRefresh: () async => retry(),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width - 50,
                    height: bodyHeight(context),
                    child: Text(
                      "Kon geen verbinding maken met Magister:\n${(error as dynamic).error.toString()}",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            );
        },
        dataBuilder: (context, data) {
          Bericht ber = data[0];
          List<Bron> bijlagen;
          if (ber.heeftBijlagen) {
            bijlagen = data[1];
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                SeeCard(
                  margin: EdgeInsets.only(
                    bottom: 20,
                    top: 0,
                    left: 0,
                    right: 0,
                  ),
                  column: [
                    if (ber.afzender != null)
                      ListTileBorder(
                        border: Border(
                          bottom: greyBorderSide(),
                        ),
                        leading: Padding(
                          child: Icon(
                            Icons.person_outlined,
                          ),
                          padding: EdgeInsets.only(
                            top: 7,
                            left: 7,
                          ),
                        ),
                        title: Text(
                          ber.afzender,
                        ),
                        subtitle: Text(
                          "Afzender",
                        ),
                      ),
                    if (ber.dag != null)
                      ListTileBorder(
                        border: Border(
                          bottom: greyBorderSide(),
                        ),
                        leading: Padding(
                          child: Icon(
                            Icons.send,
                          ),
                          padding: EdgeInsets.only(
                            top: 7,
                            left: 7,
                          ),
                        ),
                        title: Text(
                          ber.dag,
                        ),
                        subtitle: Text(
                          "Verzonden",
                        ),
                      ),
                    if (ber.ontvangers != null)
                      ListTileBorder(
                        border: ber.cc == null
                            ? null
                            : Border(
                                bottom: greyBorderSide(),
                              ),
                        leading: Padding(
                          child: Icon(
                            Icons.people_outlined,
                          ),
                          padding: EdgeInsets.only(
                            top: 7,
                            left: 7,
                          ),
                        ),
                        title: Text(
                          ber.ontvangers.take(10).join(", "),
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: ber.ontvangers.length > 3
                            ? () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ShowPeopleList(
                                      ber.ontvangers,
                                      title: "Ontvangers",
                                    ),
                                  ),
                                );
                              }
                            : null,
                        subtitle: Text(
                          "Ontvanger(s)",
                        ),
                      ),
                    if (ber.cc != null)
                      ListTile(
                        leading: Padding(
                          child: Icon(
                            Icons.people_outline,
                          ),
                          padding: EdgeInsets.only(
                            top: 7,
                            left: 7,
                          ),
                        ),
                        title: Text(
                          ber.cc.take(5).join(', '),
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          "CC",
                        ),
                        onTap: ber.cc.length > 3
                            ? () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ShowPeopleList(
                                      ber.cc,
                                      title: "Ontvangers",
                                    ),
                                  ),
                                );
                              }
                            : null,
                      ),
                  ],
                ),
                if (ber.inhoud != null && ber.inhoud.replaceAll(RegExp("<[^>]*>"), "").isNotEmpty)
                  SeeCard(
                    child: Container(
                      padding: EdgeInsets.all(
                        20,
                      ),
                      child: Column(
                        children: [
                          WebContent(
                            ber.inhoud,
                          ),
                        ],
                      ),
                    ),
                  ),
                if (ber.heeftBijlagen)
                  SeeCard(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    margin: EdgeInsets.only(top: 20),
                    column: [
                      Padding(
                        padding: EdgeInsets.only(
                          top: 20,
                          left: 20,
                          bottom: 10,
                        ),
                        child: Text(
                          "Bijlagen",
                          style: TextStyle(
                            fontSize: 23,
                          ),
                        ),
                      ),
                      for (Bron bron in bijlagen)
                        BijlageItem(
                          bron,
                          onTap: () {
                            account.magister.bronnen.downloadFile(bron, (_, _a) {});
                          },
                          border: bijlagen.last != bron
                              ? Border(
                                  bottom: greyBorderSide(),
                                )
                              : null,
                        )
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class NieuwBerichtPagina extends StatelessWidget {
  final Bericht ber;
  const NieuwBerichtPagina([this.ber]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Nieuw bericht",
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          child: Column(
            children: [
              SeeCard(
                column: [
                  ListTileBorder(
                    border: Border(
                      bottom: greyBorderSide(),
                    ),
                    leading: Icon(Icons.person_outlined),
                    title: TextFormField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintText: 'Aan',
                      ),
                      initialValue: ber != null ? ber.afzender : null,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Veld verplicht';
                        }
                        return null;
                      },
                    ),
                  ),
                  ListTileBorder(
                    border: Border(
                      bottom: greyBorderSide(),
                    ),
                    leading: Icon(Icons.people_outlined),
                    title: TextFormField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintText: 'CC',
                      ),
                      initialValue: ber?.cc?.join(', '),
                    ),
                  ),
                  ListTileBorder(
                    border: Border(
                      bottom: greyBorderSide(),
                    ),
                    leading: Icon(Icons.people_outlined),
                    title: TextFormField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintText: 'BCC',
                      ),
                      initialValue: ber?.cc?.join(', '),
                    ),
                  ),
                  ListTileBorder(
                    border: Border(
                      bottom: greyBorderSide(),
                    ),
                    leading: Icon(Icons.subject),
                    title: TextFormField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintText: 'Onderwerp',
                      ),
                      initialValue: ber != null ? "RE: " + ber.onderwerp : null,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Veld verplicht';
                        }
                        return null;
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.edit),
                    title: TextFormField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 25,
                      scrollPadding: EdgeInsets.all(20.0),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintText: 'Inhoud',
                      ),
                      // validator: validator,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        children: [
          Spacer(
            flex: 1,
          ),
          Padding(
            child: FloatingActionButton(
              onPressed: () async {
                // FilePickerResult result = await FilePicker.platform.pickFiles(
                //   allowMultiple: true,
                // );

                // if (result != null) {
                //   List<File> files = result.paths.map((path) => File(path)).toList();
                // } else {
                //   // User canceled the picker
                // }
              },
              child: Icon(
                Icons.attach_file,
                color: Colors.white,
              ),
            ),
            padding: EdgeInsets.only(
              bottom: 10,
            ),
          ),
          FloatingActionButton(
            heroTag: "VerzendBericht",
            onPressed: () {
              /// [SAM] fix dit
            },
            child: Icon(
              Icons.send,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
