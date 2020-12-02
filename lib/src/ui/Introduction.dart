part of main;

class Introduction extends StatefulWidget {
  @override
  _Introduction createState() => _Introduction();
}

class _Introduction extends State<Introduction> {
  List _colors = [
    0xff5BC3EB,
    0xffDADAD9,
    0xffF06449,
  ];
  void onLoggedIn(Account acc, BuildContext context, {String error}) {
    if (acc == null) {
      return;
    }
    print("onlogged in met: $acc");
    account = acc;
    userdata.put("introduction", true);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => App()));
    appState = _AppState();
  }

  void loginPress() => MagisterLogin().launch(context, onLoggedIn);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) => new IntroSlider(
          isShowSkipBtn: false,
          colorDot: Color.fromRGBO(255, 255, 255, .5),
          sizeDot: 13.0,
          renderNextBtn: Icon(
            Icons.navigate_next,
            color: Colors.white,
          ),
          typeDotAnimation: dotSliderAnimation.SIZE_TRANSITION,
          nameDoneBtn: "LOGIN",
          onDonePress: loginPress,
          slides: [
            Slide(
              title: "Argo",
              pathImage: "assets/images/splash.png",
              description: "\nMagister is gister, Argo is vandaag.\n\n Deze app is niet alleen mooi, hij is ook nog is zeer zwaar in de bèta dus verwacht niet veel.",
              backgroundColor: Color(
                _colors[0],
              ),
            ),
            Slide(
              widgetTitle: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    children: [
                      Container(
                        child: Text(
                          "Kies je thema",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        padding: EdgeInsets.only(
                          bottom: 30,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(
                                () {
                                  userdata.put("theme", "licht");
                                },
                              );
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width / 2 - 70,
                              child: Column(
                                children: [
                                  SeeCard(
                                    margin: EdgeInsets.symmetric(
                                      vertical: 25,
                                    ),
                                    child: Container(
                                      height: 75,
                                    ),
                                  ),
                                  PlaceholderLines(
                                    count: 3,
                                    align: TextAlign.right,
                                    color: Colors.white,
                                  ),
                                  SeeCard(
                                    margin: EdgeInsets.symmetric(
                                      vertical: 25,
                                    ),
                                    child: Container(
                                      height: 75,
                                    ),
                                  ),
                                  PlaceholderLines(
                                    count: 3,
                                    color: Colors.white,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: 15,
                                    ),
                                    child: RadioListTile(
                                      title: Text(
                                        "Licht",
                                        softWrap: false,
                                        overflow: TextOverflow.visible,
                                      ),
                                      value: "licht",
                                      groupValue: userdata.get("theme"),
                                      activeColor: Colors.white,
                                      onChanged: (value) {
                                        setState(
                                          () {
                                            userdata.put("theme", value);
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(
                                () {
                                  userdata.put("theme", "donker");
                                },
                              );
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width / 2 - 70,
                              child: Column(
                                children: [
                                  Container(
                                    color: Colors.grey[800],
                                    margin: EdgeInsets.symmetric(
                                      vertical: 25,
                                    ),
                                    height: 75,
                                  ),
                                  PlaceholderLines(
                                    count: 3,
                                    color: Colors.grey[800],
                                  ),
                                  Container(
                                    color: Colors.grey[800],
                                    margin: EdgeInsets.symmetric(
                                      vertical: 25,
                                    ),
                                    height: 75,
                                  ),
                                  PlaceholderLines(
                                    count: 3,
                                    align: TextAlign.right,
                                    color: Colors.grey[800],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: 15,
                                    ),
                                    child: RadioListTile(
                                      value: "donker",
                                      title: Text(
                                        "Donker",
                                        softWrap: false,
                                        overflow: TextOverflow.visible,
                                      ),
                                      activeColor: Colors.grey[800],
                                      groupValue: userdata.get("theme"),
                                      onChanged: (value) {
                                        setState(
                                          () {
                                            userdata.put("theme", value);
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width * (3 / 4),
                          child: RadioListTile(
                            title: Text(
                              "Gebruik systeem standaard",
                              softWrap: false,
                              overflow: TextOverflow.visible,
                            ),
                            value: "systeem",
                            activeColor: userdata.get("accentColor"),
                            groupValue: userdata.get("theme"),
                            onChanged: (value) {
                              setState(
                                () {
                                  userdata.put("theme", value);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              backgroundColor: Color(_colors[1]),
            ),
            Slide(
              title: "Login",
              widgetDescription: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 150,
                    ),
                    child: Text(
                      "Om de app te kunnen gebruiken, moet je eerst even inloggen.\n\n Je logt in via Magister dus je wachtwoord is helemaal veilig.",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Center(
                    child: Container(
                      height: 50,
                      child: FlatButton(
                        child: Text(
                          "Log nu in!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                          ),
                        ),
                        onPressed: loginPress,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Color(_colors[2]),
            ),
          ],
        ),
      ),
    );
  }
}
