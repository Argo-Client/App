import 'magister.dart';
import 'package:argo/src/utils/hive/adapters.dart';
import "package:intl/intl.dart";

DateFormat dateFormatter = DateFormat('yyyy-MM-dd');

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

  Future<Map> loadWijzer() async {
    var wijzers = await Future.wait([api.dio.get("api/leerlingen/${account.id}/studiewijzers/?peildatum=${dateFormatter.format(DateTime.now())}"), api.dio.get("api/leerlingen/${account.id}/projecten/?peildatum=${dateFormatter.format(DateTime.now())}")]);
    return {...wijzers.first.data}..["Items"].addAll(wijzers.last.data["Items"]);
  }

  Future loadChildren(Wijzer wijs) async {
    Map wijzer = (await api.dio.get(wijs.tabUrl)).data;
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
