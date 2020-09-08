part of main;

int _currentIndex = 0;

class HomeState extends State<Home> {
  Box user = Hive.box("magisterData");

  void changeIndex(int index) {
    _currentIndex = index;
    homeState.setState(() {});
    Navigator.pop(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _drawer = [
      UserAccountsDrawerHeader(
        accountName: Text(user.get("fullName", defaultValue: "Laden...")),
        accountEmail: Text(user.get("klasCode", defaultValue: "Laden...")),
        currentAccountPicture: CircleAvatar(
          backgroundColor: Theme.of(context).backgroundColor,
          child: Icon(Icons.person, size: 50),
        ),
      ),
    ];

    for (int i = 0; i < _children.length; i++) {
      if (_children[i]["divider"] ?? false) {
        _drawer.add(Divider());
      } else {
        _drawer.add(
          ListTile(
            selected: i == _currentIndex,
            leading: _children[i]["icon"],
            title: _children[i]["name"],
            onTap: () {
              changeIndex(i);
            },
          ),
        );
      }
    }

    var child = _children[_currentIndex];
    return Scaffold(
      key: _layoutKey,
      body: child["page"],
      drawer: Drawer(
        child: ListView(
          children: _drawer,
        ),
      ),
    );
  }
}
