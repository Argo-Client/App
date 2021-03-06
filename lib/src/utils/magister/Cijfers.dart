import 'magister.dart';
import 'package:argo/src/utils/hive/adapters.dart';

class Cijfers extends MagisterApi {
  MagisterApi api;
  Cijfers(this.api) : super(api.account);
  Future refresh() async {
    await cijferJaren();
    await api.wait([recentCijfers(), cijferPerioden(), cijfers()]);
  }

  Future recentCijfers() async {
    List recent = (await api.dio.get("api/personen/${account.id}/cijfers/laatste?top=50&skip=0")).data["items"];
    account.recenteCijfers = recent.map((cijf) => Cijfer(cijf)).toList();
  }

  Future cijferJaren() async {
    List perioden = (await api.dio.get("api/leerlingen/${account.id}/aanmeldingen?begin=1970-01-01")).data["items"];
    account.cijfers = perioden.map((per) => CijferJaar(per)).toList();
  }

  Future cijferPerioden() async {
    for (var i = 0; i < account.cijfers.length; i++) {
      List perioden = (await api.dio.get("/api/personen/${account.id}/aanmeldingen/${account.cijfers[i].id}/cijfers/cijferperiodenvooraanmelding")).data["Items"];
      account.cijfers[i].perioden = perioden.map((per) => Periode(per)).toList();
      account.cijfers[i].perioden.sort((a, b) => a.id.compareTo(b.id));
    }
  }

  Future cijfers() async {
    for (var i = 0; i < account.cijfers.length; i++) {
      List cijfers = (await api.dio.get("api/personen/${account.id}/aanmeldingen/${account.cijfers[i].id}/cijfers/cijferoverzichtvooraanmelding?actievePerioden=true&alleenBerekendeKolommen=false&alleenPTAKolommen=false&peildatum=${account.cijfers[i].eind}")).data["Items"];
      account.cijfers[i].cijfers = cijfers.map((cijfer) => Cijfer(cijfer)).where((cijfer) => cijfer.id != 0).toList();
      account.cijfers[i].cijfers.sort((a, b) => a.ingevoerd.millisecondsSinceEpoch.compareTo(b.ingevoerd.millisecondsSinceEpoch));
      account.cijfers[i].cijfers = account.cijfers[i].cijfers.reversed.toList();
    }
  }

  Future getExtraInfo(Cijfer cijf, CijferJaar jaar) async {
    if (cijf.title != null) return cijf;
    Map cijfer = (await api.dio.get("api/personen/${account.id}/aanmeldingen/${jaar.id}/cijfers/extracijferkolominfo/${cijf.kolomId}")).data;
    cijf.title = cijfer["WerkInformatieOmschrijving"] ?? cijfer["KolomOmschrijving"];
    cijf.weging = cijfer["Weging"];
    return cijf;
  }
}
