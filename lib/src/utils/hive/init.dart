import 'package:argo/main.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:argo/src/utils/hive/adapters.dart';

Future<void> initHive() async {
  await Hive.initFlutter();
  try {
    Hive.registerAdapter(AccountAdapter());
    Hive.registerAdapter(ColorAdapter());
    Hive.registerAdapter(MaterialColorAdapter());
    // Hive.registerAdapter(IconAdapter());
    Hive.registerAdapter(LesAdapter());
    Hive.registerAdapter(CijferJaarAdapter());
    Hive.registerAdapter(CijferAdapter());
    Hive.registerAdapter(VakAdapter());
    Hive.registerAdapter(PeriodeAdapter());
    Hive.registerAdapter(BerichtAdapter());
    Hive.registerAdapter(AbsentieAdapter());
    Hive.registerAdapter(BronAdapter());
    Hive.registerAdapter(WijzerAdapter());
    Hive.registerAdapter(LeermiddelAdapter());
    Hive.registerAdapter(ContactAdapter());
    Hive.registerAdapter(PrivilegeAdapter());
  } catch (_) {}

  try {
    await Future.wait([
      Hive.openBox<Account>("accounts"),
      Hive.openBox("userdata"),
      Hive.openBox("custom"),
    ]);
  } catch (e) {
    await Hive.deleteBoxFromDisk("accounts");
    print(e);

    return main();
  }
}
