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
        title: Text("Bronnen"),
      ),
      drawer: AppDrawer(),
      body: Center(
        child: Text("13 nieuwe opdrachten"),
      ),
    );
  }
}
