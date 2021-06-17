import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:argo/src/utils/hive/adapters.dart';
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
    this.dio = Dio(
      BaseOptions(baseUrl: "https://${account.tenant}/"),
    );
    this.refreshDio = Dio(
      BaseOptions(
        baseUrl: "https://accounts.magister.net/connect/token",
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    this.refreshDio.interceptors.add(InterceptorsWrapper(
          onRequest: (options, handler) {
            print("Refreshing token");
            this.dio.lock();
            options.data = "refresh_token=${account.refreshToken}&client_id=M6LOAPP&grant_type=refresh_token";
            handler.next(options);
          },
          onResponse: (res, handler) {
            account.saveTokens(res.data);
            this.dio.unlock();
            print("Refreshed token");
            handler.next(res);
          },
          onError: (e, handler) async {
            print("Error refreshing token");
            print(e);
            if (e.response?.data != null && e.response?.data["error"] == "invalid_grant") {
              throw "$account is uitgelogd, verwijder je account en log opnieuw in. (Spijt me zeer hier is nog geen automatische support voor)";
              // MagisterLogin().launch(main.appState.context, (tokenSet, _) {
              //   account.saveTokens(tokenSet);
              //   if (account.isInBox) account.save();
              // }, title: "Account is uitgelogd");
              // return dio.request(e.requestOptions.path, options: e.requestOptions as Options);
            }
            handler.next(e);
          },
        ));
    this.dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              if (account.accessToken == null) {
                throw ("Accestoken is null");
              }
              options.baseUrl = "https://${account.tenant}/";

              options.headers["Authorization"] = "Bearer ${account.accessToken}";
              if (DateTime.now().millisecondsSinceEpoch > account.expiry) {
                print("Accestoken expired");
                refreshDio.post("")
                  ..onError((e, stack) {
                    handler.reject(e);
                    return;
                  });
              }
              handler.next(options);
            },
            onError: (e, handler) async {
              RequestOptions options = e.requestOptions;
              if (e.response?.data == "SecurityToken Expired") {
                if (options.headers["Authorization"] != "Bearer ${account.accessToken}") {
                  options.headers["Authorization"] = "Bearer ${account.accessToken}";

                  dio.fetch(options).then(handler.resolve);
                  return;
                }

                print(e.response.data);
                this.dio.lock();
                refreshDio.post("").whenComplete(() {
                  this.dio.unlock();
                }).then((value) {
                  dio.fetch(options).then(
                    (value) => handler.resolve(value),
                    onError: (e) {
                      handler.reject(e);
                    },
                  );
                }).onError((e, stack) {
                  handler.reject(e);
                });
                return;
              }

              return handler.next(translateHttpError(e));
            },
          ),
        );
    // LogInterceptor clean = LogInterceptor(requestHeader: false, responseHeader: false, request: false);
    // this.refreshDio.interceptors.add(clean);
    // this.dio.interceptors.add(clean);
  }

  Future wait(List<Future> runList) {
    var values = Future.wait(runList);
    if (account.isInBox) account.save();
    return values;
  }

  DioError translateHttpError(DioError e) {
    if (e.error.runtimeType == SocketException) {
      this.dio.clear();
      this.refreshDio.clear();
      return DioError(error: "Geen Internet", requestOptions: e.requestOptions);
    }
    return e;
  }
}
