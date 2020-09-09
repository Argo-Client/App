part of main;

class Opdrachten extends StatefulWidget {
  @override
  _Opdrachten createState() => _Opdrachten();
}

class _Opdrachten extends State<Opdrachten> {
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
        title: Text("Opdrachten"),
      ),
      body: Center(
        child: Text("63 opdrachten in te leveren voor het eind van deze week"),
      ),
    );
  }
}
