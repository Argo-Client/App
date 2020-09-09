part of main;

class Bronnen extends StatefulWidget {
  @override
  _Bronnen createState() => _Bronnen();
}

class _Bronnen extends State<Bronnen> {
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
        title: Text("Bronnen"),
      ),
      body: Center(
        child: Text("13 nieuwe opdrachten"),
      ),
    );
  }
}
