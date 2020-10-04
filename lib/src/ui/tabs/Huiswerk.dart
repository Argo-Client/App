part of main;

class Huiswerk extends StatefulWidget {
  @override
  _Huiswerk createState() => _Huiswerk();
}

class _Huiswerk extends State<Huiswerk> {
  _Huiswerk() {
    if (account.id != 0) {
      account.magister.agenda.refresh().then((_) {
        setState(() {});
      }).catchError((e) {
        FlushbarHelper.createError(message: "Fout tijdens verversen van huiswerk:\n$e")..show(context);
        throw (e);
      });
    }
  }
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
              List huiswerkLessen = account.lessons.expand((x) => x).where((les) => les["huiswerk"] != null).toList();
              for (int i = 0; i < huiswerkLessen.length; i++) {
                Map hw = huiswerkLessen[i];
                if (lastDay != hw["date"]) {
                  huiswerk.add(
                    Padding(
                      padding: EdgeInsets.only(
                        left: 15,
                        top: 20,
                        bottom: 20,
                      ),
                      child: Text(
                        hw["date"],
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
                        leading: hw["huiswerkAf"]
                            ? IconButton(
                                onPressed: () {
                                  huiswerkAf(hw);
                                },
                                icon: Icon(
                                  Icons.check,
                                  color: Colors.greenAccent,
                                ),
                              )
                            : IconButton(
                                onPressed: () {
                                  huiswerkAf(hw);
                                },
                                icon: Icon(
                                  Icons.info,
                                  color: Colors.blueAccent,
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
                                data: hw["huiswerk"],
                                onLinkTap: launch,
                              ),
                              padding: EdgeInsets.only(
                                left: 30,
                              ),
                            ),
                          ),
                        ],
                        title: Text(
                          hw["title"],
                        ),
                      ),
                    ),
                    decoration: huiswerkLessen.length - 1 == i || huiswerkLessen[i + 1]["date"] != hw["date"]
                        ? null
                        : BoxDecoration(
                            border: Border(
                              bottom: greyBorderSide(),
                            ),
                          ),
                  ),
                );
                lastDay = hw["date"];
              }
              return ListView(
                children: huiswerk,
              );
            },
          ),
          onRefresh: () async {
            try {
              await account.magister.agenda.refresh();
              setState(() {});
            } catch (e) {
              FlushbarHelper.createError(message: "Kon huiswerk niet verversen:\n$e")..show(context);
              throw (e);
            }
          }),
    );
  }
}
