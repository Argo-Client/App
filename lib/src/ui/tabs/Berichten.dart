import 'package:flutter/material.dart';

import 'package:after_layout/after_layout.dart';
import 'package:futuristic/futuristic.dart';

import 'package:argo/src/utils/hive/adapters.dart';
import 'package:argo/src/utils/boxes.dart';
import 'package:argo/src/utils/handleError.dart';
import 'package:argo/src/utils/account.dart';
import 'package:argo/src/utils/flushbar.dart';
import 'package:argo/src/utils/magister/Berichten.dart';

import 'package:argo/src/ui/components/Card.dart';
import 'package:argo/src/ui/components/PeopleList.dart';
import 'package:argo/src/ui/components/AppPage.dart';
import 'package:argo/src/ui/components/WebContent.dart';
import 'package:argo/src/ui/components/Bijlage.dart';
import 'package:argo/src/ui/components/EmptyPage.dart';
import 'package:argo/src/ui/components/ContentHeader.dart';
import 'package:argo/src/ui/components/Refreshable.dart';
import 'package:argo/src/ui/components/ListTileDivider.dart';

class Berichten extends StatefulWidget {
  @override
  _Berichten createState() => _Berichten();
}

class _Berichten extends State<Berichten> with AfterLayoutMixin<Berichten> {
  void afterFirstLayout(BuildContext context) => handleError(account().magister.berichten.refresh, "Fout tijdens verversen van berichten", context);

  Widget _buildBericht(ValueNotifier<Bericht> ber) {
    return MaterialCard(
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
              ber.value.afzender.naam,
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
    );
  }

  Widget _buildBerichten(BuildContext context) {
    if (account().berichten.isEmpty) {
      return EmptyPage(
        text: "Geen berichten",
        icon: Icons.email_outlined,
      );
    }

    Map<String, List<Bericht>> berichtenPerDay = {};
    List<Widget> berichtenWidgets = [];

    for (var bericht in account().berichten) {
      berichtenPerDay[bericht.dag] ??= [];
      berichtenPerDay[bericht.dag].add(bericht);
    }

    berichtenPerDay.entries.forEach((day) {
      berichtenWidgets.addAll(
        [
          ContentHeader(day.key),
          ...divideListTiles(
            day.value
                .map(
                  (bericht) => _buildBericht(ValueNotifier(bericht)),
                )
                .toList(),
          ),
        ],
      );
    });

    return ListView(
      children: berichtenWidgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
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
      body: Refreshable(
        builder: _buildBerichten,
        onRefresh: account().magister.berichten.refresh,
        type: "berichten",
      ),
    );
  }
}

class BerichtPagina extends StatelessWidget {
  final ValueNotifier<Bericht> ber;

  const BerichtPagina(this.ber);

  Widget _afzender(String afzender) {
    return ListTile(
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
        afzender,
      ),
      subtitle: Text(
        "Afzender",
      ),
    );
  }

  Widget _dag(String dag) {
    return ListTile(
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
        dag,
      ),
      subtitle: Text(
        "Verzonden",
      ),
    );
  }

  Widget _ontvangers(BuildContext context, Bericht bericht) {
    return ListTile(
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
        bericht.ontvangers.take(10).join(", "),
        overflow: TextOverflow.ellipsis,
      ),
      onTap: bericht.ontvangers.length > 3
          ? () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PeopleList(
                    bericht.ontvangers,
                    title: "Ontvangers",
                  ),
                ),
              );
            }
          : null,
      subtitle: Text(
        "Ontvanger(s)",
      ),
    );
  }

  Widget _cc(BuildContext context, List<Contact> cc) {
    return ListTile(
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
        cc.take(5).join(', '),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        "CC",
      ),
      onTap: cc.length > 3
          ? () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PeopleList(
                    cc,
                    title: "Ontvangers",
                  ),
                ),
              );
            }
          : null,
    );
  }

  Widget _bijlagen(List<Bron> bijlagen) {
    return MaterialCard(
      crossAxisAlignment: CrossAxisAlignment.start,
      margin: EdgeInsets.only(top: 20),
      children: [
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
        ...divideListTiles(
          bijlagen
              .map((bijlage) => BijlageItem(
                    bijlage,
                    download: account().magister.bronnen.downloadFile,
                  ))
              .toList(),
        )
      ],
    );
  }

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
            account().magister.berichten.getBerichtFrom(ber.value),
            if (ber.value.heeftBijlagen) account().magister.berichten.bijlagen(ber.value),
          ]);
        },
        onData: (bericht) {
          ber.value.read = bericht[0].read;
        },
        busyBuilder: (context) => Center(
          child: CircularProgressIndicator(),
        ),
        onError: (error, retry) => print(error),
        errorBuilder: (context, dynamic error, retry) {
          return RefreshIndicator(
            onRefresh: () async => retry(),
            child: EmptyPage(
              icon: Icons.wifi_off_outlined,
              text: error?.error ?? error?.toString() ?? error.message ?? error,
            ),
          );
        },
        dataBuilder: (context, data) {
          Bericht ber = data[0];

          return ListView(
            children: [
              MaterialCard(
                margin: EdgeInsets.only(
                  bottom: 20,
                  top: 0,
                  left: 0,
                  right: 0,
                ),
                children: divideListTiles([
                  if (ber.afzender.naam != null) _afzender(ber.afzender.naam),
                  if (ber.dag != null) _dag(ber.dag),
                  if (ber.ontvangers != null && ber.ontvangers.isNotEmpty) _ontvangers(context, ber),
                  if (ber.cc != null) _cc(context, ber.cc),
                ]),
              ),
              if (ber.inhoud != null && ber.inhoud.replaceAll(RegExp("<[^>]*>"), "").isNotEmpty)
                MaterialCard(
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
              if (ber.heeftBijlagen) _bijlagen(data[1]),
            ],
          );
        },
      ),
    );
  }
}

class NieuwBerichtPagina extends StatefulWidget {
  final Bericht ber;

  const NieuwBerichtPagina([this.ber]);

  @override
  _NieuwBerichtPaginaState createState() => _NieuwBerichtPaginaState(ber);
}

class _NieuwBerichtPaginaState extends State<NieuwBerichtPagina> {
  final Bericht ber;
  final ValueNotifier<List<Contact>> to = ValueNotifier([]);

  final subjectController = TextEditingController();
  final contentController = TextEditingController();

  _NieuwBerichtPaginaState([this.ber]) {
    if (this.ber != null) {
      to.value = [ber.afzender];
      subjectController.text = "RE: " + ber.onderwerp;
    }
  }

  Widget _buildAutoComplete({
    void Function(QueryResponse item) onSelected,
  }) {
    final ValueNotifier<Iterable<QueryResponse>> results = ValueNotifier(Iterable.empty());

    return Stack(
      children: [
        TextField(
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Zoek een leerling of personeel",
          ),
          onChanged: (updated) async {
            results.value = await account().magister.berichten.search(updated);
          },
        ),
        Stack(
          children: [
            ValueListenableBuilder(
              valueListenable: results,
              builder: (context, _, _a) {
                return Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Column(
                    children: [
                      for (var result in results.value)
                        MaterialCard(
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                result.initials.replaceAll(".", "") ?? '',
                              ),
                              backgroundColor: userdata.get("accentColor"),
                            ),
                            onTap: () {
                              onSelected(result);
                            },
                            title: Text("${result.firstname ?? result.initials} ${result.tussenvoegsel != null ? result.tussenvoegsel + " " : ""}${result.lastname}"),
                            subtitle: Text(result.klas ?? ""),
                          ),
                        ),
                    ],
                  ),
                );
              },
            )
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Nieuw bericht",
        ),
      ),
      body: Form(
        child: MaterialCard(
          child: ListView(
            children: divideListTiles([
              ValueListenableBuilder<List<Contact>>(
                valueListenable: to,
                builder: (context, persons, _a) {
                  return Row(
                    children: persons
                        .map(
                          (person) => ElevatedButton(
                            onPressed: () {
                              to.value = List.from(to.value)..removeWhere((other) => other.id == person.id);
                            },
                            child: Text(person.naam),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.person_outlined),
                title: _buildAutoComplete(onSelected: (person) {
                  to.value = List.from(to.value)..add(person.toContact());
                }),
                // title: Autocomplete<QueryResponse>(
                //   onSelected: (person) {
                //     to.value = List.from(to.value)..add(person.toContact());
                //   },
                //   optionsBuilder: (textValues) {
                //     String query = textValues.text.trim().toLowerCase();
                //     account().magister.berichten.search(query);

                //     var queryCache = account().magister.berichten.queryCache;
                //     bool hasKey = queryCache.containsKey(query);
                //     var cached = queryCache[hasKey ? query : query.replaceFirst(RegExp(".\$"), "")];

                //     return (cached ?? []).where(
                //       (person) => !to.value.any((other) => other.id == person.id),
                //     );
                //   },
                // ),
              ),
              // ListTile(
              //   leading: Icon(Icons.people_outlined),
              //   title: TextFormField(
              //     decoration: InputDecoration(
              //       border: InputBorder.none,
              //       focusedBorder: InputBorder.none,
              //       enabledBorder: InputBorder.none,
              //       disabledBorder: InputBorder.none,
              //       hintText: 'CC',
              //     ),
              //     initialValue: ber?.cc?.join(', '),
              //   ),
              // ),
              // ListTile(
              //   leading: Icon(Icons.people_outlined),
              //   title: TextFormField(
              //     decoration: InputDecoration(
              //       border: InputBorder.none,
              //       focusedBorder: InputBorder.none,
              //       enabledBorder: InputBorder.none,
              //       disabledBorder: InputBorder.none,
              //       hintText: 'BCC',
              //     ),
              //     initialValue: ber?.cc?.join(', '),
              //   ),
              // ),
              ListTile(
                leading: Icon(Icons.subject),
                title: TextFormField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    hintText: 'Onderwerp',
                  ),
                  controller: subjectController,
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
                  controller: contentController,
                  // validator: validator,
                ),
              ),
            ]),
          ),
        ),
      ),
      floatingActionButton: Futuristic<void>(
        futureBuilder: () => account().magister.berichten.send(
              to: to.value,
              subject: subjectController.text,
              content: contentController.text,
            ),
        initialBuilder: (context, send) => FloatingActionButton(
          heroTag: "VerzendBericht",
          onPressed: () {
            if (to.value.isNotEmpty) {
              send();
            }
          },
          child: Icon(
            Icons.send,
            color: Colors.white,
          ),
        ),
        busyBuilder: (context) => FloatingActionButton(
          onPressed: () {},
          child: CircularProgressIndicator(),
        ),
        dataBuilder: (context, data) => FloatingActionButton(
          onPressed: () => Navigator.of(context).pop(),
          backgroundColor: Colors.green,
          child: Icon(
            Icons.done,
          ),
        ),
        onData: (data) {
          Navigator.of(context).pop();
          successFlushbar(context, "Bericht verzonden");
        },
        onError: (error, retry) {
          errorFlushbar(context, "Kon het bericht niet versturen:", error);
        },
        errorBuilder: (context, error, retry) => FloatingActionButton(
          backgroundColor: Colors.red,
          child: Icon(Icons.refresh),
          onPressed: retry,
        ),
      ),
    );
  }
}
