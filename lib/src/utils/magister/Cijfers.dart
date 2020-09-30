import 'magister.dart';

class Cijfers extends MagisterApi {
  MagisterApi api;
  Cijfers(this.api) : super(api.account);
  Future refresh() async {
    return await api.wait([getCijfers()]);
  }

  Future getCijfers() async {
    api.dio.get("api/personen/${account.id}/cijfers/laatste?top=50&skip=0").then(print);
  }
}
