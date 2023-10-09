import 'package:dio/dio.dart';

import 'magister.dart';
import 'package:argo/src/utils/hive/adapters.dart';

import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io' as io;

class Bronnen extends MagisterApi {
  MagisterApi api;
  Bronnen(this.api) : super(api.account);
  Future refresh() async {
    await api.wait([bronmappen()]);
  }

  Future bronmappen() async {
    account.bronnen = await loadBron();
    if (account.isInBox) account.save();
  }

  Future loadChildren(Bron bron) async {
    bron.children = await loadBron(bron.id);
    if (account.isInBox) account.save();
  }

  Future loadBron([int id]) async {
    List bronmappen = (await api.dio.get("api/personen/${account.id}/bronnen?parentId=${id ?? ''}")).data["Items"];
    return bronmappen.map((bron) => Bron(bron)).toList();
  }

  Future downloadFile(Bron bron, Function(int, int) onReceiveProgress) async {
    String savePath = (await getTemporaryDirectory()).path;
    savePath = "$savePath/${bron.naam}";
    if (io.File(savePath).existsSync()) {
      OpenFile.open(savePath);
      onReceiveProgress(bron.size, 0);
      return;
    }
    await Dio().download(
      (await api.dio.get(bron.downloadUrl + "?redirect_type=body")).data["location"],
      savePath,
      onReceiveProgress: onReceiveProgress,
    );
    OpenFile.open(savePath);
  }
}
