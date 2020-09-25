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
    bool useIcon = account.profilePicture == null || userdata.get("userIcon") != Icons.person;

    final List<Widget> _accountsDrawer = [
      for (Account acc in accounts.toMap().values)
        ListTile(
          trailing: PopupMenuButton(
            onSelected: (result) async {
              if (result == "herlaad") {
                Flushbar msg = FlushbarHelper.createInformation(message: 'Laden')..show(context);
                acc.magister.refresh().then((_) {
                  msg.dismiss();
                  FlushbarHelper.createSuccess(message: '$acc is ververst!')..show(context);
                }).catchError((e) {
                  print(e);
                  FlushbarHelper.createError(message: 'Fout tijdens verversen:\n$e')..show(context);
                });
              } else {
                accounts.delete(accounts.values.toList().indexWhere((a) => a.id == acc.id));
                userdata.put("accountIndex", 0);
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
                    userdata.get("userIcon"),
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
          onTap: () {
            int index = accounts.toMap().values.toList().indexWhere((g) => g.id == acc.id);
            setState(() {
              userdata.put("accountIndex", index);
              account = accounts.get(index);
              Agenda.of(_agendaKey.currentContext).setState(() {});
            });
          },
        ),
      ListTile(
        leading: Icon(Icons.add),
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
                await account.magister.downloadProfilePicture();
                setState(() {});
              }).catchError((e) {
                print(e);
                FlushbarHelper.createError(message: "Fout bij ophalen van gegevens:\n$e")..show(_agendaKey.currentContext);
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

    return Scaffold(
      key: _layoutKey,
      body: child["page"],
      drawer: Drawer(
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
                      onTap: () {
                        int index = accounts.toMap().values.toList().indexWhere((g) => g.id == acc.id);
                        setState(() {
                          userdata.put("accountIndex", index);
                          account = accounts.get(index);
                          Agenda.of(_agendaKey.currentContext).setState(() {});
                        });
                      },
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).backgroundColor,
                        backgroundImage: !useIcon && acc.profilePicture != null ? Image.memory(base64Decode(acc.profilePicture)).image : null,
                        child: useIcon
                            ? Icon(
                                userdata.get("userIcon"),
                                size: 25,
                              )
                            : null,
                      ),
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
    );
  }
}
