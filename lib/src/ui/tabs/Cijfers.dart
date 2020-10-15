part of main;

class Cijfers extends StatefulWidget {
  @override
  _Cijfers createState() => _Cijfers();
}

class _Cijfers extends State<Cijfers> {
  DateFormat formatDate = DateFormat("dd-MM-y");
  int jaar = 1;
  _Cijfers() {
    // if (account.id != 0) {
    //   account.magister.cijfers.refresh().then((_) {
    //     setState(() {});
    //   }).catchError((e) {
    //     FlushbarHelper.createError(message: "Fout tijdens verversen van cijfers:\n$e")..show(context);
    //     throw (e);
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: updateNotifier,
      // child: ,
      builder: (BuildContext context, _, _a) {
        return DefaultTabController(
          length: account.cijfers[jaar]["perioden"].length,
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(
                  Icons.menu,
                ),
                onPressed: () {
                  _layoutKey.currentState.openDrawer();
                },
              ),
              bottom: TabBar(
                isScrollable: true,
                tabs: [
                  for (var periode in account.cijfers[jaar]["perioden"])
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: Tab(
                        text: periode["abbr"],
                      ),
                    ),
                ],
              ),
              title: Text("Cijfers - ${account.cijfers[jaar]["leerjaar"]}"),
            ),
            body: TabBarView(
              children: [
                for (Map periode in account.cijfers[jaar]["perioden"])
                  RefreshIndicator(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (Map cijfer in account.cijfers[jaar]["cijfers"].where((cijfer) => cijfer["periode"]["id"] == periode["id"]))
                            ListTile(
                              title: Text("${cijfer["vak"]["naam"]}"),
                              subtitle: Text("${formatDate.format(cijfer["ingevoerd"])}"),
                              trailing: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: userdata.get("accentColor")),
                                ),
                                width: 45,
                                height: 45,
                                child: Center(
                                  child: Text(
                                    "${cijfer["cijfer"]}",
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => CijferPagina(cijfer["vak"]["id"], jaar),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                    onRefresh: () async {
                      await handleError(account.magister.cijfers.refresh, "Kon cijfers niet verversen", context);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CijferPagina extends StatefulWidget {
  final int id;
  final int jaar;
  CijferPagina(this.id, this.jaar);
  @override
  _CijferPagina createState() => _CijferPagina(id, jaar);
}

class _CijferPagina extends State<CijferPagina> {
  // static List<charts.Series<Map, DateTime>> _createCijfers() {
  //   final data = [
  //     {
  //       "time": DateTime.now(),
  //       "cijfer": "8.6",
  //     }
  //   ];

  //   return [
  //     new charts.Series<Map, DateTime>(
  //       id: 'Cijfer',
  //       colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
  //       domainFn: (Map cijfer, _) => cijfer["time"],
  //       measureFn: (Map cijfer, _) => cijfer["cijfer"],
  //       data: data,
  //     )
  //   ];
  // }

  Map jaar;
  List cijfers;
  Map vak;
  _CijferPagina(int id, int jaar) {
    this.jaar = account.cijfers[jaar];
    this.cijfers = this.jaar["cijfers"].where((cijfer) => cijfer["vak"]["id"] == id).toList();
    this.vak = cijfers.first["vak"];
    print(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          vak["naam"],
        ),
      ),
      body: SingleChildScrollView(
        child: Card(
          margin: EdgeInsets.only(
            bottom: 20,
          ),
          child: Column(
            children: [
              // charts.TimeSeriesChart(
              //   _createCijfers(),
              //   // Optionally pass in a [DateTimeFactory] used by the chart. The factory
              //   // should create the same type of [DateTime] as the data provided. If none
              //   // specified, the default creates local date time.
              //   dateTimeFactory: const charts.LocalDateTimeFactory(),
              // ),
              ListTile(
                leading: Icon(
                  Icons.book,
                ),
                title: Text(
                  vak["naam"],
                ),
              ),
              for (Map periode in jaar["perioden"])
                Column(
                  children: [
                    Divider(),
                    Text(
                      periode["naam"],
                      style: TextStyle(color: userdata.get("accentColor")),
                    ),
                    for (Map cijfer in cijfers.where((cijf) => cijf["periode"]["id"] == periode["id"]))
                      ListTile(
                        onTap: () {},
                        title: Text(cijfer["cijfer"]),
                      )
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}
