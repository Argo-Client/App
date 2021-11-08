import 'package:argo/src/ui/components/ListTileDivider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:after_layout/after_layout.dart';

import 'package:argo/src/utils/hive/adapters.dart';
import 'package:argo/src/utils/bodyHeight.dart';
import 'package:argo/src/utils/handleError.dart';
import 'package:argo/src/utils/account.dart';

import 'package:argo/src/ui/components/Card.dart';
import 'package:argo/src/ui/components/AppPage.dart';
import 'package:argo/src/ui/components/Bijlage.dart';
import 'package:argo/src/ui/components/EmptyPage.dart';
import 'package:argo/src/ui/components/Refreshable.dart';

class Bronnen extends StatefulWidget {
  @override
  _Bronnen createState() => _Bronnen();
}

class _Bronnen extends State<Bronnen> with AfterLayoutMixin<Bronnen> {
  ValueNotifier<List<String>> breadcrumbs = ValueNotifier(["Bronnen"]);
  ValueNotifier<List<List<Bron>>> bronnenView = ValueNotifier([account().bronnen]);

  void afterFirstLayout(BuildContext context) => handleError(account().magister.bronnen.refresh, "Fout tijdens verversen van bronnen", context);

  Widget _buildBronnenPagina(List<List<Bron>> view) {
    List<Widget> bronnenPagina = [];

    for (Bron bron in view.last) {
      bronnenPagina.add(
        MaterialCard(
          child: BijlageItem(
            bron,
            download: bron.isFolder ? null : account().magister.bronnen.downloadFile,
            onTap: !bron.isFolder
                ? null
                : () async {
                    breadcrumbs.value = List.from(breadcrumbs.value)..add(bron.naam);
                    bronnenView.value = List.from(view)..add(bron.children);
                    if (bron.children == null) {
                      await handleError(
                        () async => await account().magister.bronnen.loadChildren(bron),
                        "Kon ${bron.naam} niet laden.",
                        context,
                        () {
                          bronnenView.value = view.where((list) => list != null).toList();
                          bronnenView.value = List.from(view)..add(bron.children);
                        },
                      );
                    }
                  },
          ),
        ),
      );
    }

    return ListView(
      children: divideListTiles(bronnenPagina),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (bronnenView.value.length > 1) bronnenView.value.removeLast();
        if (breadcrumbs.value.length > 1) breadcrumbs.value.removeLast();
        return Future.value(false);
      },
      child: AppPage(
        title: Text("Bronnen"),
        bottom: PreferredSize(
          child: Align(
            alignment: Alignment.centerLeft,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 10,
                bottom: 10,
                right: 10,
              ),
              reverse: true,
              scrollDirection: Axis.horizontal,
              child: ValueListenableBuilder(
                valueListenable: breadcrumbs,
                builder: (c, crumbs, _b) {
                  return Row(
                    children: [
                      for (int i = 0; i < crumbs.length; i++)
                        GestureDetector(
                          child: Row(
                            children: [
                              Text(
                                " ${crumbs[i]} ",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              if (crumbs.length != i + 1)
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 10,
                                ),
                            ],
                          ),
                          onTap: () {
                            breadcrumbs.value = breadcrumbs.value.take(i + 1).toList();
                            bronnenView.value = bronnenView.value.take(i + 1).toList();
                          },
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
          preferredSize: Size.fromHeight(25),
        ),
        body: Refreshable(
          type: "bronnen",
          onRefresh: account().magister.bronnen.refresh, // Ververst alleen "/" niet de bron waar je nu inzit.
          child: account().bronnen.isEmpty
              ? EmptyPage(
                  text: "Geen bronnen",
                  icon: Icons.folder_outlined,
                )
              : ValueListenableBuilder(
                  valueListenable: bronnenView,
                  builder: (c, view, _) {
                    if (view.last == null)
                      return Container(
                        height: bodyHeight(context),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    else if (view.last.isEmpty)
                      return EmptyPage(
                        text: "Deze map is leeg",
                        icon: Icons.folder_outlined,
                      );
                    else
                      return _buildBronnenPagina(view);
                  },
                ),
        ),
      ),
    );
  }
}
