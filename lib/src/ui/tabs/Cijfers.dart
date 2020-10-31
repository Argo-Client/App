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
          length: perioden.length,
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
              title: Text("Cijfers - ${account.cijfers[jaar].leerjaar}"),
            ),
            body: TabBarView(
              children: [
                for (Periode periode in perioden)
                  RefreshIndicator(
                    child: SingleChildScrollView(
                      child: SeeCard(
                        child: Column(
                          children: [
                            for (Cijfer cijfer in account.cijfers[jaar].cijfers.where((cijfer) => cijfer.periode.id == periode.id))
                              Container(
                                child: ListTile(
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
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: greyBorderSide(),
                                    bottom: greyBorderSide(),
                                  ),
                                ),
                              ),
                          ],
                        ),
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
  CijferJaar jaar;
  List<Cijfer> cijfers;
  Vak vak;
  _CijferPagina(int id, int jaar) {
    this.jaar = account.cijfers[jaar];
    this.cijfers = this.jaar.cijfers.where((cijfer) => cijfer.vak.id == id).toList();
    this.vak = cijfers.first.vak;
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
            Container(
              constraints: BoxConstraints.tightForFinite(),
            ),
            SizedBox(
              height: 300.0,
              child: charts.LineChart(_createCijfers()),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.symmetric(
                  vertical: greyBorderSide(),
                ),
              ),
              child: SeeCard(
                child: ListTile(
                  leading: Icon(
                    Icons.book,
                  ),
                  title: Text(
                    vak.naam,
                  ),
                ),
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
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: greyBorderSide(),
                        ),
                      ),
                      child: Column(
                        children: [
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
                                dataBuilder: (context, data) => ListTile(
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
                                      ? null
                                      : Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          child: Text(
                                            cijfer.cijfer,
                                          ),
                                        ),
                                  title: Text(cijfer.title),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  List<charts.Series<double, int>> _createCijfers() {
    List<double> doubleCijfers = [];
    cijfers.forEach(
      (Cijfer cijfer) {
        try {
          double cijf = double.parse(cijfer.cijfer.replaceFirst(",", "."));
          doubleCijfers.add(cijf);
        } catch (e) {}
      },
    );
    return [
      new charts.Series<double, int>(
        id: 'Cijfers',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (double cijfer, i) => i,
        measureFn: (double cijfer, _) => cijfer,
        data: doubleCijfers,
      )
    ];
  }
}
