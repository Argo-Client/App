part of main;

class Cijfers extends StatefulWidget {
  @override
  _Cijfers createState() => _Cijfers();
}

class _Cijfers extends State<Cijfers> {
  DateFormat formatDate = DateFormat("dd-MM-y");
  int jaar = 0;
  @override
  Widget build(BuildContext context) {
    List<Periode> perioden = account.cijfers[jaar].perioden
        .where(
          (periode) => account.cijfers[jaar].cijfers.where((cijfer) => cijfer.periode.id == periode.id).isNotEmpty,
        )
        .toList();

    return ValueListenableBuilder(
      valueListenable: updateNotifier,
      builder: (BuildContext context, _, _a) {
        return DefaultTabController(
          length: jaar == 0 ? 1 + perioden.length : perioden.length,
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
                  if (jaar == 0) // Recenst
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: Tab(
                        text: "Recent",
                      ),
                    ),
                  for (Periode periode in perioden)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: Tab(
                        text: periode.abbr,
                      ),
                    ),
                ],
              ),
              title: PopupMenuButton(
                initialValue: jaar,
                onSelected: (value) => setState(() => jaar = value),
                itemBuilder: (BuildContext context) {
                  return <PopupMenuEntry>[
                    for (int i = 0; i < account.cijfers.length; i++)
                      PopupMenuItem(
                        value: i,
                        child: Text('${account.cijfers[i].leerjaar}'),
                      ),
                  ];
                },
                child: Row(
                  children: [
                    Text("Cijfers - ${account.cijfers[jaar].leerjaar}"),
                    Icon(Icons.keyboard_arrow_down_outlined),
                  ],
                ),
              ),
            ),
            body: TabBarView(
              children: [
                if (jaar == 0) // Recenst
                  RefreshIndicator(
                    onRefresh: () async {
                      await handleError(account.magister.cijfers.refresh, "Kon cijfers niet verversen", context);
                    },
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: account.recenteCijfers.isEmpty
                          ? Center(
                              child: Text("Nog geen cijfers"),
                            )
                          : SeeCard(
                              column: [
                                for (Cijfer cijfer in account.recenteCijfers)
                                  Container(
                                    child: cijferTile(cijfer, true),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: greyBorderSide(),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                    ),
                  ),
                for (Periode periode in perioden)
                  RefreshIndicator(
                    onRefresh: () async {
                      await handleError(account.magister.cijfers.refresh, "Kon cijfers niet verversen", context);
                    },
                    child: SingleChildScrollView(
                      child: SeeCard(
                        column: [
                          for (Cijfer cijfer in account.cijfers[jaar].cijfers.where(
                            (cijfer) => cijfer.periode.id == periode.id,
                          ))
                            ListTileBorder(
                              border: Border(
                                right: greyBorderSide(),
                                bottom: greyBorderSide(),
                              ),
                              title: Text("${cijfer.vak.naam}"),
                              subtitle: Text("${formatDate.format(cijfer.ingevoerd)}"),
                              trailing: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: userdata.get("accentColor")),
                                ),
                                width: 45,
                                height: 45,
                                child: Center(
                                  child: Text(
                                    "${cijfer.cijfer}",
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
                                    builder: (context) => CijferPagina(cijfer.vak.id, jaar),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
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
  CijferJaar jaar;
  List<Cijfer> cijfers;
  Vak vak;
  double doubleCijfers;
  List<double> avgCijfers;
  double totalWeging;
  _CijferPagina(int id, int jaar) {
    this.jaar = account.cijfers[jaar];
    this.cijfers = this.jaar.cijfers.where((cijfer) => cijfer.vak.id == id).toList();
    this.vak = cijfers.first.vak;
    avgCijfers = [];
    doubleCijfers = 0;
    totalWeging = 0;
    cijfers.reversed.forEach(
      (Cijfer cijfer) {
        if (cijfer.weging == 0 || cijfer.weging == null) return;
        double cijf;
        try {
          cijf = double.parse(cijfer.cijfer.replaceFirst(",", "."));
        } catch (e) {}
        if (cijf != null) {
          doubleCijfers += cijf * cijfer.weging;
          print(doubleCijfers);
          print(formatDate.format(cijfer.ingevoerd));
          totalWeging += cijfer.weging;
          avgCijfers.add(doubleCijfers / totalWeging);
        }
        print(avgCijfers);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          vak.naam,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (avgCijfers.isNotEmpty)
              SizedBox(
                height: 200.0,
                child: charts.LineChart(
                  _createCijfers(),
                ),
              ),
            for (Periode periode in jaar.perioden)
              Column(
                children: [
                  if (cijfers
                      .where(
                        (cijf) => cijf.periode.id == periode.id,
                      )
                      .isNotEmpty)
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(
                        left: 10,
                        top: 15,
                        bottom: 15,
                      ),
                      child: Text(
                        periode.naam,
                        // maxLines: 1,
                        // overflow: TextOverflow.visible,
                        // softWrap: false,
                        style: TextStyle(color: userdata.get("accentColor")),
                      ),
                    ),
                  SeeCard(
                    border: Border(
                      top: greyBorderSide(),
                    ),
                    column: [
                      for (Cijfer cijfer in cijfers.where(
                        (cijf) => cijf.periode.id == periode.id,
                      ))
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: greyBorderSide(),
                            ),
                          ),
                          child: Futuristic(
                            autoStart: true,
                            futureBuilder: () => account.magister.cijfers.getExtraInfo(cijfer, jaar),
                            busyBuilder: (context) => CircularProgressIndicator(),
                            errorBuilder: (context, error, retry) {
                              return Text("Error $error");
                            },
                            dataBuilder: (context, data) => cijferTile(cijfer),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  List<charts.Series<double, int>> _createCijfers() {
    return [
      new charts.Series<double, int>(
        id: 'Cijfers',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (double cijfer, i) => i,
        measureFn: (double cijfer, _) => cijfer,
        displayName: "Gemiddelde",
        data: avgCijfers,
      )
    ];
  }
}

ListTile cijferTile(Cijfer cijfer, [bool isRecent]) {
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
