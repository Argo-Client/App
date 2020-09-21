import 'package:intl/intl.dart';
import 'magister.dart';
import 'package:Magistex/src/utils/hiveObjects.dart';

class Berichten extends MagisterApi {
  Account account;
  DateFormat formatDate = DateFormat("yyyy-MM-dd");
  DateFormat formatDatum = DateFormat("EEEE dd MMMM");
  Berichten(this.account) : super(account);
  Future refresh() async {
    await runList([getBerichten()]);
    account.save();
    return;
  }

  Map<String, dynamic> parseBericht(ber) {
    return {
      "dag": formatDatum.format(DateTime.parse(ber["verzondenOp"])),
      "id": ber["id"],
      "prioriteit": ber["heeftPrioriteit"],
      "bijlagen": ber["heeftBijlagen"],
      "onderwerp": ber["onderwerp"],
      "afzender": ber["afzender"]["naam"],
    };
  }

  Future getBerichten() async {
    var parsed = (await getFromMagister("berichten/postvakin/berichten?top=30"))["items"];
    account.berichten = parsed.map((ber) => parseBericht(ber)).toList();
  }

  Future<Map> getBerichtFromId(id) async {
    var parsed = (await getFromMagister("berichten/berichten/$id"));
    Map ber = {
      "inhoud": parsed["inhoud"],
      "ontvangers": parsed["ontvangers"].take(10).map((ont) => ont["weergavenaam"]).join(" "),
    };
    ber.addAll(parseBericht(parsed));
    return ber;
  }
}
