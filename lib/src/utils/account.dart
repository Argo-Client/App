import 'package:argo/src/utils/boxes.dart';
import 'package:argo/src/utils/hive/adapters.dart';

int firstAccIndex = accounts.toMap().entries.first.key;
int accountIndex = userdata.get("alwaysPrimary") ? firstAccIndex : userdata.get("accountIndex");
Account account = accounts.get(userdata.get("accountIndex")) ?? accounts.get(firstAccIndex);
