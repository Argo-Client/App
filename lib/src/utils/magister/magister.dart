import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:Argo/src/utils/hiveObjects.dart';
import 'package:Argo/src/utils/magister/login.dart';
import 'ProfileInfo.dart';
import 'Agenda.dart';
import 'Cijfers.dart';
import 'Afwezigheid.dart';
import 'Berichten.dart';

class Magister {
  Account account;
  ProfileInfo profileInfo;
  Agenda agenda;
  Cijfers cijfers;
  MagisterApi api;
  Afwezigheid afwezigheid;
  Berichten berichten;
  Magister(Account acc) {
    this.account = acc;
    api = MagisterApi(acc);
    profileInfo = ProfileInfo(MagisterApi(acc));
    agenda = Agenda(MagisterApi(acc));
    cijfers = Cijfers(MagisterApi(acc));
    afwezigheid = Afwezigheid(MagisterApi(acc));
    berichten = Berichten(MagisterApi(acc));
  }
  void expiryAndTenant() {
    String parsed = base64.normalize(account.accessToken.split(".")[1]);
    Map data = json.decode(utf8.decode(base64Decode(parsed)));
    account.expiry = data["exp"] * 1000;
    account.username = data["urn:magister:claims:iam:username"];
    account.tenant = data["urn:magister:claims:iam:tenant"];
    if (account.isInBox) account.save();
  }

  Future refresh() async {
    expiryAndTenant();
    if (account.id == 0) await account.magister.profileInfo.profileInfo();
    return Future.wait([
      agenda.refresh(),
      profileInfo.refresh(),
      afwezigheid.refresh(),
      berichten.refresh(),
    ]);
  }

  Future downloadProfilePicture() async {
    var img = (await api.dio.get("api/leerlingen/${account.id}/foto", options: Options(responseType: ResponseType.bytes)));
    String image = base64Encode(img.data);
    account.profilePicture = image;
    account.save();
  }
}

class MagisterApi {
  Account account;
  Dio dio;
  Dio refreshDio;
  MagisterApi(Account account) {
    this.account = account;
    this.refreshDio = Dio(BaseOptions(
      baseUrl: "https://accounts.magister.net/connect/token",
      // contentType: Headers.formUrlEncodedContentType,
      responseType: ResponseType.json,
      headers: {
        'content-type': 'application/x-www-form-urlencoded; charset=utf-8',
        "Accept": "application/x-www-form-urlencoded",
      },
    ));
    this.refreshDio.interceptors.add(InterceptorsWrapper(
          onRequest: (options) {
            print("Refreshing token");
            this.dio.lock();
            options.data = "refresh_token=${account.refreshToken}&client_id=M6LOAPP&grant_type=refresh_token";
            options.headers["Content-Type"] = 'application/x-www-form-urlencoded; charset=utf-8';
            return options;
          },
          onResponse: (Response res) {
            account.saveTokens(res.data);
            account.magister.expiryAndTenant();
            this.dio.unlock();
            print("Refreshed token");
            return res;
          },
          onError: (e) {
            if (e.response?.data == '{"error":"invalid_grant"}') {
              if (e.request.headers["refresh_token"] != account.refreshToken) {
                print("$account zou uitgelogd zijn maar slim nieuw systeem werkt");
                //repeat
                return dio.request(e.request.path, options: e.request);
              }
              MagisterAuth().fullLogin({"username": account.username, "tenant": account.tenant}).then((tokenSet) {
                account.saveTokens(tokenSet);
                account.magister.expiryAndTenant();
                account.save();
              });
            }
            print("Error refreshing token");
            print(e.request.uri);
            print(e.request.data);
            print(e);
            print(e.response.data);
            return e;
          },
        ));
    this.dio = Dio(
      BaseOptions(baseUrl: "https://${account.tenant}/", headers: {"Authorization": "Bearer ${account.accessToken}"}),
    );
    this.dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options) async {
              if (account.accessToken == null) {
                throw ("Accestoken is null");
              }
              if (DateTime.now().millisecondsSinceEpoch > account.expiry) {
                print("Accestoken expired");
                await refreshDio.post("");
                return options;
              }
              options.baseUrl = "https://${account.tenant}/";
              options.headers["Authorization"] = "Bearer ${account.accessToken}";
              return options;
            },
            onError: (DioError e) {
              RequestOptions options = e.request;
              if (e.response?.data == "SecurityToken Expired") {
                if (options.headers["Authorization"] != "Bearer ${account.accessToken}") {
                  options.headers["Authorization"] = "Bearer ${account.accessToken}";
                  return dio.request(options.path, options: options);
                }
                print(e.response.data);
                return refreshDio.post("");
              }
              print("error");
              print(e.request.uri);
              print(e);
              print(e.response?.data);
              return e;
            },
          ),
        );
  }

  Future wait(List<Future> runList) {
    var values = Future.wait(runList);
    account.save();
    return values;
  }
}
