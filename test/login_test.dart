import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:argo/src/utils/hive/adapters.dart';

// Deze tests hebben een refresh token nodig
// https://github.com/Netfloex/Argo-Token-Api

bool hasEnv = Platform.environment["TOKEN_API"] != null && Platform.environment["TOKEN_API_AUTH"] != null;
Dio tokenApi = Dio(
  BaseOptions(
    baseUrl: Platform.environment["TOKEN_API"],
    headers: {"Authorization": Platform.environment["TOKEN_API_AUTH"]},
  ),
);

void main() {
  if (!hasEnv) {
    throw "To run tests please provide TOKEN_API and TOKEN_API_AUTH environment variables";
  }
  String refreshToken;

  Account account;

  // Get a refresh token
  setUpAll(() async {
    await tokenApi.get("").then((value) {
      refreshToken = value.data;
    });
  });

  // Update the refresh token
  tearDownAll(() async {
    if (account?.refreshToken != null) {
      await tokenApi.post("", data: {"token": account.refreshToken});
    }
  });

  setUp(() {
    account = Account();
    account.refreshToken = refreshToken;
  });
  test('Kan een token refreshen', () async {
    await account.magister.api.refreshDio.post("");

    expect(account.accessToken, isInstanceOf<String>());
    expect(account.refreshToken, isInstanceOf<String>());
    expect(account.refreshToken != refreshToken, isTrue);
  });
}
