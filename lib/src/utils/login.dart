import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';

import 'package:argo/src/utils/bodyHeight.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:futuristic/futuristic.dart';
import 'package:share/share.dart';
import 'package:webview_flutter/platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:pointycastle/export.dart' as castle;
import 'package:url_launcher/url_launcher.dart';
import 'package:uni_links/uni_links.dart';

import 'package:argo/src/ui/components/Card.dart';
import 'package:argo/src/ui/components/ListTileDivider.dart';

import 'package:argo/src/utils/hive/adapters.dart';
import 'package:argo/src/utils/boxes.dart';

class _CenteredLoading extends StatelessWidget {
  final String text;

  _CenteredLoading(this.text);

  @override
  Widget build(context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text),
          CircularProgressIndicator(),
        ],
      ),
    );
  }
}

class _Error extends StatelessWidget {
  final void Function() retry;
  final error;
  final void Function() skip;
  _Error({
    @required this.error,
    @required this.retry,
    this.skip,
  });

  @override
  Widget build(context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Er is een fout opgetreden",
            textScaleFactor: 1.6,
          ),
          Text(
            error.toString(),
            textScaleFactor: .9,
            softWrap: false,
          ),
          Text(
            "Stacktrace:",
            textScaleFactor: 1.6,
          ),
          Text(
            error?.stackTrace?.toString(),
            maxLines: 10,
            textScaleFactor: .9,
            softWrap: false,
          ),
          if (error.runtimeType == DioError && error.response != null)
            Text(
              error.response.data.toString(),
              maxLines: 10,
              textScaleFactor: .9,
              softWrap: false,
            ),
          Text(
            "Je kan ervoor kiezen om het opnieuw te proberen, als dat niet werkt kan je deze informatie met ons delen. Je kan vervolgens op Doorgaan klikken, maar dit is op eigen risico.",
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton.icon(
                icon: Icon(Icons.refresh_outlined),
                label: Text("Retry"),
                onPressed: retry,
              ),
              if (skip != null)
                ElevatedButton.icon(
                  icon: Icon(Icons.report_off_outlined),
                  label: Text("Doorgaan"),
                  onPressed: skip,
                ),
              ElevatedButton.icon(
                onPressed: () {
                  Share.share("Error:\n\n${error.toString()}\n\n\nStacktrace:\n\n${error?.stackTrace?.toString()}");
                },
                icon: Icon(Icons.share),
                label: Text("Deel informatie"),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class LoginView extends StatelessWidget {
  final MagisterLogin magisterLogin;
  final String title;

  final ValueNotifier<String> redirectUrl = ValueNotifier(null);

  LoginView(this.magisterLogin, this.title);

  _CenteredLoading Function(BuildContext) busyBuilder(String text) {
    return (BuildContext context) => _CenteredLoading(text);
  }

  Widget errorBuilder(BuildContext context, Object error, void Function() retry) {
    return _Error(
      error: error,
      retry: retry,
    );
  }

  @override
  Widget build(BuildContext context) {
    WebViewController controller;
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? "Inloggen"),
        actions: [
          ValueListenableBuilder(
            valueListenable: redirectUrl,
            builder: (context, _, _a) {
              if (redirectUrl.value != null) {
                return Container();
              }

              return PopupMenuButton(
                onSelected: (value) {
                  if (value == "herlaad") {
                    magisterLogin.url = magisterLogin.createURL();
                    controller?.loadUrl(magisterLogin.url);
                  } else {
                    launch(magisterLogin.url);
                    linkStream.first.then((link) => redirectUrl.value = link);
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: "herlaad",
                    child: Text("Herlaad"),
                  ),
                  PopupMenuItem(
                    value: "browser",
                    child: Text("Open in browser"),
                  )
                ],
              );
            },
          )
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: redirectUrl,
        builder: (context, _, _a) {
          if (redirectUrl.value == null) {
            CookieManager().clearCookies();

            return WebView(
              initialUrl: magisterLogin.url,
              javascriptMode: JavascriptMode.unrestricted,
              onWebResourceError: (error) {
                if (error.errorType == WebResourceErrorType.unsupportedScheme) {
                  print("er was een error, reload");
                  magisterLogin.url = magisterLogin.createURL();
                  controller?.loadUrl(magisterLogin.url);
                }
              },
              navigationDelegate: (req) {
                if (req.url.contains("#code")) {
                  redirectUrl.value = req.url;
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
              onWebViewCreated: (c) {
                controller = c;
              },
            );
          }
          return Container(
            height: bodyHeight(context),
            child: Futuristic<Map>(
              autoStart: true,
              errorBuilder: errorBuilder,
              busyBuilder: busyBuilder("Inlog verifiëren"),
              futureBuilder: () async => magisterLogin.getTokenSet(redirectUrl.value, context),
              dataBuilder: (context, tokenSet) {
                var account = Account(tokenSet);
                return Futuristic(
                  autoStart: true,
                  errorBuilder: errorBuilder,
                  busyBuilder: busyBuilder("Account id en school ophalen"),
                  futureBuilder: () async {
                    if (account.tenant == null) {
                      await account.magister.profileInfo.getTenant();
                    }

                    if (account.id == 0) {
                      await account.magister.profileInfo.profileInfo();
                    }

                    return Future.value(true);
                  },
                  dataBuilder: (context, _) {
                    bool accountExists = accounts.values.any((acc) => acc.id == account.id);
                    if (accountExists) {
                      Timer.run(() {
                        Fluttertoast.showToast(
                          msg: "$account is al ingelogd!",
                        );
                        magisterLogin.url = magisterLogin.createURL();
                        redirectUrl.value = null;
                      });

                      return Center(
                        child: Text("$account is al ingelogd!"),
                      );
                    }
                    return RefreshAccountView(account, context, magisterLogin.callback);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class MagisterLoader extends StatelessWidget {
  final String name;
  final Future Function() future;
  final ValueNotifier<int> count;
  final ValueNotifier<List<List>> errors;
  MagisterLoader({this.name, this.future, this.count, this.errors});
  @override
  Widget build(c) {
    return MaterialCard(
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.only(top: 4.5),
          child: Text(
            name,
            style: TextStyle(fontSize: 17.5),
          ),
        ),
        trailing: Futuristic(
          autoStart: true,
          futureBuilder: future,
          busyBuilder: (context) => CircularProgressIndicator(),
          onData: (_) {
            count.value++;
          },
          onError: (error, retry) {
            errors.value = List.from(errors.value)..add([error, retry]);
          },
          errorBuilder: (context, error, retry) => Icon(
            Icons.clear,
            color: Colors.red,
          ),
          dataBuilder: (c, d) => Icon(
            Icons.check,
            color: Colors.green,
          ),
        ),
      ),
    );
  }
}

class RefreshAccountView extends StatelessWidget {
  final ValueNotifier<int> totalLoaded = ValueNotifier(0);

  final ValueNotifier<List<List>> errors = ValueNotifier([]);
  static List<Widget> loaders;
  final Account account;
  final BuildContext context;
  final Function callback;
  RefreshAccountView(this.account, this.context, this.callback) {
    loaders = [
      if (account.has("Afspraken", "Read"))
        MagisterLoader(
          name: "Agenda",
          future: account.magister.agenda.refresh,
          count: totalLoaded,
          errors: errors,
        ),
      if (account.has("Absenties", "Read"))
        MagisterLoader(
          name: "Afwezigheid",
          future: account.magister.afwezigheid.refresh,
          count: totalLoaded,
          errors: errors,
        ),
      if (account.has("Berichten", "Read"))
        MagisterLoader(
          name: "Berichten",
          future: account.magister.berichten.refresh,
          count: totalLoaded,
          errors: errors,
        ),
      if (account.has("Bronnen", "Read"))
        MagisterLoader(
          name: "Bronnen",
          future: account.magister.bronnen.refresh,
          count: totalLoaded,
          errors: errors,
        ),
      if (account.has("Cijfers", "Read"))
        MagisterLoader(
          name: "Cijfers",
          future: account.magister.cijfers.refresh,
          count: totalLoaded,
          errors: errors,
        ),
      if (account.has("DigitaalLesmateriaal", "Read"))
        MagisterLoader(
          name: "Leermiddelen",
          future: account.magister.leermiddelen.refresh,
          count: totalLoaded,
          errors: errors,
        ),
      if (account.has("Studiewijzers", "Read"))
        MagisterLoader(
          name: "Studiewijzers",
          future: account.magister.studiewijzers.refresh,
          count: totalLoaded,
          errors: errors,
        ),
      MagisterLoader(
        name: "Profiel Info",
        future: account.magister.profileInfo.refresh,
        count: totalLoaded,
        errors: errors,
      ),
      MagisterLoader(
        name: "Profiel Foto",
        future: account.magister.downloadProfilePicture,
        count: totalLoaded,
        errors: errors,
      ),
    ];
    totalLoaded.addListener(() {
      if (totalLoaded.value == loaders.length) {
        if (!account.isInBox) accounts.add(account);
        Navigator.pop(context);
        callback(account, context);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ValueListenableBuilder(
          valueListenable: totalLoaded,
          builder: (c, loaded, _) => LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Color.fromRGBO(
                255,
                255,
                255,
                1,
              ),
            ),
            backgroundColor: userdata.get("primaryColor"),
            value: loaded / loaders.length,
          ),
        ),
        ...divideListTiles(loaders),
        ValueListenableBuilder(
          valueListenable: errors,
          builder: (context, _, _a) {
            if (errors.value.isEmpty) {
              return Container();
            } else {
              var error = errors.value.first.first;
              return _Error(
                error: error,
                retry: () {
                  errors.value.forEach(
                    (error) => error.last(),
                  );
                  errors.value = [];
                },
                skip: () {
                  totalLoaded.value = loaders.length;
                },
              );
            }
          },
        ),
      ],
    );
  }
}

class MagisterLogin {
  // Dit is niet meer Sjoerd zijn code, maar ik heb er wel zeker gebruik van gemaakt om te weten hoe dit werkt.
  // https://github.com/Argo-Magister/App/blob/07c73024e9ed131d746626610910b53d616b2a5e/lib/src/utils/magister/login.dart
  String codeVerifier;
  String url;
  String title;
  Function callback;
  Map preFill;

  void launch(context, Function cb, {Map preFill, String title}) {
    this.preFill = preFill;
    this.callback = cb;
    this.title = title;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LoginView(this, title),
      ),
    );
  }

  MagisterLogin() {
    this.url = createURL();
  }

  String _generateRandomString() {
    var r = Random.secure();
    var chars = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    return Iterable.generate(50, (_) => chars[r.nextInt(chars.length)]).join();
  }

  String _generateRandomBase64(length) {
    var r = Random.secure();
    var chars = 'abcdef0123456789';
    return Iterable.generate(length, (_) => chars[r.nextInt(chars.length)]).join();
  }

  String createURL() {
    String nonce = _generateRandomBase64(32);
    this.codeVerifier = _generateRandomString();
    String state = _generateRandomString();
    String codeChallenge = base64Url.encode(castle.SHA256Digest().process(Uint8List.fromList(this.codeVerifier.codeUnits))).replaceAll('=', '');
    String str = "https://accounts.magister.net/connect/authorize?client_id=M6LOAPP&redirect_uri=m6loapp%3A%2F%2Foauth2redirect%2F&scope=openid%20profile%20offline_access%20magister.mobile%20magister.ecs&response_type=code%20id_token&state=$state&nonce=$nonce&code_challenge=$codeChallenge&code_challenge_method=S256";
    if (preFill != null) {
      str += "&acr_values=tenant:${preFill["tenant"]}&prompt=select_account&login_hint=${preFill['username']}";
    }
    return str;
  }

  Future<Map> getTokenSet(String url, BuildContext context) async {
    String code = url.replaceFirst(RegExp("^m6.*#code="), "").split("&")[0];

    Response res = await Dio().post(
      "https://accounts.magister.net/connect/token",
      options: Options(
        contentType: "application/x-www-form-urlencoded",
      ),
      data: "code=$code&redirect_uri=m6loapp://oauth2redirect/&client_id=M6LOAPP&grant_type=authorization_code&code_verifier=$codeVerifier",
    );
    return res.data;
  }
}
