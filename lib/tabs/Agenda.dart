part of main;

class Agenda extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Scaffold is a layout for the major Material Components.
    return Scaffold(
      drawer: DefaultDrawer(),
      appBar: AppBar(
        title: GestureDetector(
            onTap: () {},
            child: Row(
              children: [
                Text('Agenda'),
                Icon(
                  Icons.arrow_drop_down,
                  size: 26.0,
                ),
              ],
            )),
        actions: [
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {},
                child: Icon(
                  Icons.add,
                  size: 26.0,
                ),
              )),
        ],
      ),
      body: Center(
        child: Text('Hier komt de agenda'),
      ),
    );
  }
}
