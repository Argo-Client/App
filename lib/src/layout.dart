part of main;

int _currentIndex = 0;
final GlobalKey<ScaffoldState> _layoutKey = new GlobalKey<ScaffoldState>();

class HomeState extends State<Home> with AfterLayoutMixin<Home> {
  void afterFirstLayout(BuildContext context) {
    if (userdata.containsKey("introduction")) {
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => App()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Introduction()));
    }
  }

  void changeIndex(int index) {
    _currentIndex = index;
    // homeState.setState(() {});
    Navigator.pop(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool useIcon = account.profilePicture == null || userdata.get("userIcon") != Icons.person;
    final List<Widget> _drawer = [
      UserAccountsDrawerHeader(
        accountName: Text(account.fullName),
        accountEmail: Text(account.klasCode),
        currentAccountPicture: CircleAvatar(
          backgroundColor: Theme.of(context).backgroundColor,
          backgroundImage: !useIcon ? Image.memory(base64Decode(account.profilePicture)).image : null,
          child: useIcon
              ? Icon(
                  userdata.get("userIcon"),
                  size: 50,
                )
              : null,
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
          padding: EdgeInsets.all(0),
          children: _drawer,
        ),
      ),
    );
  }
}
