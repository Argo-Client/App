part of main;

int _currentIndex = 0;
final GlobalKey<ScaffoldState> _layoutKey = new GlobalKey<ScaffoldState>();

class HomeState extends State<Home> with AfterLayoutMixin<Home> {
  bool _detailsPressed = false;
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

    final List<Widget> _accountsDrawer = [
      for (Account acc in accounts.toMap().values)
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).backgroundColor,
            backgroundImage: !useIcon ? Image.memory(base64Decode(acc.profilePicture)).image : null,
            child: useIcon
                ? Icon(
                    userdata.get("userIcon"),
                    size: 50,
                  )
                : null,
          ),
          title: Text(
            acc.fullName,
          ),
          subtitle: Text(
            acc.klasCode,
          ),
        ),
      ListTile(
        leading: Icon(Icons.add),
        title: Text("Voeg account toe"),
        onTap: () {
          magisterAuth.fullLogin((tokenSet) async {
            if (tokenSet != null) {
              Account newAccount = Account();
              newAccount.saveTokens(tokenSet);
              await newAccount.magister.profileInfo.profileInfo();
              if (newAccount.id != null && !accounts.values.any((acc) => acc.id == newAccount.id)) {
                await account.magister.refresh();
                accounts.add(newAccount);
                userdata.put("accountIndex", accounts.length - 1);
                account = newAccount;
                print('$account is toegevoegd');
              } else {
                print("Account bestaat al");
              }
            }
          });
        },
      ),
    ];

    final List<Widget> _drawer = [];

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
          children: [
            UserAccountsDrawerHeader(
              onDetailsPressed: () => {
                setState(
                  () {
                    _detailsPressed = !_detailsPressed;
                  },
                ),
              },
              otherAccountsPictures: [
                for (Account acc in accounts.toMap().values)
                  if (acc.id != account.id)
                    CircleAvatar(
                      backgroundColor: Theme.of(context).backgroundColor,
                      backgroundImage: !useIcon ? Image.memory(base64Decode(acc.profilePicture)).image : null,
                      child: useIcon
                          ? Icon(
                              userdata.get("userIcon"),
                              size: 50,
                            )
                          : null,
                    ),
              ],
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
            Column(
              children: _detailsPressed ? _accountsDrawer : _drawer,
            ),
          ],
        ),
      ),
    );
  }
}
