import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_placeholder_textlines/placeholder_lines.dart';

import 'package:intl/intl.dart';
// import 'package:charts_flutter/flutter.dart' as charts;
import 'package:futuristic/futuristic.dart';

import 'package:argo/src/utils/boxes.dart';
import 'package:argo/src/utils/update.dart';
import 'package:argo/src/utils/account.dart';
import 'package:argo/src/utils/handleError.dart';
import 'package:argo/src/utils/hive/adapters.dart';

import 'package:argo/src/ui/components/Card.dart';
import 'package:argo/src/ui/components/AppPage.dart';
import 'package:argo/src/ui/components/EmptyPage.dart';
import 'package:argo/src/ui/components/grayBorder.dart';
import 'package:argo/src/ui/components/CircleShape.dart';
import 'package:argo/src/ui/components/ContentHeader.dart';
import 'package:argo/src/ui/components/ListTileDivider.dart';

class CijferTile extends StatelessWidget {
  final Cijfer cijfer;
  final bool isRecent;

  CijferTile(this.cijfer, {this.isRecent});

  @override
  Widget build(BuildContext build) {
    return ListTile(
      trailing: cijfer.cijfer.length > 4
          ? null
          : Stack(
              children: [
                Text(
                  cijfer.cijfer,
                  style: TextStyle(
                    fontSize: 17,
                    color: cijfer.voldoende || userdata.get("disableCijferColor") ? null : Colors.red,
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

class Cijfers extends StatefulWidget {
  @override
  _Cijfers createState() => _Cijfers();
}

class _Cijfers extends State<Cijfers> {
  DateFormat formatDate = DateFormat("dd-MM-y");
  int jaar = 0;

  Widget _buildCijfer(Cijfer cijfer, List cijfersInPeriode) {
    return ListTile(
      title: Text("${cijfer.vak.naam}"),
      subtitle: Text("${formatDate.format(cijfer.ingevoerd)}"),
      trailing: CircleShape(
        child: Text(
          cijfer.cijfer,
          textAlign: TextAlign.center,
          overflow: TextOverflow.fade,
          softWrap: false,
          maxLines: 1,
        ),
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CijferPagina(cijfer.vak.id, jaar),
          ),
        );
      },
    );
  }

  Widget _recenteCijfers() {
    return RefreshIndicator(
      onRefresh: () async {
        await handleError(account().magister.cijfers.recentCijfers, "Kon cijfers niet verversen", context);
      },
      child: account().recenteCijfers.isEmpty
          ? EmptyPage(
              text: "Nog geen cijfers",
              icon: Icons.looks_6_outlined,
            )
          : ListView(
              children: divideListTiles([
                for (Cijfer cijfer in account().recenteCijfers)
                  MaterialCard(
                    child: CijferTile(cijfer, isRecent: true),
                  ),
              ]),
            ),
    );
  }

  Widget _tabBar(List<Periode> perioden) {
    return TabBar(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Periode> perioden = account()
        .cijfers[jaar]
        .perioden
        .where(
          (periode) => account().cijfers[jaar].cijfers.where((cijfer) => cijfer.periode.id == periode.id).isNotEmpty,
        )
        .toList();

    return ValueListenableBuilder(
      valueListenable: updateNotifier,
      builder: (BuildContext context, _, _a) {
        return DefaultTabController(
          length: jaar == 0 ? 1 + perioden.length : perioden.length,
          child: AppPage(
            bottom: _tabBar(perioden),
            title: Text("Cijfers - ${account().cijfers[jaar].leerjaar}"),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.calculate_outlined,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => _BerekenCijferPagina(),
                    ),
                  );
                },
              ),
              PopupMenuButton(
                  initialValue: jaar,
                  onSelected: (value) => setState(() => jaar = value),
                  itemBuilder: (BuildContext context) {
                    return <PopupMenuEntry>[
                      for (int i = 0; i < account().cijfers.length; i++)
                        PopupMenuItem(
                          value: i,
                          child: Text('${account().cijfers[i].leerjaar}'),
                        ),
                    ];
                  }),
            ],
            body: TabBarView(
              children: [
                if (jaar == 0) // Recente Cijfers
                  _recenteCijfers(),
                for (Periode periode in perioden)
                  RefreshIndicator(
                    onRefresh: () async => await handleError(
                      account().magister.cijfers.refresh,
                      "Kon cijfers niet verversen",
                      context,
                    ),
                    child: ListView(
                      children: () {
                        List cijfersInPeriode = account()
                            .cijfers[jaar]
                            .cijfers
                            .where(
                              (cijfer) => cijfer.periode.id == periode.id,
                            )
                            .toList();

                        return divideListTiles([
                          for (var cijfer in cijfersInPeriode)
                            MaterialCard(
                              child: _buildCijfer(cijfer, cijfersInPeriode),
                            ),
                        ]);
                      }(),
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
  Vak vak;
  CijferJaar jaar;
  List<Cijfer> cijfers;

  _CijferPagina(int id, int jaar) {
    this.jaar = account().cijfers[jaar];
    this.cijfers = this.jaar.cijfers.where((cijfer) => cijfer.vak.id == id).toList();
    this.vak = cijfers.first.vak;
  }

  Widget _buildPeriode(Periode periode) {
    List<Cijfer> periodecijfers = cijfers.where((cijf) => cijf.periode.id == periode.id).toList();

    if (periodecijfers.isEmpty) return Container();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ContentHeader(periode.naam),
        MaterialCard(
          children: divideListTiles([
            for (Cijfer cijfer in periodecijfers)
              Futuristic(
                autoStart: true,
                futureBuilder: () => account().magister.cijfers.getExtraInfo(cijfer, jaar),
                busyBuilder: (context) => ListTile(
                  title: PlaceholderLines(
                    count: 1,
                    animate: true,
                  ),
                  subtitle: PlaceholderLines(
                    count: 1,
                    animate: true,
                  ),
                  trailing: CircularProgressIndicator(),
                ),
                errorBuilder: (context, error, retry) {
                  return Text("Error $error");
                },
                dataBuilder: (context, data) => CijferTile(
                  cijfer,
                ),
              ),
          ]),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          vak.naam,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.calculate_outlined,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => _BerekenCijferPagina(
                    vak: vak,
                    jaar: jaar,
                    cijfers: cijfers,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: jaar.perioden
              .map(
                (periode) => _buildPeriode(periode),
              )
              .toList(),
        ),
      ),
    );
  }

  // List<charts.Series<double, int>> _createCijfers() {
  //   return [
  //     new charts.Series<double, int>(
  //       id: 'Cijfers',
  //       colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
  //       domainFn: (double cijfer, i) => i,
  //       measureFn: (double cijfer, _) => cijfer,
  //       displayName: "Gemiddelde",
  //       data: avgCijfers,
  //     )
  //   ];
  // }
}

class _BerekenCijferPagina extends StatelessWidget {
  final CijferJaar jaar;
  final Vak vak;

  final ValueNotifier<List<Cijfer>> cijfers = ValueNotifier([]);

  _BerekenCijferPagina({this.vak, this.jaar, List<Cijfer> cijfers}) {
    cijfers ??= [];
    var included = cijfers.where((cijfer) => cijfer.parse() != null && cijfer.weging != null && cijfer.weging > 1);
    this.cijfers.value = included.map((oldCijfer) => oldCijfer.lowCopy()).toList();
  }

  Widget _buildCijfer(Cijfer cijfer) {
    ValueNotifier<bool> checked = ValueNotifier(cijfer.selected);

    void updateChecked(bool value) {
      checked.value = value;
      cijfer.selected = value;

      // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
      cijfers.notifyListeners();
    }

    return MaterialCard(
      child: ValueListenableBuilder(
        valueListenable: checked,
        builder: (context, _, _a) => ListTile(
          onTap: () => updateChecked(!checked.value),
          leading: Checkbox(
            value: checked.value,
            onChanged: updateChecked,
            activeColor: userdata.get('accentColor'),
          ),
          title: Text(cijfer.title),
          trailing: Container(
            width: 75,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  child: TextFormField(
                    onChanged: (changed) {
                      cijfer.cijfer = changed;
                      if (cijfer.selected) {
                        // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                        cijfers.notifyListeners();
                      }
                    },
                    decoration: InputDecoration(
                      isDense: true,
                      // border: InputBorder.none,
                    ),
                    keyboardType: TextInputType.number,
                    initialValue: cijfer.cijfer,
                  ),
                  width: 30,
                ),
                Text("x"),
                Container(
                  child: TextFormField(
                    onChanged: (changed) {
                      cijfer.weging = double.tryParse(changed.replaceFirst(",", "."));
                      if (cijfer.selected) {
                        // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                        cijfers.notifyListeners();
                      }
                    },
                    decoration: InputDecoration(
                      isDense: true,
                      // border: InputBorder.none,
                    ),
                    keyboardType: TextInputType.number,
                    initialValue: cijfer.weging.toString().replaceFirst(".", ","),
                  ),
                  width: 30,
                ),
              ],
              // leading: Checkbox(value: ,),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriode(Periode periode) {
    List<Cijfer> periodeCijfers = cijfers.value.where((cijf) => cijf.periode?.id == periode.id).toList();

    if (periodeCijfers.isEmpty) return Container();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ContentHeader(periode.naam),
        ...divideListTiles(
          periodeCijfers
              .map(
                (cijfer) => _buildCijfer(cijfer),
              )
              .toList(),
        )
      ],
    );
  }

  String _calculateAverage(List<Cijfer> cijfers) {
    if (cijfers.isEmpty || cijfers.any((cijfer) => cijfer.parse() == null || cijfer.weging == null)) {
      return 0.toStringAsPrecision(3);
    }

    double sum = cijfers.fold(0, (value, cijfer) => value + cijfer.parse() * cijfer.weging);
    double weight = cijfers.fold(0, (value, cijfer) => value + cijfer.weging);

    double average = sum / weight;

    return average.toStringAsPrecision(3);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Gemiddelde berekenen'),
          actions: [
            IconButton(
              icon: Icon(Icons.add_outlined),
              onPressed: () {
                Cijfer newCijfer = Cijfer();
                newCijfer.title = "Cijfer ${cijfers.value.length}";
                newCijfer.weging = 1;
                newCijfer.cijfer = "10";
                newCijfer.selected = true;
                newCijfer.id = cijfers.value.length;
                cijfers.value = List.from(cijfers.value)..add(newCijfer);
              },
            ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: defaultBorderSide(context),
            ),
          ),
          child: ListTile(
            title: Text("Gemiddelde:"),
            trailing: ValueListenableBuilder<List<Cijfer>>(
              valueListenable: cijfers,
              builder: (context, cijfers, _a) => Text(
                _calculateAverage(cijfers.where((cijfer) => cijfer.selected != null && cijfer.selected).toList()),
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ),
        body: ValueListenableBuilder<List<Cijfer>>(
          valueListenable: cijfers,
          child: EmptyPage(
            icon: Icons.calculate_outlined,
            text: 'Geen geschikte cijfers',
          ),
          builder: (context, cijfers, empty) {
            var noPeriodeCijfers = cijfers.where((cijfer) => cijfer.periode == null).toList().reversed;
            var periodeCijfers = jaar == null ? [] : jaar.perioden.map((periode) => _buildPeriode(periode)).toList();

            if (noPeriodeCijfers.isEmpty && periodeCijfers.isEmpty) {
              return empty;
            }

            return ListView(
              children: [
                ...divideListTiles(noPeriodeCijfers
                    .map(
                      (cijfer) => _buildCijfer(cijfer),
                    )
                    .toList()),
                ...periodeCijfers
              ],
            );
          },
        ));
  }
}
