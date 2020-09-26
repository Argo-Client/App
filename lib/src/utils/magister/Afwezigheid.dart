import 'package:intl/intl.dart';
import 'magister.dart';
import 'dart:convert';
import 'package:Argo/src/utils/hiveObjects.dart';
import 'Agenda.dart';

class Afwezigheid extends MagisterApi {
  Account account;
  DateFormat formatDate = DateFormat("yyyy-MM-dd");
  DateFormat formatDatum = DateFormat("EEEE dd MMMM");
  Afwezigheid(this.account) : super(account);
  Future refresh() async {
    return await runList([getAfwezigheid()]);
  }

  Future getAfwezigheid() async {
    var res = await getFromMagister("personen/${account.id}/absentieperioden");
    Map current = json.decode(res.body)["Items"].first;
    String start = formatDate.format(DateTime.parse(current["Start"]));
    String eind = formatDate.format(DateTime.parse(current["Eind"]));
    getFromMagister("personen/${account.id}/absenties?van=$start&tot=$eind").then((res) {
      account.afwezigheid = json
          .decode(res.body)["Items"]
          .map((afw) {
            return {
              "dag": formatDatum.format(DateTime.parse(afw["Afspraak"]["Einde"])),
              "type": afw["Omschrijving"],
              "les": Agenda(account).lesFrom(afw["Afspraak"]),
              "geoorloofd": afw["Geoorloofd"],
            };
          })
          .toList()
          .reversed
          .toList();
    });
  }
}
