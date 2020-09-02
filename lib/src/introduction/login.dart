import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

class MagisterAuth {
  final String authURL = "https://accounts.magister.net/connect/authorize";
  final String tokenURL = "https://accounts.magister.net/connect/token";
  final String tenant;
  String codeVerifier;
  String codeChallenge;
  String nonce;
  String state;
  String code;

  MagisterAuth(this.tenant) {
    this.nonce = this.generateRandomBase64(32);
    this.state = this.generateRandomString(16);
    this.codeVerifier = generateRandomString(128);
    this.codeChallenge = generateCodeChallenge(codeVerifier);
  }

  String generateRandomString(length) {
    String text = "";
    String possible = "abcdefhijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVW0123456789";
    for (int i = 0; i < length; i++) {
      Random random = new Random();
      text += possible[random.nextInt(possible.length)];
    }
    return text;
  }

  String generateCodeVerifier() {
    return generateRandomString(128);
  }

  String generateRandomBase64(length) {
    var text = "";
    var possible = "abcdef0123456789";
    for (var i = 0; i < length; i++) {
      Random random = new Random();
      text += possible[random.nextInt(possible.length)];
    }
    return text;
  }

  String generateCodeChallenge(verifier) {
    return base64URL(verifier);
    // return base64URL(sha256.convert(verifier));
  }

  String base64URL(string) {
    return string
        .toString()
        // .toString(CryptoJS.enc.Base64)
        .replaceAll("/=/g", "")
        .replaceAll("/\+/g", "-")
        .replaceAll("/\//g", "_")
        .toString();
  }

  Future<String> getURL() async {
    return "https://accounts.magister.net/connect/authorize/?client_id=M6LOAPP&redirect_uri=m6loapp%3A%2F%2Foauth2redirect%2F&scope=openid%20profile%20offline_access%20magister.mobile%20magister.ecs&response_type=code%20id_token&state=$state&nonce=$nonce&code_challenge=$codeChallenge&code_challenge_method=S256&acr_values=tenant:$tenant&prompt=select_account";
  }

  Future getTokens() async {
    String formBody = Uri.encodeQueryComponent("code=$code&redirect_uri=m6loapp%3A%2F%2Foauth2redirect%2F&client_id=M6LOAPP&grant_type=authorization_code&code_verifier=$codeVerifier");
    List<int> bodyBytes = utf8.encode(formBody); // utf8 encode
    HttpClientRequest request = await HttpClient().post(tokenURL, 80, "");
    request.add(bodyBytes);
    return await request.close();

    // return "$tokenURL?client_id=M6LOAPP&redirect_uri=m6loapp%3A%2F%2Foauth2redirect%2F&scope=openid%20profile%20offline_access%20magister.mobile%20magister.ecs&response_type=code%20id_token&state=$state&nonce=$nonce&code_challenge=$codeChallenge&code_challenge_method=S256&acr_values=tenant:$tenant&prompt=select_account";
  }

  Future fullLogin() async {
    String authURL = await this.getURL();
    print(authURL);
    // code=${code}&redirect_uri=m6loapp%3A%2F%2Foauth2redirect%2F&client_id=M6LOAPP&grant_type=authorization_code&code_verifier=${codeVerifier}
    // await launch(authURL);
    // StreamSubscription _sub;
    // _sub = getLinksStream().listen((String link) async {
    //   print(link);
    //   code = link.substring(link.indexOf("code=") + 5, link.indexOf("&"));
    //   print(code);
    //   print(await this.getTokens());
    //   _sub.cancel();
    // }, onError: (err) {
    //   _sub.cancel();
    //   throw Exception("Stream error ofzo idk");
    // });
  }
}
