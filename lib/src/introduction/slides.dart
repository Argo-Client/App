part of main;

final _formKey = GlobalKey<FormState>();

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

String randomSchool() {
  return schools[new Random().nextInt(schools.length)].capitalize();
}

class Introduction extends StatelessWidget {
  final FlutterAppAuth appAuth = FlutterAppAuth();
  Function goToTab;
  // List<String> schoolUrls;
  // @override
  // void initState() {
  //   super.initState();
  // }

  void login(context) async {
    print("Logging in");
    if (magisterAuth.tokenSet is MagisterTokenSet && magisterAuth.tokenSet != null) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => App(),
      ));
      print(magisterAuth.tokenSet.accessToken);
    }
    await magisterAuth.fullLogin(callback: () => login(context));
  }

  @override
  Widget build(BuildContext context) {
    IntroSlider intro = new IntroSlider(
      isShowSkipBtn: false,
      colorDot: Color.fromRGBO(255, 255, 255, .5),
      refFuncGoToTab: (index) {
        this.goToTab = index;
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
      onDonePress: () {
        login(context);
      },
    );
    return intro;
  }
}
