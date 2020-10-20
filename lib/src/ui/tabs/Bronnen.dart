part of main;

class Bronnen extends StatefulWidget {
  @override
  _Bronnen createState() => _Bronnen();
}

class _Bronnen extends State<Bronnen> with AfterLayoutMixin<Bronnen> {
  List<List<Bron>> bronnenView = [account.bronnen];
  List<String> breadcrumbs = ["Bronnen"];
  void afterFirstLayout(BuildContext context) => handleError(account.magister.bronnen.refresh, "Fout tijdens verversen van bronnen", context);
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (bronnenView.length > 1) bronnenView.removeLast();
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
          title: Text("Bronnen"),
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
                            bronnenView = bronnenView.take(i + 1).toList();
                          });
                        },
                      ),
                    if (bronnenView.last == null)
                      CircularProgressIndicator()
                    else if (bronnenView.last.isEmpty)
                      Center(
                        child: Text("Deze map is leeg"),
                      )
                    else
                      for (Bron bron in bronnenView.last)
                        ListTile(
                          leading: Icon(bron.isFolder ? Icons.folder_outlined : Icons.insert_drive_file_outlined),
                          title: Text(bron.naam),
                          subtitle: bron.downloadCount == null ? null : LinearProgressIndicator(value: bron.downloadCount / bron.size),
                          trailing: bron.isFolder ? null : Text(filesize(bron.size)),
                          onTap: () async {
                            if (bron.isFolder) {
                              breadcrumbs.add(bron.naam);
                              bronnenView.add(bron.children);
                              setState(() {});
                              if (bron.children == null) {
                                await handleError(() async => await account.magister.bronnen.loadChildren(bron), "Kon ${bron.naam} niet laden.", context, () {
                                  setState(() {});
                                  print("Length voor ${bronnenView.length}");
                                  bronnenView = bronnenView.where((list) => list != null).toList();

                                  print("Length na ${bronnenView.length}");
                                  bronnenView.add(bron.children);
                                });
                              }
                            } else {
                              account.magister.bronnen.downloadFile(bron, (count, total) {
                                setState(() {
                                  bron.downloadCount = count;
                                });
                              });
                            }
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
