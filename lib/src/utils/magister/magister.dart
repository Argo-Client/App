import 'dart:convert';
import 'dart:io';
import 'package:argo/main.dart' as main;
import 'package:dio/dio.dart';
import 'package:argo/src/utils/hive/adapters.dart';
import 'package:argo/src/utils/login.dart';
import 'ProfileInfo.dart';
import 'Agenda.dart';
import 'Cijfers.dart';
import 'Afwezigheid.dart';
import 'Berichten.dart';
import 'Bronnen.dart';
import 'Studiewijzers.dart';
import 'Leermiddelen.dart';

class Magister {
  Account account;
  ProfileInfo profileInfo;
  Agenda agenda;
  Cijfers cijfers;
  MagisterApi api;
  Afwezigheid afwezigheid;
  Berichten berichten;
  Bronnen bronnen;
  Studiewijzers studiewijzers;
  Leermiddelen leermiddelen;
  Magister(Account acc) {
    this.account = acc;
    api = MagisterApi(acc);
    profileInfo = ProfileInfo(MagisterApi(acc));
    agenda = Agenda(MagisterApi(acc));
    cijfers = Cijfers(MagisterApi(acc));
    afwezigheid = Afwezigheid(MagisterApi(acc));
    berichten = Berichten(MagisterApi(acc));
    bronnen = Bronnen(MagisterApi(acc));
    studiewijzers = Studiewijzers(MagisterApi(acc));
    leermiddelen = Leermiddelen(MagisterApi(acc));
  }

  Future downloadProfilePicture() async {
    var img = (await api.dio.get("api/leerlingen/${account.id}/foto", options: Options(responseType: ResponseType.bytes)));
    String image = base64Encode(img.data);
    account.profilePicture = image;
    if (account.isInBox) account.save();
  }
}

class MagisterApi {
  Account account;
  Dio dio;
  Dio refreshDio;
  MagisterApi(Account account) {
    this.account = account;
    this.dio = Dio(BaseOptions(baseUrl: "https://${account.tenant}/"));
    this.refreshDio = Dio(BaseOptions(
      baseUrl: "https://accounts.magister.net/connect/token",
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
            this.dio.unlock();
            print("Refreshed token");
            return res;
          },
          onError: (e) async {
            print("Error refreshing token");
            this.dio.unlock();
            print(e);
            if (e.response?.data != null && e.response?.data["error"] == "invalid_grant") {
              print("$account is uitgelogd");
              MagisterLogin().launch(main.appState.context, (tokenSet, _) {
                account.saveTokens(tokenSet);
                if (account.isInBox) account.save();
              }, title: "Account is uitgelogd");
              return dio.request(e.request.path, options: e.request);
            }
            return e;
          },
        ));
    this.dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options) async {
              if (account.accessToken == null) {
                throw ("Accestoken is null");
              }
              options.baseUrl = "https://${account.tenant}/";
              options.headers["Authorization"] = "Bearer ${account.accessToken}";
              if (DateTime.now().millisecondsSinceEpoch > account.expiry) {
                print("Accestoken expired");
                return refreshDio.post("").then((value) {
                  return options;
                });
              }
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

              if (e.error.runtimeType == SocketException) {
                this.dio.clear();
                this.refreshDio.clear();
                return "Geen Internet";
              }
              return e;
            },
          ),
        );

    // this.refreshDio.interceptors.add(LogInterceptor());
    // this.dio.interceptors.add(LogInterceptor());
  }

  Future wait(List<Future> runList) {
    var values = Future.wait(runList);
    if (account.isInBox) account.save();
    return values;
  }
}
