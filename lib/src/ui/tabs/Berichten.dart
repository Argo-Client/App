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
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _layoutKey.currentState.openDrawer();
          },
        ),
        title: Text("Berichten"),
      ),
      body: CalendarDatePicker(
        initialDate: DateTime.now(),
        firstDate: DateTime.parse("1970-01-01 00:00:00Z"),
        lastDate: DateTime.now().add(Duration(days: 365)),
        onDateChanged: (value) {},
      ),
    );
  }
}
