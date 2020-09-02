part of main;

final _formKey = GlobalKey<FormState>();

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

String randomSchool() {
  return schoolUrls[new Random().nextInt(schoolUrls.length)].capitalize();
}

class Introduction extends StatelessWidget {
  final FlutterAppAuth appAuth = FlutterAppAuth();
  Function goToTab;
  // List<String> schoolUrls;
  // @override
  // void initState() {
  //   super.initState();
  // }

  void validateSchool(context) async {
    print("Validating");
    if (_formKey.currentState == null || _formKey.currentState.validate()) {
      print("Logging in");
      // final AuthorizationTokenResponse result = await appAuth.authorizeAndExchangeCode(AuthorizationTokenRequest(
      //   "M6LOAPP",
      //   'm6loapp://oauth2redirect',
      //   discoveryUrl: ' https://accounts.magister.net/',
      //   serviceConfiguration: AuthorizationServiceConfiguration(
      //     'https://accounts.magister.net/connect/authorize',
      //     'https://accounts.magister.net/connect/token',
      //   ),
      //   scopes: ["openid", "profile", "offline_access", "magister.mobile", "magister.ecs"],
      // ));
      // print(result);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('seen', true);
      Navigator.pushNamed(context, '/');
    } else {
      this.goToTab(1);
    }
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
          description:
              "Een moderne magister app.\nStart snel op en is gebruiksvriendelijk",
          backgroundColor: Colors.lightBlue,
        ),
        new Slide(
          title: "Kies uw school",
          widgetDescription: Column(
            children: [
              Text("Bijv. " + randomSchool()),
              Form(
                key: _formKey,
                child: TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.school),
                    hintText: "Zoek een school",
                    labelText: 'School',
                  ),
                  autofocus: true,
                  onChanged: (String value) {
                    print(value);
                  },
                  validator: (value) {
                    value = value
                        .replaceAll(
                            new RegExp(r'(http|https)://|.magister.net'), "")
                        .toLowerCase();
                    print(value);
                    if (value.isEmpty) {
                      return "Vergeet niet je school in te vullen!";
                    }
                    if (!schoolUrls.contains(value)) {
                      return "Dit is niet de naam van een school, probeer bijvoorbeeld \n" +
                          randomSchool();
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          backgroundColor: Colors.redAccent,
        ),
        new Slide(
          title: "Login",
          widgetDescription: Center(
            child: RaisedButton(
              child: Text("Login"),
              onPressed: () {
                validateSchool(context);
              },
            ),
          ),
          backgroundColor: Colors.teal,
        ),
      ],
      onDonePress: () {
        validateSchool(context);
      },
    );
    return intro;
  }
}
