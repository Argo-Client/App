part of main;

class Afwezigheid extends StatefulWidget {
  @override
  _Afwezigheid createState() => _Afwezigheid();
}

class _Afwezigheid extends State<Afwezigheid> {
  List<Widget> absenties = [];
  @override
  Widget build(BuildContext context) {
    for (Map afw in account.afwezigheid) {
      absenties.addAll([
        Padding(
          padding: EdgeInsets.only(left: 15, top: 20),
          child: Text(
            afw["dag"],
            style: TextStyle(color: userdata.get("accentColor")),
          ),
        ),
        ListTile(
          leading: afw["geoorloofd"] ? Icon(Icons.check) : Icon(Icons.error),
          title: Text(afw["type"]),
          onTap: () {},
        ),
      ]);
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _layoutKey.currentState.openDrawer();
          },
        ),
        title: Text("Afwezigheid"),
      ),
      body: RefreshIndicator(
          child: ListView(
            children: absenties,
          ),
          onRefresh: () async {
            return await account.magister.afwezigheid.refresh();
          }),
    );
  }
}
