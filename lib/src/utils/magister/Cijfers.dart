import 'magister.dart';
import 'package:Magistex/src/utils/hiveObjects.dart';

class Cijfers extends MagisterApi {
  Account account;
  Cijfers(this.account) : super(account);
  Future refresh() async {
    await runList([getCijfers()]);
    account.save();
    return;
  }

  Future getCijfers() async {
    var parsed = await getFromMagister("personen/${account.id}/cijfers/laatste?top=50&skip=0");
    print(parsed);
  }
}
