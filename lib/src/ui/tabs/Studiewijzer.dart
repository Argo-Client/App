import 'package:flutter/material.dart';

import 'package:after_layout/after_layout.dart';
import 'package:futuristic/futuristic.dart';

import 'package:Argo/main.dart';
import 'package:Argo/src/layout.dart';
import 'package:Argo/src/utils/hive/adapters.dart';
import 'package:Argo/src/ui/CustomWidgets.dart';

class Studiewijzers extends StatefulWidget {
  @override
  _Studiewijzers createState() => _Studiewijzers();
}

class _Studiewijzers extends State<Studiewijzers> with AfterLayoutMixin<Studiewijzers> {
  void afterFirstLayout(BuildContext context) => handleError(account.magister.studiewijzers.refresh, "Fout tijdens verversen van studiewijzers", context);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.menu,
          ),
          onPressed: () {
            DrawerStates.layoutKey.currentState.openDrawer();
          },
        ),
        title: Text(
          "Studiewijzers",
        ),
      ),
      body: RefreshIndicator(
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: ValueListenableBuilder(
            valueListenable: updateNotifier,
            builder: (BuildContext context, _, _a) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Padding(
                  //   padding: EdgeInsets.only(
                  //     top: 10,
                  //     left: 10,
                  //   ),
                  //   child:
                  //   ),
                  // ),
                  for (Wijzer wijs in account.studiewijzers)
                    SeeCard(
                      border: account.studiewijzers.length - 1 == account.studiewijzers.indexOf(wijs)
                          ? null
                          : Border(
                              bottom: greyBorderSide(),
                            ),
                      child: ListTile(
                        title: Text(wijs.naam),
                        onTap: () async {
                          setState(
                            () {},
                          );
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => StudiewijzerPagina(wijs),
                            ),
                          );
                          // await handleError(
                          //   () async => await account.magister.studiewijzers.loadChildren(wijs),
                          //   "Kon ${wijs.naam} niet laden",
                          //   context,
                          //   () {
                          //     setState(
                          //       () {},
                          //     );
                          //   },
                          // );
                          // await handleError(() async => await account.magister.bronnen.loadChildren(bron), "Kon ${bron.naam} niet laden.", context, () {
                          // });
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        onRefresh: () async {
          await handleError(account.magister.studiewijzers.refresh, "Kon studiewijzer niet verversen", context);
        },
      ),
    );
  }
}

class StudiewijzerPagina extends StatefulWidget {
  final Wijzer wijs;
  StudiewijzerPagina(this.wijs);
  @override
  _StudiewijzerPagina createState() => _StudiewijzerPagina(wijs);
}

class _StudiewijzerPagina extends State<StudiewijzerPagina> {
  Wijzer wijs;
  _StudiewijzerPagina(this.wijs);

  ValueNotifier<Wijzer> selected = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: AppBar().preferredSize,
        child: ValueListenableBuilder(
          valueListenable: selected,
          builder: (context, _, _a) {
            return AppBar(
              leading: selected.value != null
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        selected.value = null;
                      },
                    )
                  // : AnimatedIcon(icon: AnimatedIcons.),
                  : null,
              title: selected.value != null
                  ? Text(selected.value.naam)
                  : Text(
                      wijs.naam,
                    ),
              actions: [
                if (selected.value != null)
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.push_pin),
                  ),
              ],
            );
          },
        ),
      ),
      body: Futuristic(
        autoStart: true,
        futureBuilder: wijs.children != null ? () async {} : () async => await account.magister.studiewijzers.loadChildren(wijs),
        busyBuilder: (BuildContext context) => Center(
          child: CircularProgressIndicator(),
        ),
        errorBuilder: (BuildContext context, dynamic error, retry) {
          return RefreshIndicator(
            onRefresh: () async => retry(),
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Container(
                height: bodyHeight(context),
                child: Column(
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: 25,
                            ),
                            child: Icon(
                              Icons.wifi_off_outlined,
                              size: 150,
                              color: Colors.grey[400],
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 2,
                            child: Text(
                              "Fout tijdens het laden van studiewijzer: \n\n" + error.error,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 17.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
              ),
            ),
          );
        },
        dataBuilder: (BuildContext context, _) {
          return SingleChildScrollView(
            child: Column(
              children: [
                for (Wijzer wijstab in wijs.children)
                  ValueListenableBuilder(
                    valueListenable: selected,
                    builder: (context, _, _a) {
                      return GestureDetector(
                        child: SeeCard(
                          border: wijs.children.length - 1 == wijs.children.indexOf(wijstab)
                              ? null
                              : Border(
                                  bottom: greyBorderSide(),
                                ),
                          child: ListTile(
                            title: Text(
                              wijstab.naam,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onLongPress: () {
                              selected.value = wijstab;
                            },
                            trailing: selected?.value?.id == wijstab.id ? Icon(Icons.check) : null,
                            onTap: () {
                              if (selected.value != null) {
                                selected.value = null;
                                return;
                              }

                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => StudiewijzerTab(wijstab),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  )
              ],
            ),
          );
        },
      ),
    );
  }
}

class StudiewijzerTab extends StatefulWidget {
  final Wijzer wijstab;
  StudiewijzerTab(this.wijstab);
  @override
  _StudiewijzerTab createState() => _StudiewijzerTab(wijstab);
}

class _StudiewijzerTab extends State<StudiewijzerTab> {
  final Wijzer wijstab;
  Bron currentlyDownloading;

  _StudiewijzerTab(this.wijstab);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Tooltip(
          child: Text(wijstab.naam),
          message: wijstab.naam,
        ),
        bottom: currentlyDownloading == null
            ? null
            : PreferredSize(
                child: LinearProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color.fromARGB(
                      100,
                      255,
                      255,
                      255,
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  value: currentlyDownloading.downloadCount / currentlyDownloading.size,
                ),
                preferredSize: Size.fromHeight(2),
              ),
      ),
      body: Futuristic(
        autoStart: true,
        errorBuilder: (BuildContext context, error, retry) {
          return Text(error);
        },
        futureBuilder: () async {
          await account.magister.studiewijzers.loadTab(
            wijstab,
          );
        },
        busyBuilder: (BuildContext context) => Center(
          child: CircularProgressIndicator(),
        ),
        dataBuilder: (BuildContext context, _) {
          return ListView(
            children: [
              if (wijstab.omschrijving
                  .replaceAll(RegExp("<[^>]*>"), "") // Hier ga ik echt zo hard van janken dat ik het liefst meteen van een brug afspring, maar het werkt wel.
                  .isNotEmpty)
                SeeCard(
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: WebContent(
                      wijstab.omschrijving,
                    ),
                  ),
                ),
              SeeCard(
                column: [
                  for (Bron wijsbron in wijstab.bronnen)
                    BijlageItem(
                      wijsbron,
                      onTap: () {
                        if (currentlyDownloading != null) return;
                        currentlyDownloading = wijsbron;
                        account.magister.bronnen.downloadFile(
                          wijsbron,
                          (count, _) {
                            setState(
                              () {
                                wijsbron.downloadCount = count;
                                if (count >= currentlyDownloading.size) {
                                  currentlyDownloading = null;
                                }
                              },
                            );
                          },
                        );
                      },
                      border: wijstab.bronnen.last != wijsbron
                          ? Border(
                              bottom: greyBorderSide(),
                            )
                          : null,
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
