part of main;

class Studiewijzers extends StatefulWidget {
  @override
  _Studiewijzers createState() => _Studiewijzers();
}

class _Studiewijzers extends State<Studiewijzers>
    with AfterLayoutMixin<Studiewijzers> {
  void afterFirstLayout(BuildContext context) => handleError(
      account.magister.studiewijzers.refresh,
      "Fout tijdens verversen van studiewijzers",
      context);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.menu,
          ),
          onPressed: () {
            _layoutKey.currentState.openDrawer();
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
                      border: account.studiewijzers.length - 1 ==
                              account.studiewijzers.indexOf(wijs)
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
          await handleError(account.magister.studiewijzers.refresh,
              "Kon studiewijzer niet verversen", context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          wijs.naam,
        ),
      ),
      body: Futuristic(
        autoStart: true,
        futureBuilder: wijs.children != null
            ? () async {}
            : () async =>
                await account.magister.studiewijzers.loadChildren(wijs),
        busyBuilder: (BuildContext context) => Center(
          child: CircularProgressIndicator(),
        ),
        errorBuilder: (BuildContext context, error, retry) {
          return RefreshIndicator(
            onRefresh: () async => retry(),
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Container(
                height: MediaQuery.of(context).size.height -
                    80, // Hier ga ik hard van huilen, houden zo.
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
                              "Fout tijdens het laden van studiewijzer: \n\n" +
                                  (error as dynamic).error,
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
                  SeeCard(
                    border: wijs.children.length - 1 ==
                            wijs.children.indexOf(wijstab)
                        ? null
                        : Border(
                            bottom: greyBorderSide(),
                          ),
                    child: ListTile(
                      title: Text(
                        wijstab.naam,
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => StudiewijzerTab(wijstab),
                          ),
                        );
                      },
                    ),
                  ),
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
                  value: currentlyDownloading.downloadCount /
                      currentlyDownloading.size,
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
                  .replaceAll(RegExp("<[^>]*>"),
                      "") // Hier ga ik echt zo hard van janken dat ik het liefst meteen van een brug afspring, maar het werkt wel.
                  .isNotEmpty)
                SeeCard(
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: WebContent(
                      wijstab.omschrijving,
                    ),
                  ),
                ),
              for (Bron wijsbron in wijstab.bronnen)
                StatefulBuilder(
                  builder: (BuildContext context, _) {
                    List<String> splittedNaam = wijsbron.naam.split(".");
                    bool hasExtension =
                        wijsbron.naam.contains(".") && !wijsbron.isFolder;

                    return Tooltip(
                      child: SeeCard(
                        child: ListTileBorder(
                          onTap: () {
                            if (currentlyDownloading != null) return;
                            currentlyDownloading = wijsbron;
                            account.magister.bronnen.downloadFile(
                              wijsbron,
                              (count, _) {
                                setState(
                                  () {
                                    wijsbron.downloadCount = count;
                                    // print(wijsbron.downloadCount);
                                    if (count >= currentlyDownloading.size) {
                                      currentlyDownloading = null;
                                    }
                                    // print("klaar ${wijsbron.downloadCount} | ${wijsbron.size}");
                                  },
                                );
                              },
                            );
                          },
                          leading: Column(
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
                                  hasExtension
                                      ? splittedNaam.removeLast().toUpperCase()
                                      : wijsbron.naam,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                  ),
                                ),
                              )
                            ],
                          ),
                          subtitle: Padding(
                            child: Text(
                              filesize(wijsbron.size),
                            ),
                            padding: EdgeInsets.only(
                              bottom: 5,
                            ),
                          ),
                          title: Padding(
                            child: Text(
                              hasExtension ? splittedNaam.first : wijsbron.naam,
                              overflow: TextOverflow.ellipsis,
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                          ),
                          trailing: wijsbron.downloadCount == wijsbron.size
                              ? Icon(
                                  Icons.arrow_forward_ios,
                                  size: 18,
                                )
                              : wijsbron.downloadCount == null
                                  ? Icon(
                                      Icons.cloud_download,
                                      size: 22,
                                    )
                                  : CircularProgressIndicator(),
                          border: Border(
                            top: greyBorderSide(),
                          ),
                        ),
                      ),
                      padding: EdgeInsets.all(
                        5,
                      ),
                      message: wijsbron.naam,
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
