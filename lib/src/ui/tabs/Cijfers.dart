part of main;

class Cijfers extends StatefulWidget {
  @override
  _Cijfers createState() => _Cijfers();
}

class _Cijfers extends State<Cijfers> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
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
              Tab(
                text: "Recent",
              ),
              Tab(
                text: "TP 1",
              ),
            ],
          ),
          title: Text("Cijfers"),
        ),
        body: TabBarView(
          children: [
            ListView(),
            ListView(),
          ],
        ),
      ),
    );
  }
}
