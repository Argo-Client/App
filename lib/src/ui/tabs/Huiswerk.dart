part of main;

class Huiswerk extends StatefulWidget {
  @override
  _Huiswerk createState() => _Huiswerk();
}

class _Huiswerk extends State<Huiswerk> {
  @override
  Widget build(BuildContext context) {
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
            color: hw["huiswerkAf"] ? Colors.green : null,
            margin: EdgeInsets.zero,
            child: ListTile(
              subtitle: Html(data: hw["huiswerk"]),
              title: Text(hw["title"]),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => LesPagina(hw),
                  ),
                );
              },
            ),
          ),
          decoration: huiswerkLessen.length - 1 == i || huiswerkLessen[i + 1]["date"] != hw["date"]
              ? null
              : BoxDecoration(
                  border: Border(
                    bottom: GreyBorderSide,
                  ),
                ),
        ),
      );
      lastDay = hw["date"];
    }
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
          child: ListView(
            children: huiswerk,
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
