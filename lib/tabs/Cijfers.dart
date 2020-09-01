part of main;

class Cijfers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DefaultDrawer(),
      body: Center(
        child: Text('Hier komen de cijfers'),
      ),
      appBar: AppBar(
        title: Text('Cijfers'),
      ),
    );
  }
}
