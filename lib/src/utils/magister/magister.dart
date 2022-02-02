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
    var img = (await api.dio.get(
      "api/leerlingen/${account.id}/foto",
      options: Options(
        responseType: ResponseType.bytes,
        validateStatus: (status) => [200, 404].contains(status),
      ),
    ));

    String image;
    if (img.statusCode == 200) {
      image = base64Encode(img.data);
    }

    account.profilePicture = image;
    if (account.isInBox) account.save();
  }
}

class MagisterApi {
  Account account;
  Dio dio;
  Dio refreshDio;

  Future<void> refreshToken() async {
    print("Refreshing token");
    this.dio.lock();
    await this
        .refreshDio
        .post<Map>(
          "https://accounts.magister.net/connect/token",
          data: "refresh_token=${account.refreshToken}&client_id=M6LOAPP&grant_type=refresh_token",
        )
        .then((res) async {
      await account.saveTokens(res.data);
    }).catchError((err) {
      print("Error while refreshing token");
      throw err;
    }).whenComplete(
      () => this.dio.unlock(),
    );
  }

  MagisterApi(Account account) {
    this.account = account;
    this.dio = Dio(
      BaseOptions(baseUrl: "https://${account.tenant}/"),
    );
    this.refreshDio = Dio(
      BaseOptions(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    this.refreshDio.interceptors.add(
      InterceptorsWrapper(
        onError: (e, handler) async {
          if (e.response?.data != null && e.response?.data["error"] == "invalid_grant") {
            return handler.reject(DioError(
              requestOptions: e.requestOptions,
              error: "Dit account is uitgelogd, verwijder je account en log opnieuw in. (Spijt me zeer hier is nog geen automatische support voor)",
              response: e.response,
            ));
            // MagisterLogin().launch(main.appState.context, (tokenSet, _) {
            //   account.saveTokens(tokenSet);
            //   if (account.isInBox) account.save();
            // }, title: "Account is uitgelogd");
            // return dio.request(e.requestOptions.path, options: e.requestOptions as Options);
          }
          handler.next(e);
        },
      ),
    );
    this.dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              if (account.accessToken == null || DateTime.now().millisecondsSinceEpoch > account.expiry) {
                print("Accestoken expired");
                await this.refreshToken().onError((e, stack) {
                  handler.reject(e);
                  return;
                });
              }

              options.baseUrl = "https://${account.tenant}/";

              options.headers["Authorization"] = "Bearer ${account.accessToken}";

              return handler.next(options);
            },
            onError: (e, handler) async {
              var options = e.requestOptions;

              Future<void> retry() => dio.fetch(options).then(
                    (r) => handler.resolve(r),
                    onError: (e) => handler.reject(e),
                  );

              if (e.response?.data == "SecurityToken Expired") {
                print("Request failed, token is invalid");

                if (options.headers["Authorization"] != "Bearer ${account.accessToken}") {
                  options.headers["Authorization"] = "Bearer ${account.accessToken}";

                  return await retry();
                }

                return await this.refreshToken().then((_) => retry()).onError(
                      (e, stack) => handler.reject(e),
                    );
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
      return DioError(error: "Geen Internet", requestOptions: e.requestOptions);
    }
    return e;
  }
}
