part of main;

class Afwezigheid extends StatefulWidget {
  @override
  _Afwezigheid createState() => _Afwezigheid();
}

class _Afwezigheid extends State<Afwezigheid> {
  _Afwezigheid() {
    if (account.id != 0) {
      account.magister.afwezigheid.refresh().then((_) {
        setState(() {});
      }).catchError((e) {
        FlushbarHelper.createError(message: "Fout tijdens verversen van afwezigheid:\n$e")..show(context);
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
          title: Text("Afwezigheid"),
          actions: [
            Tooltip(
              child: Padding(
                padding: EdgeInsets.only(
                  right: 15,
                ),
                child: Row(
                  children: [
                    Icon(Icons.check),
                    Text(" " + account.afwezigheid.where((afw) => afw["geoorloofd"]).length.toString()),
                  ],
                ),
              ),
              message: "Geoorloofd",
            ),
            Tooltip(
              message: "Ongeoorloofd",
              child: Padding(
                padding: EdgeInsets.only(
                  right: 15,
                ),
                child: Row(
                  children: [
                    Icon(Icons.error),
                    Text(" " + account.afwezigheid.where((afw) => !afw["geoorloofd"]).length.toString()),
                  ],
                ),
              ),
            ),
          ]),
      body: RefreshIndicator(
        child: ValueListenableBuilder(
            valueListenable: updateNotifier,
            builder: (BuildContext context, _, _a) {
              List<Widget> absenties = [];
              String lastDay;
              for (int i = 0; i < account.afwezigheid.length; i++) {
                Map afw = account.afwezigheid[i];
                String hour = afw["les"]["hour"].isEmpty ? "" : afw["les"]["hour"] + "e - ";
                if (lastDay != afw["dag"]) {
                  absenties.add(
                    Padding(
                      padding: EdgeInsets.only(
                        left: 15,
                        top: 20,
                        bottom: 20,
                      ),
                      child: Text(
                        afw["dag"],
                        style: TextStyle(color: userdata.get("accentColor")),
                      ),
                    ),
                  );
                }
                absenties.add(
                  Container(
                    child: Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        leading: Padding(
                          child: afw["geoorloofd"] ? Icon(Icons.check, color: Colors.green) : Icon(Icons.error, color: Colors.redAccent),
                          padding: EdgeInsets.only(
                            top: 7,
                            left: 7,
                          ),
                        ),
                        subtitle: Text(hour + afw["les"]["title"]),
                        title: Text(afw["type"]),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => LesPagina(afw["les"]),
                            ),
                          );
                        },
                        trailing: afw["les"]["description"].isEmpty
                            ? null
                            : Icon(
                                Icons.assignment,
                                color: Colors.grey,
                              ),
                      ),
                    ),
                    decoration: account.afwezigheid.length - 1 == i || account.afwezigheid[i + 1]["dag"] != afw["dag"]
                        ? null
                        : BoxDecoration(
                            border: Border(
                              bottom: greyBorderSide(),
                            ),
                          ),
                  ),
                );
                lastDay = afw["dag"];
              }
              return account.afwezigheid.isEmpty
                  ? ListView(
                      children: [
                        Center(
                          child: Text(
                            "Geen afwezigheid",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView(
                      children: absenties,
                    );
            }),
        onRefresh: () async {
          await account.magister.afwezigheid.refresh();
          setState(() {});
        },
      ),
    );
  }
}
