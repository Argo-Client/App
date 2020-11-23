part of main;

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
                      border: Border(
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
  Bron currentlyDownloading;
  _StudiewijzerPagina(this.wijs);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          wijs.naam,
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
        futureBuilder: wijs.children != null ? () async {} : () async => await account.magister.studiewijzers.loadChildren(wijs),
        busyBuilder: (BuildContext context) => Center(
          child: CircularProgressIndicator(),
        ),
        errorBuilder: (BuildContext context, error, retry) {
          return RefreshIndicator(
            onRefresh: () async => retry(),
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Container(
                height: MediaQuery.of(context).size.height - 80, // Hier ga ik hard van huilen, houden zo.
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
                              "Fout tijdens het laden van studiewijzer: \n\n" + (error as dynamic).error,
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
                    border: Border(
                      bottom: greyBorderSide(),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        title: Text(
                          wijstab.naam,
                        ),
                        children: [
                          Futuristic(
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
                              return Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: 17.5,
                                      bottom: 10,
                                    ),
                                    child: WebContent(
                                      wijstab.omschrijving,
                                    ),
                                  ),
                                  for (Bron wijsbron in wijstab.bronnen)
                                    Tooltip(
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
                                        leading: Icon(
                                          Icons.insert_drive_file_outlined,
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
                                            wijsbron.naam,
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
                                      padding: EdgeInsets.all(
                                        5,
                                      ),
                                      message: wijsbron.naam,
                                    ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
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

// for (Wijzer wijs in wijzerView.last)
//                         ExpansionTile(
//                           title: Text(wijs.naam),
//                           children: [
//                             wijs.bronnen.isEmpty
//                                 ? CircularProgressIndicator()
//                                 : Column(
//                                     children: [
//                                       Html(
//                                         data: wijs.omschrijving ?? "",
//                                         onLinkTap: launch,
//                                       ),
//                                       for (Bron bron in wijs.bronnen)
//                                         SeeCard(
//                                           child: ListTile(
//                                             leading: Icon(Icons.insert_drive_file_outlined),
//                                             title: Text(bron.naam),
//                                             subtitle: bron.downloadCount == null ? null : LinearProgressIndicator(value: bron.downloadCount / bron.size),
//                                             trailing: Text(filesize(bron.size)),
//                                             onTap: () async {
//                                               account.magister.bronnen.downloadFile(
//                                                 bron,
//                                                 (count, total) {
//                                                   setState(
//                                                     () {
//                                                       bron.downloadCount = count;
//                                                     },
//                                                   );
//                                                 },
//                                               );
//                                             },
//                                           ),
//                                         ),
//                                     ],
//                                   ),
//                           ],
//                           onExpansionChanged: (value) async {
//                             if (wijs.bronnen.isEmpty) {
//                               handleError(() async => await account.magister.studiewijzers.loadTab(wijs), "Kon ${wijs.naam} niet laden", context);
//                             }
//                           },
//                         )
