part of main;

class Huiswerk extends StatefulWidget {
  @override
  _Huiswerk createState() => _Huiswerk();
}

class _Huiswerk extends State<Huiswerk> with AfterLayoutMixin<Huiswerk>, SingleTickerProviderStateMixin {
  static DateFormat formatDate = DateFormat("yyyy-MM-dd");
  static DateTime date = DateTime.now();

  DateTime lastMonday = date.subtract(Duration(days: date.weekday - 1));

  int currentWeek(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  void afterFirstLayout(BuildContext context) => handleError(account.magister.agenda.refresh, "Fout tijdens verversen van huiswerk", context);

  @override
  Widget build(BuildContext context) {
    String weekslug = formatDate.format(lastMonday);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _layoutKey.currentState.openDrawer();
          },
        ),
        title: Text("Huiswerk"),
      ),
      body: RefreshIndicator(
        child: ValueListenableBuilder(
          valueListenable: updateNotifier,
          builder: (BuildContext context, _, _a) {
            List<Widget> huiswerk = [];
            String lastDay;
            List<Les> huiswerkLessen;
            bool loading = false;
            if (account.lessons[weekslug] != null) {
              huiswerkLessen = account.lessons[weekslug].expand((x) => x).where((les) => les.huiswerk != null).toList();
            } else {
              huiswerkLessen = [];
              loading = true;
              handleError(
                () async => await account.magister.agenda.getLessen(DateTime.parse(weekslug)),
                "Kon deze week niet ophalen",
                context,
              );
            }

            huiswerk.add(
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_left),
                    onPressed: () {
                      lastMonday = lastMonday.subtract(
                        Duration(
                          days: 7,
                        ),
                      );
                      setState(() {});
                    },
                  ),
                  Text("Week ${currentWeek(DateTime.parse(weekslug))}"),
                  IconButton(
                    icon: Icon(Icons.arrow_right),
                    onPressed: () {
                      lastMonday = lastMonday.add(
                        Duration(
                          days: 7,
                        ),
                      );
                      setState(() {});
                    },
                  ),
                ],
              ),
            );
            if (loading) {
              huiswerk.add(
                Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (huiswerkLessen.isEmpty) {
              /// [GUUS] maak even mooier, oja maak dan ook gelijk dat je naar volgende week kan ofzo
              huiswerk.add(Center(child: Text("Geen huiswerk deze week")));
            }
            for (int i = 0; i < huiswerkLessen.length; i++) {
              Les hw = huiswerkLessen[i];
              if (lastDay != hw.date) {
                huiswerk.add(
                  Padding(
                    padding: EdgeInsets.only(
                      left: 15,
                      top: 20,
                      bottom: 20,
                    ),
                    child: Text(
                      hw.date,
                      style: TextStyle(color: userdata.get("accentColor")),
                    ),
                  ),
                );
              }
              huiswerk.add(
                Container(
                  child: SeeCard(
                    child: ExpansionTile(
                      leading: hw.huiswerkAf
                          ? IconButton(
                              onPressed: () {
                                huiswerkAf(hw);
                              },
                              icon: Icon(
                                Icons.assignment_turned_in_outlined,
                                color: Colors.green,
                              ),
                            )
                          : IconButton(
                              onPressed: () {
                                huiswerkAf(hw);
                              },
                              icon: Icon(
                                Icons.assignment_outlined,
                              ),
                            ),
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => LesPagina(hw),
                              ),
                            );
                          },
                          child: Padding(
                            child: Html(
                              data: hw.huiswerk,
                              onLinkTap: launch,
                            ),
                            padding: EdgeInsets.only(
                              left: 30,
                            ),
                          ),
                        ),
                      ],
                      title: Text(
                        hw.title,
                      ),
                    ),
                  ),
                  decoration: huiswerkLessen.length - 1 == i || huiswerkLessen[i + 1].date != hw.date
                      ? null
                      : BoxDecoration(
                          border: Border(
                            bottom: greyBorderSide(),
                          ),
                        ),
                ),
              );
              lastDay = hw.date;
            }
            return ListView(
              children: huiswerk,
            );
          },
        ),
        onRefresh: () async {
          await handleError(account.magister.agenda.refresh, "Kon huiswerk niet verversen", context);
        },
      ),
    );
  }
}
