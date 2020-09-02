part of main;

bool openedIntroduction = false;

class Agenda extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    void runIntroduction() async {
      openedIntroduction = true;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool _seen = (prefs.getBool('seen') ?? false);
      if (!_seen) {
        Navigator.pushNamed(context, 'Introduction');
      }
    }

    if (!openedIntroduction) {
      runIntroduction();
    }

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
