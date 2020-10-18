part of main;

class Huiswerk extends StatefulWidget {
  @override
  _Huiswerk createState() => _Huiswerk();
}

class _Huiswerk extends State<Huiswerk> with AfterLayoutMixin<Huiswerk> {
  void afterFirstLayout(BuildContext context) => handleError(account.magister.agenda.refresh, "Fout tijdens verversen van huiswerk", context);
  @override
  Widget build(BuildContext context) {
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
              List<Les> huiswerkLessen = account.lessons.expand((x) => x).where((les) => les.huiswerk != null).toList();
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
                    child: Card(
                      margin: EdgeInsets.zero,
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
          }),
    );
  }
}
