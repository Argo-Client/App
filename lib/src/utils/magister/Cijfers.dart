import 'magister.dart';
import 'package:Magistex/src/utils/hiveObjects.dart';

class Cijfers extends MagisterApi {
  Account account;
  Cijfers(this.account) : super(account);
  Future refresh() async {
    return await runList([getCijfers()]);
  }

  Future getCijfers() async {
    getFromMagister("personen/${account.id}/cijfers/laatste?top=50&skip=0").then(print);
  }
}
