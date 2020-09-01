part of main;

class IntroScreenState extends State<IntroScreen> {
  final FlutterAppAuth appAuth = FlutterAppAuth();
  @override
  void initState() {
    super.initState();
  }

  void onDonePress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Navigator.of(context).pushReplacement(
      new MaterialPageRoute(
        builder: (context) => new MaterialApp(
          title: 'Magistex',
          theme: ThemeData(
            primaryColor: Colors.blue,
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => Agenda(),
            '/cijfers': (context) => Cijfers(),
          },
        ),
      ),
    );
    await prefs.setBool('seen', true);
  }

  @override
  Widget build(BuildContext context) {
    return new IntroSlider(
      isShowSkipBtn: false,
      slides: [
        new Slide(
          title: "Magistex",
          description: "Een moderne magister app.\nStart snel op en is gebruiksvriendelijk",
          backgroundColor: Colors.lightBlue,
        ),
        new Slide(
          title: "Kies uw school",
          widgetDescription: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.school),
                  hintText: 'Zoek uw school',
                  labelText: 'School',
                ),
                onSaved: (String value) {
                  print(value);
                },
              )
            ],
          ),
          backgroundColor: Colors.amberAccent,
        ),
        new Slide(
          title: "Login",
          widgetDescription: Center(
            child: FlatButton(
              child: Text("Login"),
              onPressed: () async {
                final AuthorizationTokenResponse result = await appAuth.authorizeAndExchangeCode(
                  AuthorizationTokenRequest(
                    "m6loapp",
                    'm6loapp://oauth2redirect',
                    discoveryUrl: ' https://accounts.magister.net/',
                    serviceConfiguration: AuthorizationServiceConfiguration(
                      'https://accounts.magister.net/connect/authorize',
                      'https://accounts.magister.net/connect/token',
                    ),
                    scopes: ["openid", "profile", "offline_access", "magister.mobile", "magister.ecs"],
                  ),
                );
                print(result);
              },
            ),
          ),
          backgroundColor: Colors.teal,
        ),
      ],
      onDonePress: this.onDonePress,
    );
  }
}
