part of main;

enum HomeMenu { herlaad, indeling, instellingen }

class Thuis extends StatefulWidget {
  final AppBar appBar = AppBar(
    title: Text("Home"),
    actions: [
      PopupMenuButton<HomeMenu>(
        onSelected: (HomeMenu result) {
          // setState(() {
          //   _selection = result;
          // });
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<HomeMenu>>[
          const PopupMenuItem<HomeMenu>(
            value: HomeMenu.herlaad,
            child: Text('Herlaad'),
          ),
          const PopupMenuItem<HomeMenu>(
            value: HomeMenu.indeling,
            child: Text('Verander indeling'),
          ),
          const PopupMenuItem<HomeMenu>(
            value: HomeMenu.instellingen,
            child: Text('Instellingen'),
          ),
        ],
      ),
    ],
  );
  @override
  _Thuis createState() => _Thuis();
}

class _Thuis extends State<Thuis> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Hier komt home'),
    );
  }
}
