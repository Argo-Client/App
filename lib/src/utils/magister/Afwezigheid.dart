import 'package:intl/intl.dart';
import 'magister.dart';
import 'package:argo/src/utils/hive/adapters.dart';

class Afwezigheid extends MagisterApi {
  MagisterApi api;
  Afwezigheid(this.api) : super(api.account);
  DateFormat formatDate = DateFormat("yyyy-MM-dd");
  DateFormat formatDatum = DateFormat("EEEE d MMMM");
  Future refresh() async {
    return await api.wait([getAfwezigheid()]);
  }

  Future getAfwezigheid() async {
    Map current = (await api.dio.get("api/personen/${account.id}/absentieperioden")).data["Items"].first;
    String start = formatDate.format(DateTime.parse(current["Start"]));
    String eind = formatDate.format(DateTime.parse(current["Eind"]));
    List body = (await api.dio.get("api/personen/${account.id}/absenties?van=$start&tot=$eind")).data["Items"];
    account.afwezigheid = body.map((afw) => Absentie(afw)).toList().reversed.toList();
  }
}
