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
        Agenda.of(_agendaKey.currentContext).setState(() {});
        FlushbarHelper.createSuccess(message: "$account is succesvol ingelogd")..show(_agendaKey.currentContext);
        await account.magister.downloadProfilePicture();
        appState.setState(() {});
      }).catchError((e) {
        print(e);
        FlushbarHelper.createError(message: "Fout bij ophalen van gegevens:\n$e")..show(_agendaKey.currentContext);
      });
    }).catchError((e) {
      print(e);
      FlushbarHelper.createError(message: "Fout bij het inloggen:\n$e")..show(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) => new IntroSlider(
          isShowSkipBtn: false,
          colorDot: Color.fromRGBO(255, 255, 255, .5),
          nameDoneBtn: "LOGIN",
          onDonePress: loginPress,
          slides: [
            Slide(
              title: "Magistex",
              description: "Een moderne magister app.\nStart snel op en is gebruiksvriendelijk",
              backgroundColor: Colors.lightBlue,
            ),
            Slide(
              title: "Login",
              widgetDescription: Center(
                child: RaisedButton(
                  child: Text("Login"),
                  onPressed: loginPress,
                ),
              ),
              backgroundColor: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }
}
