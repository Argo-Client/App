part of main;

class Agenda extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Scaffold is a layout for the major Material Components.
    return Scaffold(
      drawer: DefaultDrawer(),
      appBar: AppBar(
        title: Text('Agenda'),
      ),
      body: Center(
        child: Text('Hier komt de agenda'),
      ),
    );
  }
}
