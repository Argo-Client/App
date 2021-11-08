import 'package:argo/src/ui/components/ListTileDivider.dart';
import 'package:flutter/material.dart';

import 'package:after_layout/after_layout.dart';
import 'package:futuristic/futuristic.dart';

import 'package:argo/src/utils/hive/adapters.dart';
import 'package:argo/src/utils/handleError.dart';
import 'package:argo/src/utils/account.dart';

import 'package:argo/src/ui/components/Card.dart';
import 'package:argo/src/ui/components/AppPage.dart';
import 'package:argo/src/ui/components/WebContent.dart';
import 'package:argo/src/ui/components/Bijlage.dart';
import 'package:argo/src/ui/components/EmptyPage.dart';
import 'package:argo/src/ui/components/Refreshable.dart';

class Studiewijzers extends StatefulWidget {
  @override
  _Studiewijzers createState() => _Studiewijzers();
}

class _Studiewijzers extends State<Studiewijzers> with AfterLayoutMixin<Studiewijzers> {
  void afterFirstLayout(BuildContext context) => handleError(account().magister.studiewijzers.refresh, "Fout tijdens verversen van studiewijzers", context);

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: Text("Studiewijzers"),
      body: Refreshable(
        type: "studiewijzers",
        onRefresh: account().magister.studiewijzers.refresh,
        child: account().studiewijzers.isEmpty
            ? EmptyPage(
                text: "Geen studiewijzers",
                icon: Icons.school_outlined,
              )
            : ListView(
                children: divideListTiles([
                  for (var studiewijzer in account().studiewijzers)
                    MaterialCard(
                      child: ListTile(
                        title: Text(studiewijzer.naam),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => StudiewijzerPagina(studiewijzer),
                            ),
                          );
                        },
                      ),
                    )
                ]),
              ),
      ),
    );
  }
}

class StudiewijzerPagina extends StatelessWidget {
  final Wijzer wijs;
  StudiewijzerPagina(this.wijs);

  final ValueNotifier<List<Wijzer>> selected = ValueNotifier([]);

  Widget _buildStudiewijzerPagina(BuildContext context, _) {
    return Refreshable(
      type: "studiewijzer",
      onRefresh: () => Future.delayed(Duration(milliseconds: 100)), // Doet ook nog niet de pagina verversen
      child: Column(
        children: divideListTiles(
          wijs.children
              .map(
                (wijzer) => ValueListenableBuilder(
                  valueListenable: selected,
                  builder: (context, _, _a) {
                    bool isSelected = selected.value.contains(wijzer);

                    return MaterialCard(
                      child: ListTile(
                        selected: isSelected,
                        title: Text(
                          wijzer.naam,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onLongPress: () {
                          selected.value = List.from(selected.value)..add(wijzer);
                        },
                        trailing: wijzer.pinned ? Icon(Icons.push_pin_outlined) : null,
                        onTap: () {
                          if (selected.value.isNotEmpty) {
                            if (isSelected) {
                              selected.value = List.from(selected.value)..remove(wijzer);
                            } else {
                              selected.value = List.from(selected.value)..add(wijzer);
                            }
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => StudiewijzerTab(wijzer),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: ValueListenableBuilder(
          valueListenable: selected,
          builder: (context, _a, _) {
            if (selected.value.isNotEmpty)
              return IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  selected.value = [];
                },
              );
            return IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            );
          },
        ),
        title: selected.value.isNotEmpty
            ? Text("${selected.value.length} geselecteerd")
            : Text(
                wijs.naam,
              ),
        actions: [
          ValueListenableBuilder(
            valueListenable: selected,
            builder: (context, _a, _) {
              bool value = selected.value.where((wijzer) => wijzer.pinned).isEmpty;
              if (selected.value.isNotEmpty)
                return IconButton(
                  onPressed: () {
                    selected.value.forEach((wijzer) {
                      wijzer.pinned = value;
                    });
                    selected.value = [];
                  },
                  icon: Icon(
                    value ? Icons.push_pin_outlined : Icons.remove_circle_outline,
                  ),
                );
              return Container();
            },
          ),
        ],
      ),
      body: Futuristic(
        autoStart: true,
        futureBuilder: wijs.children != null ? () async {} : () async => await account().magister.studiewijzers.loadChildren(wijs),
        busyBuilder: (BuildContext context) => Center(
          child: CircularProgressIndicator(),
        ),
        errorBuilder: (BuildContext context, dynamic error, retry) {
          return RefreshIndicator(
            onRefresh: () async => retry(),
            child: EmptyPage(
              icon: Icons.wifi_off_outlined,
              text: "Geen Internet",
            ),
          );
        },
        dataBuilder: _buildStudiewijzerPagina,
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

  _StudiewijzerTab(this.wijstab);

  Widget _buildStudiewijzerInfo(BuildContext context, _) {
    String title = wijstab.omschrijving.replaceAll(RegExp("<[^>]*>"), ""); // Hier ga ik echt zo hard van janken dat ik het liefst meteen van een brug afspring, maar het werkt wel.
    bool hasContent = title.isNotEmpty || wijstab.bronnen.isNotEmpty;

    if (!hasContent) {
      return EmptyPage(
        icon: Icons.subtitles_off,
        text: "Geen Data",
      );
    }
    return ListView(
      children: divideListTiles([
        if (title.isNotEmpty)
          MaterialCard(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: WebContent(
                wijstab.omschrijving,
              ),
            ),
          ),
        if (wijstab.bronnen.isNotEmpty)
          MaterialCard(
            children: divideListTiles([
              for (var bron in wijstab.bronnen)
                BijlageItem(
                  bron,
                  download: account().magister.bronnen.downloadFile,
                )
            ]),
          ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Tooltip(
          child: Text(wijstab.naam),
          message: wijstab.naam,
        ),
      ),
      body: Futuristic(
        autoStart: true,
        errorBuilder: (_, dynamic error, retry) => RefreshIndicator(
          onRefresh: () async => retry(),
          child: EmptyPage(
            icon: Icons.wifi_off_outlined,
            text: error?.error ?? error?.toString(),
          ),
        ),
        futureBuilder: () async {
          await account().magister.studiewijzers.loadTab(
                wijstab,
              );
        },
        busyBuilder: (BuildContext context) => Center(
          child: CircularProgressIndicator(),
        ),
        dataBuilder: _buildStudiewijzerInfo,
      ),
    );
  }
}
