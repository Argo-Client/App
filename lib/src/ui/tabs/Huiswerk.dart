part of main;

class Huiswerk extends StatefulWidget {
  @override
  _Huiswerk createState() => _Huiswerk();
}

class _Huiswerk extends State<Huiswerk> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Huiswerk"),
      ),
      body: Center(
        child: Text("45 opdrachten voor de komende week"),
      ),
    );
  }
}
