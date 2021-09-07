import 'package:argo/src/utils/boxes.dart';
import 'package:argo/src/utils/hive/adapters.dart';

Account account() {
  if (accounts.isEmpty) {
    return null;
  }

  Account account = accounts.get(userdata.get("accountIndex"));

  return account;
}
