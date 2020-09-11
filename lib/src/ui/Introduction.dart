part of main;

class Introduction extends StatefulWidget {
  @override
  _Introduction createState() => _Introduction();
}

class _Introduction extends State<Introduction> {
  void loginPress() {
    magisterAuth.fullLogin((tokenSet) {
      account.saveTokens(tokenSet);
      userdata.put("introduction", true);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => App()));
      appState = _AppState();
      Magister().refresh().then((value) => appState.setState(() {}));
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
