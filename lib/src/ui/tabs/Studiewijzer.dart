part of main;

class Studiewijzers extends StatefulWidget {
  @override
  _Studiewijzers createState() => _Studiewijzers();
}

class _Studiewijzers extends State<Studiewijzers> with AfterLayoutMixin<Studiewijzers> {
  List<List<Wijzer>> wijzerView = [account.studiewijzers];
  List<String> breadcrumbs = ["Studiewijzers"];
  void afterFirstLayout(BuildContext context) => handleError(account.magister.studiewijzers.refresh, "Fout tijdens verversen van bronnen", context);
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (wijzerView.length > 1) wijzerView.removeLast();
        if (breadcrumbs.length > 1) breadcrumbs.removeLast();
        setState(() {});
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              _layoutKey.currentState.openDrawer();
            },
          ),
          title: Text("Studiewijzers"),
        ),
        body: RefreshIndicator(
            child: ValueListenableBuilder(
              valueListenable: updateNotifier,
              builder: (BuildContext context, _, _a) {
                return ListView(
                  children: [
                    for (int i = 0; i < breadcrumbs.length; i++)
                      InkWell(
                        child: Text(breadcrumbs[i]),
                        onTap: () {
                          setState(() {
                            breadcrumbs = breadcrumbs.take(i + 1).toList();
                            wijzerView = wijzerView.take(i + 1).toList();
                          });
                        },
                      ),
                    if (wijzerView.last == null)
                      CircularProgressIndicator()
                    else if (wijzerView.last.isEmpty)
                      Center(
                        child: Text("Deze map is leeg"),
                      )
                    else if (wijzerView.last.last.bronnen != null)
                      for (Wijzer wijs in wijzerView.last)
                        ExpansionTile(
                          title: Text(wijs.naam),
                          children: [
                            wijs.bronnen.isEmpty
                                ? CircularProgressIndicator()
                                : Column(children: [
                                    Html(
                                      data: wijs.omschrijving ?? "",
                                      onLinkTap: launch,
                                    ),
                                    for (Bron bron in wijs.bronnen)
                                      ListTile(
                                        leading: Icon(Icons.insert_drive_file_outlined),
                                        title: Text(bron.naam),
                                        subtitle: bron.downloadCount == null ? null : LinearProgressIndicator(value: bron.downloadCount / bron.size),
                                        trailing: Text(filesize(bron.size)),
                                        onTap: () async {
                                          account.magister.bronnen.downloadFile(bron, (count, total) {
                                            setState(() {
                                              bron.downloadCount = count;
                                            });
                                          });
                                        },
                                      )
                                  ]),
                          ],
                          onExpansionChanged: (value) async {
                            if (wijs.bronnen.isEmpty) {
                              handleError(() async => await account.magister.studiewijzers.loadTab(wijs), "Kon ${wijs.naam} niet laden", context);
                            }
                          },
                        )
                    else
                      for (Wijzer wijs in wijzerView.last)
                        ListTile(
                          title: Text(wijs.naam),
                          onTap: () async {
                            breadcrumbs.add(wijs.naam);
                            wijzerView.add(wijs.children);
                            setState(() {});
                            await handleError(() async => await account.magister.studiewijzers.loadChildren(wijs), "Kon ${wijs.naam} niet laden", context, () {
                              wijzerView = wijzerView.where((list) => list != null).toList();
                              wijzerView.add(wijs.children);
                              setState(() {});
                            });
                            // await handleError(() async => await account.magister.bronnen.loadChildren(bron), "Kon ${bron.naam} niet laden.", context, () {
                            // });
                          },
                        )
                  ],
                );
              },
            ),
            onRefresh: () async {
              await handleError(account.magister.bronnen.refresh, "Kon bronnen niet verversen", context);
            }),
      ),
    );
  }
}
