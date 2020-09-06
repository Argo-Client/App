part of main;

class Introduction extends StatefulWidget {
  @override
  _Introduction createState() => _Introduction();
}

class _Introduction extends State<Introduction> {
  @override
  Widget build(BuildContext context) {
    void gotoApp() {
      userdata.put("introduction", true);
      Navigator.pushNamed(context, '/');
    }

    return MaterialApp(
        title: "Introduction",
        home: new IntroSlider(
          isShowSkipBtn: false,
          colorDot: Color.fromRGBO(255, 255, 255, .5),
          nameDoneBtn: "LOGIN",
          onDonePress: () {
            magisterAuth.checkThenLogin(gotoApp);
          },
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
                    onPressed: () {
                      magisterAuth.checkThenLogin(gotoApp);
                    }),
              ),
              backgroundColor: Colors.teal,
            ),
          ],
        ));
  }
}
