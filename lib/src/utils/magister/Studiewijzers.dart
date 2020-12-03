import 'magister.dart';
import 'package:Argo/src/utils/hive/adapters.dart';

class Studiewijzers extends MagisterApi {
  MagisterApi api;
  Studiewijzers(this.api) : super(api.account);
  Future refresh() async {
    await api.wait([studiewijzer()]);
  }

  Future studiewijzer() async {
    account.studiewijzers = (await loadWijzer())["Items"]
        .map(
          (wijs) => Wijzer(wijs),
        )
        .toList()
        .cast<Wijzer>();
  }

  Future<Map> loadWijzer([id]) async {
    return (await api.dio.get("api/leerlingen/${account.id}/studiewijzers/${id ?? ''}")).data;
  }

  Future loadChildren(Wijzer wijs) async {
    Map wijzer = (await loadWijzer(wijs.id));
    wijs.children = wijzer["Onderdelen"]["Items"]
        .map(
          (wijs) => Wijzer(wijs),
        )
        .toList()
        .cast<Wijzer>() as List<Wijzer>;
    if (account.isInBox) account.save();
  }

  Future loadTab(Wijzer wijs) async {
    Wijzer wijzer = Wijzer((await api.dio.get(wijs.tabUrl + "?gebruikMappenStructuur=true")).data);
    wijs.omschrijving = wijzer.omschrijving;
    wijs.bronnen = wijzer.bronnen;
    if (account.isInBox) account.save();
  }
}
