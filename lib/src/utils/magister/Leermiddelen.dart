import 'magister.dart';
import 'package:Argo/src/utils/hive/adapters.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

class Leermiddelen extends MagisterApi {
  MagisterApi api;
  Leermiddelen(this.api) : super(api.account);
  Future refresh() async {
    await api.wait([getLeermiddelen()]);
  }

  Future getLeermiddelen() async {
    List leermiddelen = (await api.dio.get("api/personen/${account.id}/lesmateriaal?DigitaalLicentieFilter=0")).data["Items"];
    account.leermiddelen = leermiddelen.map((e) => Leermiddel(e)).toList();
  }

  void launch(Leermiddel leermiddel) async {
    String url = (await api.dio.get("/api/personen/${account.id}/digitaallesmateriaal/Ean/${leermiddel.ean}?redirect_type=body")).data["location"];
    launcher.launch(url);
  }
}
