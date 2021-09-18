import "dart:io";

import "package:dio/dio.dart";
import "package:flutter_test/flutter_test.dart";
import "package:argo/src/utils/hive/adapters.dart";

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

  Account account = Account();

  // Get a refresh token
  setUpAll(() async {
    await tokenApi.get("").then((value) {
      refreshToken = value.data;
      account.refreshToken = refreshToken;
    });
  });

  group("Setup:", () {
    test("Token refreshen", () async {
      expect(account.refreshToken, isNotNull);

      await account.magister.api.refreshToken();

      expect(account.accessToken, isInstanceOf<String>());
      expect(account.refreshToken, isInstanceOf<String>());
      expect(account.refreshToken != refreshToken, isTrue);

      await tokenApi.post("", data: {"token": account.refreshToken});
    });

    test("Tenant ophalen", () async {
      expect(account.tenant, isNull);
      await account.magister.profileInfo.getTenant();

      expect(account.tenant, isInstanceOf<String>());
    });

    test("Account id ophalen", () async {
      expect(account.id, 0);
      await account.magister.profileInfo.profileInfo();

      expect(account.privileges, isInstanceOf<List<Privilege>>());
      expect(account.id, isNot(0));
      expect(account.id, isInstanceOf<int>());
    });
  });

  group("Refresh Functions:", () {
    test("Agenda", () async {
      if (!account.has("Afspraken", "Read")) {
        return print("Skipped Agenda");
      }

      expect(account.lessons, {});

      await account.magister.agenda.refresh();

      expect(account.lessons, isInstanceOf<Map<String, List<List<Les>>>>());
    });

    test("Afwezigheid", () async {
      if (!account.has("Absenties", "Read")) {
        return print("Skipped Afwezigheid");
      }

      expect(account.afwezigheid, isNull);

      await account.magister.afwezigheid.refresh();

      expect(account.afwezigheid, isInstanceOf<List<Absentie>>());
    });

    test("Berichten", () async {
      if (!account.has("Berichten", "Read")) {
        return print("Skipped Berichten");
      }

      expect(account.berichten, isNull);

      await account.magister.berichten.refresh();

      expect(account.berichten, isInstanceOf<List<Bericht>>());
    });

    test("Bronnen", () async {
      if (!account.has("Bronnen", "Read")) {
        return print("Skipped Bronnen");
      }

      expect(account.bronnen, isNull);

      await account.magister.bronnen.refresh();

      expect(account.bronnen, isInstanceOf<List<Bron>>());
    });

    test("Cijfers", () async {
      if (!account.has("Cijfers", "Read")) {
        return print("Skipped Cijfers");
      }

      expect(account.cijfers, isNull);

      await account.magister.cijfers.refresh();

      expect(account.cijfers, isInstanceOf<List<CijferJaar>>());
    });

    test("Leermiddelen", () async {
      if (!account.has("DigitaalLesmateriaal", "Read")) {
        return print("Skipped Leermiddelen");
      }

      expect(account.leermiddelen, isNull);

      await account.magister.leermiddelen.refresh();

      expect(account.leermiddelen, isInstanceOf<List<Leermiddel>>());
    });

    test("Studiewijzers", () async {
      if (!account.has("Studiewijzers", "Read")) {
        return print("Skipped Studiewijzers");
      }

      expect(account.studiewijzers, isNull);

      await account.magister.studiewijzers.refresh();

      expect(account.studiewijzers, isInstanceOf<List<Wijzer>>());
    });

    test("Profiel Info", () async {
      await account.magister.profileInfo.refresh();

      expect(account.address, isInstanceOf<String>());
      expect(account.id, isInstanceOf<int>());
      expect(account.officialFullName, isInstanceOf<String>());
      expect(account.fullName, isInstanceOf<String>());
      expect(account.name, isInstanceOf<String>());
      expect(account.initials, isInstanceOf<String>());
      expect(account.birthdate, isInstanceOf<String>());
    });

    test("Profiel Foto", () async {
      expect(account.profilePicture, isNull);

      await account.magister.downloadProfilePicture();

      expect(account.profilePicture, isInstanceOf<String>());
    });
  });
}
