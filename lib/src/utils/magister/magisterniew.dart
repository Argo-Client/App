import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:Argo/src/utils/hiveObjects.dart';

class MagisterApi {
  Dio dio;
  Dio refreshDio;
  Account account;
  MagisterApi(Account account) {
    this.account = account;
    this.refreshDio = Dio(BaseOptions(
      baseUrl: "https://accounts.magister.net",
    ));
    this.refreshDio.interceptors.add(InterceptorsWrapper(
          onRequest: (options) {
            print("Refreshing token");
            options.headers['Content-type'] = 'application/x-www-form-urlencoded';
            options.data = FormData.fromMap({
              "refresh_token": account.refreshToken,
              "client_id": "M6LOAPP",
              "grant_type": "refresh_token",
            });
            return options;
          },
          onResponse: (Response res) {
            var parsed = jsonDecode(res.data);
            account.saveTokens(parsed);
            // Magister(account).expiryAndTenant();
            print("Refreshed token");
            return res;
          },
          onError: (e) {
            if (e.response.data == '{"error":"invalid_grant"}') {
              if (e.request.headers["refresh_token"] != account.refreshToken) {
                print("$account zou uitgelogd zijn maar slim nieuw systeem werkt");
                //repeat
                return dio.request(e.request.path, options: e.request);
              }
              print("$account is uitgelogd");
            }
            print("Error refreshing token");
            print(e.request.uri);
            print(e.request.data);
            print(e.response.data);
            return e;
          },
        ));
    this.dio = Dio(
      BaseOptions(baseUrl: "https://${account.tenant}"),
    );
    this.dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options) async {
              if (DateTime.now().millisecondsSinceEpoch < account.expiry) {
                print("Accestoken expired");
                await refreshDio.post("/connect/token");
                return options;
              }
              options.headers["Authorization"] = "Bearer ${account.accessToken}";
              return options;
            },
            onResponse: (Response res) {
              print("Respinse interceptde");
              print(res);
              return res;
            },
            onError: (DioError e) {
              RequestOptions options = e.request;
              if (e.response?.data == "SecurityToken Expired") {
                if (options.headers["Authorization"] != "Bearer ${account.accessToken}") {
                  options.headers["Authorization"] = "Bearer ${account.accessToken}";
                  return dio.request(options.path, options: options);
                }
                print(e.response.data);
                // Refresh token
                return refreshDio.post("/connect/token");
              }
              print("error");
              print(e);
              print(e.response.data);
              return e;
            },
          ),
        );
  }
}
