part of main;

class Leermiddelen extends StatefulWidget {
  @override
  _Leermiddelen createState() => _Leermiddelen();
}

class _Leermiddelen extends State<Leermiddelen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Leermiddelen"),
      ),
      body: Center(
        child: Text("3 online methodes beschikbaar"),
      ),
    );
  }
}
