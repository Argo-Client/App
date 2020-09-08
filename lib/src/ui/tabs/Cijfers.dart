part of main;

class Cijfers extends StatefulWidget {
  @override
  _Cijfers createState() => _Cijfers();
}

class _Cijfers extends State<Cijfers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cijfers"),
      ),
      body: Center(
        child: Text("Je staat een 4 voor wiskunde"),
      ),
    );
  }
}
