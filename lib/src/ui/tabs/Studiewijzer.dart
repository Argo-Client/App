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
          icon: Icon(Icons.menu),
          onPressed: () {
            _layoutKey.currentState.openDrawer();
          },
        ),
        title: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(
                right: 10,
              ),
              child: Icon(
                Icons.book,
              ),
            ),
            Text(
              "Studiewijzers",
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
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
                  Container(
                    child: SeeCard(
                      child: ListTile(
                        title: Text(wijs.naam),
                        onTap: () async {
                          setState(() {});
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
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: greyBorderSide(),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        onRefresh: () async {
          await handleError(account.magister.bronnen.refresh, "Kon bronnen niet verversen", context);
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
                  Container(
                    decoration: BoxDecoration(
                      border: Border(bottom: greyBorderSide()),
                    ),
                    child: SeeCard(
                        child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        title: Text(wijstab.naam),
                        children: [
                          Padding(
                            child: Futuristic(
                              autoStart: true,
                              futureBuilder: wijstab.bronnen.isNotEmpty ? () async {} : () async => await account.magister.studiewijzers.loadTab(wijstab),
                              busyBuilder: (BuildContext context) => Center(
                                child: CircularProgressIndicator(),
                              ),
                              dataBuilder: (BuildContext context, _) {
                                return Html(
                                  data: wijstab.omschrijving,
                                );
                              },
                            ),
                            padding: EdgeInsets.only(
                              bottom: 10,
                            ),
                          ),
                        ],
                      ),
                    )),
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
