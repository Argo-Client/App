part of main;

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawer createState() => _AppDrawer();
}

class _AppDrawer extends State<AppDrawer> {
  Box user = Hive.box("magisterData");
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
              _currentIndex = i;
              homeState.setState(() {});
              setState(() {});
            },
          ),
        );
      }
    }

    return Drawer(
      child: ListView(
        children: _drawer,
      ),
    );
  }
}
