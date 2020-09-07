part of main;

class Berichten extends StatefulWidget {
  @override
  _Berichten createState() => _Berichten();
}

class _Berichten extends State<Berichten> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Berichten"),
      ),
      drawer: AppDrawer(),
      body: Center(
        child: Text("56 ongelezen berichten"),
      ),
    );
  }
}
