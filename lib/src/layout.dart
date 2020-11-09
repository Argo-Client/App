part of main;

int _currentIndex = 1;
final GlobalKey<ScaffoldState> _layoutKey = new GlobalKey<ScaffoldState>();
final GlobalKey<State> _drawerState = new GlobalKey<State>();

class HomeState extends State<Home> with AfterLayoutMixin<Home> {
  bool _detailsPressed = false;
  void afterFirstLayout(BuildContext context) {
    if (!userdata.containsKey("introduction")) {
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => App()));
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
    var child = _children[_currentIndex];
    bool useIcon = account.profilePicture == null || userdata.get("useIcon");
    void changeAccount(int id) {
      int index = accounts.toMap().entries.firstWhere((g) => g.value.id == id).key;
      if (userdata.get("accountIndex") != index) {
        setState(() {
          userdata.put("accountIndex", index);
          account = accounts.get(index);
          update();
        });
      }
    }

    final List<Widget> _accountsDrawer = [
      for (Account acc in accounts.toMap().values)
        ListTile(
          trailing: PopupMenuButton(
            onSelected: (result) async {
              if (result == "herlaad") {
                Flushbar msg = FlushbarHelper.createInformation(message: 'Laden')..show(context);
                await handleError(acc.magister.refresh, "Fout tijdens verversen", context, () async {
                  FlushbarHelper.createSuccess(message: "$acc is ververst!")..show(context);
                  update();
                  await acc.magister.downloadProfilePicture();
                  setState(() {});
                });
                msg..dismiss();
              } else {
                accounts.delete(accounts.toMap().entries.firstWhere((a) => a.value.id == acc.id).key);
                if (accounts.isEmpty) {
                  accounts.clear();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Introduction(),
                    ),
                  );
                  return;
                }
                userdata.put("accountsIndex", accounts.toMap().entries.first.key);
                setState(() {});
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              const PopupMenuItem(
                value: "verwijder",
                child: Text('Verwijder'),
              ),
              const PopupMenuItem(
                value: "herlaad",
                child: Text('Herlaad'),
              ),
            ],
          ),
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).backgroundColor,
            backgroundImage: !useIcon && acc.profilePicture != null ? Image.memory(base64Decode(acc.profilePicture)).image : null,
            child: useIcon
                ? Icon(
                    Icons.person,
                    size: 25,
                  )
                : null,
          ),
          title: Text(
            acc.fullName,
          ),
          subtitle: Text(
            acc.klasCode,
          ),
          onTap: () => changeAccount(acc.id),
        ),
      ListTile(
        leading: Icon(Icons.add_outlined),
        title: Text("Voeg account toe"),
        onTap: () {
          MagisterAuth().fullLogin().then((tokenSet) async {
            Account newAccount = Account(tokenSet);
            newAccount.magister.expiryAndTenant();
            await newAccount.magister.profileInfo.profileInfo();
            if (newAccount.id != null && !accounts.values.any((acc) => acc.id == newAccount.id)) {
              account = newAccount;
              accounts.add(account);
              account.saveTokens(tokenSet);
              account.magister.refresh().then((_) async {
                userdata.put("accountIndex", accounts.length - 1);
                setState(() {});
                FlushbarHelper.createSuccess(message: '$account is toegevoegd')..show(context);
                update();
                await account.magister.downloadProfilePicture();
                setState(() {});
              }).catchError((e) {
                FlushbarHelper.createError(message: "Fout bij ophalen van gegevens:\n$e")..show(_agendaKey.currentContext);
                throw (e);
              });
            } else {
              FlushbarHelper.createError(message: '$account bestaat al')..show(context);
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

    return WillPopScope(
      onWillPop: () {
        if (!userdata.get("backOpensDrawer") || child["overridePop"] != null) return Future.value(true);
        if (_layoutKey.currentState.isDrawerOpen) {
          Navigator.of(context).pop();
        } else {
          _layoutKey.currentState.openDrawer();
        }
        return Future.value(false);
      },
      child: Scaffold(
        key: _layoutKey,
        body: child["page"],
        drawer: Drawer(
          child: Container(
            color: userdata.get("theme") == "OLED" ? Colors.black : null,
            child: ListView(
              padding: EdgeInsets.all(0),
              children: [
                UserAccountsDrawerHeader(
                  onDetailsPressed: () => {
                    _drawerState.currentState.setState(
                      () {
                        _detailsPressed = !_detailsPressed;
                      },
                    ),
                  },
                  otherAccountsPictures: [
                    for (Account acc in accounts.toMap().values)
                      if (acc.id != account.id)
                        InkWell(
                          onTap: () => changeAccount(acc.id),
                          child: CircleAvatar(
                            backgroundColor: Theme.of(context).backgroundColor,
                            backgroundImage: !useIcon && acc.profilePicture != null ? Image.memory(base64Decode(acc.profilePicture)).image : null,
                            child: useIcon
                                ? Icon(
                                    Icons.person,
                                    size: 25,
                                  )
                                : null,
                          ),
                        ),
                  ],
                  accountName: Text(account.fullName),
                  accountEmail: Text(account.klasCode),
                  currentAccountPicture: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).backgroundColor,
                        backgroundImage: !useIcon
                            ? Image.memory(
                                base64Decode(account.profilePicture),
                              ).image
                            : null,
                        child: useIcon
                            ? Icon(
                                Icons.person_outline,
                                size: 50,
                              )
                            : null,
                      ),
                      // Align(
                      //   alignment: Alignment.bottomRight,
                      //   child: Icon(
                      //     Icons.star,
                      //     size: 25,
                      //     color: Color.fromARGB(255, 255, 223, 0),
                      //   ),
                      // ),
                    ],
                  ),
                ),
                StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Column(
                      children: _detailsPressed ? _accountsDrawer : _drawer,
                    );
                  },
                  key: _drawerState,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
