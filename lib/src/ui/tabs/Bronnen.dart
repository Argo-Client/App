import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:after_layout/after_layout.dart';

import 'package:argo/main.dart';
import 'package:argo/src/utils/hive/adapters.dart';

import 'package:argo/src/ui/components/Card.dart';
import 'package:argo/src/ui/components/Utils.dart';
import 'package:argo/src/ui/components/AppPage.dart';
import 'package:argo/src/ui/components/Bijlage.dart';
import 'package:argo/src/ui/components/EmptyPage.dart';

class Bronnen extends StatefulWidget {
  @override
  _Bronnen createState() => _Bronnen();
}

class _Bronnen extends State<Bronnen> with AfterLayoutMixin<Bronnen> {
  ValueNotifier<List<String>> breadcrumbs = ValueNotifier(["Bronnen"]);
  ValueNotifier<List<List<Bron>>> bronnenView = ValueNotifier([account.bronnen]);

  void afterFirstLayout(BuildContext context) => handleError(account.magister.bronnen.refresh, "Fout tijdens verversen van bronnen", context);

  Widget _buildBronnenPagina(List<List<Bron>> view) {
    List<Widget> bronnenPagina = [];

    for (Bron bron in view.last) {
      ValueNotifier<DownloadState> state = ValueNotifier(DownloadState.none);

      bronnenPagina.add(
        SeeCard(
          child: BijlageItem(
            bron,
            downloadState: state,
            border: view.last.last != bron
                ? Border(
                    bottom: greyBorderSide(),
                  )
                : null,
            onTap: () async {
              if (bron.isFolder) {
                breadcrumbs.value = List.from(breadcrumbs.value)..add(bron.naam);
                bronnenView.value = List.from(view)..add(bron.children);
                if (bron.children == null) {
                  await handleError(
                    () async => await account.magister.bronnen.loadChildren(bron),
                    "Kon ${bron.naam} niet laden.",
                    context,
                    () {
                      bronnenView.value = view.where((list) => list != null).toList();
                      bronnenView.value = List.from(view)..add(bron.children);
                    },
                  );
                }
              } else {
                account.magister.bronnen.downloadFile(bron, (count, total) {
                  if (count == total) {
                    state.value = DownloadState.done;
                  }
                });
              }
            },
          ),
        ),
      );
    }

    return ListView(
      children: bronnenPagina,
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
        body: RefreshIndicator(
          child: ValueListenableBuilder(
            valueListenable: updateNotifier,
            builder: (BuildContext context, _, _a) {
              if (account.bronnen.isEmpty) {
                return EmptyPage(
                  text: "Geen bronnen",
                  icon: Icons.folder_outlined,
                );
              }
              return ValueListenableBuilder(
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
              );
            },
          ),
          onRefresh: () async {
            Future Function() refresh = account.magister.bronnen.refresh;
            if (bronnenView.value.length > 1) {
              Bron bron = bronnenView.value.last.last;
              if (bron.isFolder) {
                refresh = () async => await account.magister.bronnen.loadChildren(bron);
              }
            }
            await handleError(refresh, "Kon bronnen niet verversen", context);
          },
        ),
      ),
    );
  }
}
