part of main;

class Introduction extends StatefulWidget {
  @override
  _Introduction createState() => _Introduction();
}

class _Introduction extends State<Introduction> {
  void loginPress() {
    MagisterAuth().fullLogin().then((tokenSet) {
      account = Account(tokenSet);
      accounts.put(0, account);
      userdata.put("introduction", true);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => App()));
      appState = _AppState();
      account.magister.refresh().then((_) async {
        appState.setState(() {});
        update();
        FlushbarHelper.createSuccess(message: "$account is succesvol ingelogd")..show(_agendaKey.currentContext);
        await account.magister.downloadProfilePicture();
        appState.setState(() {});
      }).catchError((e) {
        FlushbarHelper.createError(message: "Fout bij ophalen van gegevens:\n$e")..show(_agendaKey.currentContext);
        throw (e);
      });
    }).catchError((e) {
      FlushbarHelper.createError(message: "Fout bij het inloggen:\n$e")..show(context);
      throw (e);
    });
  }

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
              description: "\nMagister is van gister, Argo is van vandaag.\n\n Deze app is niet alleen mooi, hij is ook nog is zeer zwaar in de bèta dus verwacht niet veel.",
              backgroundColor: Color(0xff264653),
            ),
            Slide(
              title: "Kies je thema",
              widgetDescription: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 2 - 70,
                        child: Column(
                          children: [
                            Card(
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
                            Card(
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
                            RadioListTile(
                              title: Text(
                                "Licht",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
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
                                    print(userdata.get("theme"));
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 2 - 70,
                        child: Column(
                          children: [
                            Card(
                              color: Colors.grey[800],
                              margin: EdgeInsets.symmetric(
                                vertical: 25,
                              ),
                              child: Container(
                                height: 75,
                              ),
                            ),
                            PlaceholderLines(
                              count: 3,
                              color: Colors.grey[800],
                            ),
                            Card(
                              color: Colors.grey[800],
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
                              color: Colors.grey[800],
                            ),
                            RadioListTile(
                              value: "donker",
                              title: Text(
                                "Donker",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                                softWrap: false,
                                overflow: TextOverflow.visible,
                              ),
                              activeColor: Colors.white,
                              groupValue: userdata.get("theme"),
                              onChanged: (value) {
                                setState(
                                  () {
                                    userdata.put("theme", value);
                                    print(userdata.put("theme", value));
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              backgroundColor: Color(0xff2A9D8F),
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
                      height: 70,
                      child: RaisedButton(
                        color: Color(0xffE9C46A),
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
              backgroundColor: Color(0xffE9C46A),
            ),
          ],
        ),
      ),
    );
  }
}
