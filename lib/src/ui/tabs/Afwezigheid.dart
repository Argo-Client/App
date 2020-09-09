part of main;

class Afwezigheid extends StatefulWidget {
  @override
  _Afwezigheid createState() => _Afwezigheid();
}

class _Afwezigheid extends State<Afwezigheid> {
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
        title: Text("Afwezigheid"),
      ),
      body: Center(
        child: Text("30 ongeoorloofde absenties"),
      ),
    );
  }
}
