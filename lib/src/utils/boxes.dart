import 'package:argo/src/utils/hive/adapters.dart';
import 'package:hive/hive.dart';

Box userdata = Hive.box("userdata");
Box custom = Hive.box("custom");
Box<Account> accounts = Hive.box("accounts");
