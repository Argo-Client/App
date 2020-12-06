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
                child: Row(
                  children: [
                    for (int i = 0; i < breadcrumbs.length; i++)
                      GestureDetector(
                        child: Row(
                          children: [
                            Text(
                              " ${breadcrumbs[i]} ",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 10,
                            ),
                          ],
                        ),
                        onTap: () {
                          setState(
                            () {
                              breadcrumbs = breadcrumbs.take(i + 1).toList();
                              bronnenView = bronnenView.take(i + 1).toList();
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
            preferredSize: Size.fromHeight(25),
          ),
          title: Text("Bronnen"),
        ),
        body: RefreshIndicator(
            child: ValueListenableBuilder(
              valueListenable: updateNotifier,
              builder: (BuildContext context, _, _a) {
                return ListView(
                  children: [
                    if (bronnenView.last == null)
                      Container(
                        height: bodyHeight(context),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (bronnenView.last.isEmpty)
                      Container(
                        height: bodyHeight(context),
                        child: Center(
                          child: Text("Deze map is leeg"),
                        ),
                      )
                    else
                      for (Bron bron in bronnenView.last)
                        StatefulBuilder(
                          builder: (BuildContext context, _) {
                            List<String> splittedNaam = bron.naam.split(".");
                            bool hasExtension = bron.naam.contains(".") && !bron.isFolder;

                            return SeeCard(
                              border: bronnenView.last.last != bron
                                  ? Border(
                                      bottom: greyBorderSide(),
                                    )
                                  : null,
                              child: Tooltip(
                                child: ListTile(
                                  leading: bron.isFolder
                                      ? Icon(Icons.folder_outlined)
                                      : Column(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                top: 5,
                                              ),
                                              child: Icon(
                                                Icons.insert_drive_file_outlined,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                top: 7.5,
                                              ),
                                              child: Text(
                                                hasExtension ? splittedNaam.removeLast().toUpperCase() : bron.naam,
                                                style: TextStyle(
                                                  fontSize: 12.5,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                  title: Text(
                                    hasExtension ? splittedNaam.join(".") : bron.naam,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: bron.isFolder
                                      ? Icon(
                                          Icons.arrow_forward_ios,
                                          size: 18,
                                        )
                                      : bron.downloadCount == bron.size
                                          ? Icon(
                                              Icons.arrow_forward_ios,
                                              size: 18,
                                            )
                                          : bron.downloadCount == null
                                              ? Icon(
                                                  Icons.cloud_download,
                                                  size: 22,
                                                )
                                              : CircularProgressIndicator(),
                                  subtitle: bron.isFolder
                                      // ? Text("${bron.children.length} bestanden")
                                      ? null
                                      : Text(
                                          filesize(
                                            bron.size,
                                          ),
                                        ),
                                  onTap: () async {
                                    if (bron.isFolder) {
                                      breadcrumbs.add(
                                        bron.naam,
                                      );
                                      bronnenView.add(
                                        bron.children,
                                      );
                                      setState(
                                        () {},
                                      );
                                      if (bron.children == null) {
                                        await handleError(
                                          () async => await account.magister.bronnen.loadChildren(bron),
                                          "Kon ${bron.naam} niet laden.",
                                          context,
                                          () {
                                            setState(
                                              () {},
                                            );
                                            bronnenView = bronnenView
                                                .where(
                                                  (list) => list != null,
                                                )
                                                .toList();
                                            bronnenView.add(
                                              bron.children,
                                            );
                                          },
                                        );
                                      }
                                    } else {
                                      account.magister.bronnen.downloadFile(
                                        bron,
                                        (count, total) {
                                          setState(
                                            () {
                                              bron.downloadCount = count;
                                            },
                                          );
                                        },
                                      );
                                    }
                                  },
                                ),
                                message: bron.naam,
                              ),
                            );
                          },
                        ),
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
