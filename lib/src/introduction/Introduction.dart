part of main;

class Introduction extends StatefulWidget {
  @override
  _Introduction createState() => _Introduction();
}

class _Introduction extends State<Introduction> {
  void login(context) async {
    print("Logging in");
    if (magisterAuth.tokenSet is MagisterTokenSet && magisterAuth.tokenSet != null) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => App(),
      ));
      print(magisterAuth.tokenSet.accessToken);
    } else {
      await magisterAuth.fullLogin(callback: () => login(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    IntroSlider intro = new IntroSlider(
      isShowSkipBtn: false,
      colorDot: Color.fromRGBO(255, 255, 255, .5),
      nameDoneBtn: "LOGIN",
      onDonePress: () {
        login(context);
      },
      slides: [
        new Slide(
          title: "Magistex",
          description: "Een moderne magister app.\nStart snel op en is gebruiksvriendelijk",
          backgroundColor: Colors.lightBlue,
        ),
        new Slide(
          title: "Login",
          widgetDescription: Center(
            child: RaisedButton(
                child: Text("Login"),
                onPressed: () {
                  login(context);
                }),
          ),
          backgroundColor: Colors.teal,
        ),
      ],
    );
    return intro;
  }
}
