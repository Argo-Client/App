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
                  icon: Icon(Icons.menu),
                  onPressed: () {
                    _layoutKey.currentState.openDrawer();
                  },
                ),
                bottom: TabBar(
                  tabs: [
                    for (var periode in account.cijfers[jaar]["perioden"])
                      Tab(
                        text: periode["abbr"],
                      ),
                  ],
                ),
                title: Text("Cijfers - ${account.cijfers[jaar]["leerjaar"]}"),
              ),
              body: RefreshIndicator(
                  child: TabBarView(
                    children: [
                      for (Map periode in account.cijfers[jaar]["perioden"])
                        SingleChildScrollView(
                          child: Column(children: [
                            for (Map cijfer in account.cijfers[jaar]["cijfers"].where((cijfer) => cijfer["periodeId"] == periode["id"]))
                              ListTile(
                                title: Text("${cijfer["vak"]["Omschrijving"]}"),
                                subtitle: Text("${formatDate.format(cijfer["ingevoerd"])}"),
                                trailing: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: userdata.get("accentColor")),
                                  ),
                                  width: 45,
                                  height: 45,
                                  padding: EdgeInsets.all(13),
                                  child: Text(
                                    "${cijfer["cijfer"]}",
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.fade,
                                    maxLines: 1,
                                  ),
                                ),
                              )
                          ]),
                        ),
                    ],
                  ),
                  onRefresh: () async {
                    try {
                      await account.magister.cijfers.refresh();
                      setState(() {});
                    } catch (e) {
                      FlushbarHelper.createError(message: "Kon cijfers niet verversen:\n$e")..show(context);
                      throw (e);
                    }
                  })),
        );
      },
    );
  }
}
