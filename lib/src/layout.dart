part of main;

int _currentIndex = 0;

class _Home extends State<Home> {
  void changeIndex(int index) {
    setState(() {
      _currentIndex = index;
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _drawer = [
      UserAccountsDrawerHeader(
        accountName: Text(Hive.box("magisterData").get("fullName", defaultValue: "Laden...")),
        accountEmail: Text(Hive.box("magisterData").get("klasCode", defaultValue: "Laden...")),
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
      appBar: child["appBar"] ??
          AppBar(
            title: child["name"],
          ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: _drawer,
        ),
      ),
      body: child["page"],
    );
  }
}
