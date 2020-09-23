import 'package:intl/intl.dart';
import 'magister.dart';
import 'package:Magistex/src/utils/hiveObjects.dart';
import 'Agenda.dart';

class Afwezigheid extends MagisterApi {
  Account account;
  DateFormat formatDate = DateFormat("yyyy-MM-dd");
  DateFormat formatDatum = DateFormat("EEEE dd MMMM");
  Afwezigheid(this.account) : super(account);
  Future refresh() async {
    await runList([getAfwezigheid()]);
    account.save();
    return;
  }

  Future getAfwezigheid() async {
    var perioden = (await getFromMagister("personen/${account.id}/absentieperioden"))["Items"];
    var current = perioden.first;
    String start = formatDate.format(DateTime.parse(current["Start"]));
    String eind = formatDate.format(DateTime.parse(current["Eind"]));
    var parsed = (await getFromMagister("personen/${account.id}/absenties?van=$start&tot=$eind"))["Items"];
    account.afwezigheid = parsed
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
  }
}
