part of main;

class Berichten extends StatefulWidget {
  @override
  _Berichten createState() => _Berichten();
}

class _Berichten extends State<Berichten> with AfterLayoutMixin<Berichten> {
  void afterFirstLayout(BuildContext context) => handleError(account.magister.berichten.refresh, "Fout tijdens verversen van berichten", context);
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
        title: Text("Berichten"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => NieuwBerichtPagina(null),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        child: ValueListenableBuilder(
          valueListenable: updateNotifier,
          builder: (BuildContext context, box, Widget child) {
            List<Widget> berichten = [];
            String lastDay;
            for (int i = 0; i < account.berichten.length; i++) {
              Bericht ber = account.berichten[i];
              if (lastDay != ber.dag) {
                berichten.add(
                  ContentHeader(ber.dag),
                );
              }
              berichten.add(
                SeeCard(
                  border: account.berichten.length - 1 == i || account.berichten[i + 1].dag != ber.dag
                      ? null
                      : Border(
                          bottom: greyBorderSide(),
                        ),
                  child: ListTile(
                    trailing: Padding(
                      child: ber.prioriteit ? Icon(Icons.error, color: Colors.redAccent) : null,
                      padding: EdgeInsets.only(
                        top: 7,
                        left: 7,
                      ),
                    ),
                    subtitle: Text(
                      ber.afzender,
                    ),
                    title: Text(
                      ber.onderwerp,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BerichtPagina(ber),
                        ),
                      );
                    },
                  ),
                ),
              );
              lastDay = ber.dag;
            }
            return ListView(
              children: berichten,
            );
          },
        ),
        onRefresh: () async {
          await handleError(account.magister.berichten.refresh, "Kon berichten niet verversen", context);
        },
      ),
    );
  }
}

class BerichtPagina extends StatelessWidget {
  final Bericht ber;
  const BerichtPagina(this.ber);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ber.onderwerp,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.reply),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => NieuwBerichtPagina(ber),
                ),
              );
            },
          ),
        ],
      ),
      body: Futuristic(
        autoStart: true,
        futureBuilder: () => account.magister.berichten.getBerichtFromId(ber.id),
        busyBuilder: (context) => Center(
          child: CircularProgressIndicator(),
        ),
        errorBuilder: (context, error, retry) => RefreshIndicator(
          onRefresh: () async => retry(),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width - 50,
                height: MediaQuery.of(context).size.height - 80,
                child: Text(
                  "Kon geen verbinding maken met Magister:\n${(error as dynamic).error.toString()}",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        dataBuilder: (context, ber) => SingleChildScrollView(
          child: Column(
            children: [
              SeeCard(
                margin: EdgeInsets.only(
                  bottom: 20,
                  top: 0,
                  left: 0,
                  right: 0,
                ),
                column: [
                  if (ber.afzender != null)
                    ListTileBorder(
                      border: Border(
                        bottom: greyBorderSide(),
                      ),
                      leading: Padding(
                        child: Icon(
                          Icons.person_outlined,
                        ),
                        padding: EdgeInsets.only(
                          top: 7,
                          left: 7,
                        ),
                      ),
                      title: Text(
                        ber.afzender,
                      ),
                      subtitle: Text(
                        "Afzender",
                      ),
                    ),
                  if (ber.dag != null)
                    ListTileBorder(
                      border: Border(
                        bottom: greyBorderSide(),
                      ),
                      leading: Padding(
                        child: Icon(
                          Icons.send,
                        ),
                        padding: EdgeInsets.only(
                          top: 7,
                          left: 7,
                        ),
                      ),
                      title: Text(
                        ber.dag,
                      ),
                      subtitle: Text(
                        "Verzonden",
                      ),
                    ),
                  if (ber.ontvangers != null)
                    ListTile(
                      leading: Padding(
                        child: Icon(
                          Icons.people_outlined,
                        ),
                        padding: EdgeInsets.only(
                          top: 7,
                          left: 7,
                        ),
                      ),
                      title: Text(
                        ber.ontvangers,
                      ),
                      subtitle: Text(
                        "Ontvanger(s)",
                      ),
                    ),
                  if (ber.cc != null)
                    ListTile(
                      leading: Padding(
                        child: Icon(
                          Icons.people_outline,
                        ),
                        padding: EdgeInsets.only(
                          top: 7,
                          left: 7,
                        ),
                      ),
                      title: Text(
                        ber.cc,
                      ),
                      subtitle: Text(
                        "CC",
                      ),
                    ),
                ],
              ),
              if (ber.inhoud != null)
                SeeCard(
                  child: Container(
                    padding: EdgeInsets.all(
                      20,
                    ),
                    child: Html(
                      onLinkTap: launch,
                      data: ber.inhoud,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class NieuwBerichtPagina extends StatelessWidget {
  final Bericht ber;
  const NieuwBerichtPagina(this.ber);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Nieuw bericht",
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          child: Column(
            children: [
              SeeCard(
                column: [
                  ListTileBorder(
                    border: Border(
                      bottom: greyBorderSide(),
                    ),
                    leading: Icon(Icons.person_outlined),
                    title: TextFormField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintText: 'Aan',
                      ),
                      initialValue: ber != null ? ber.afzender : null,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Veld verplicht';
                        }
                        return null;
                      },
                    ),
                  ),
                  ListTileBorder(
                    border: Border(
                      bottom: greyBorderSide(),
                    ),
                    leading: Icon(Icons.people_outlined),
                    title: TextFormField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintText: 'CC',
                      ),
                      initialValue: ber != null ? ber.cc : null,
                    ),
                  ),
                  ListTileBorder(
                    border: Border(
                      bottom: greyBorderSide(),
                    ),
                    leading: Icon(Icons.people_outlined),
                    title: TextFormField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintText: 'BCC',
                      ),
                      initialValue: ber != null ? ber.cc : null,
                    ),
                  ),
                  ListTileBorder(
                    border: Border(
                      bottom: greyBorderSide(),
                    ),
                    leading: Icon(Icons.subject),
                    title: TextFormField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintText: 'Onderwerp',
                      ),
                      initialValue: ber != null ? "RE: " + ber.onderwerp : null,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Veld verplicht';
                        }
                        return null;
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.edit),
                    title: TextFormField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 25,
                      scrollPadding: EdgeInsets.all(20.0),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintText: 'Inhoud',
                      ),
                      // validator: validator,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        children: [
          Spacer(
            flex: 1,
          ),
          Padding(
            child: FloatingActionButton(
              onPressed: () async {
                // FilePickerResult result = await FilePicker.platform.pickFiles(
                //   allowMultiple: true,
                // );

                // if (result != null) {
                //   List<File> files = result.paths.map((path) => File(path)).toList();
                // } else {
                //   // User canceled the picker
                // }
              },
              child: Icon(
                Icons.attach_file,
                color: Colors.white,
              ),
            ),
            padding: EdgeInsets.only(
              bottom: 10,
            ),
          ),
          FloatingActionButton(
            onPressed: () {
              /// [SAM] fix dit
            },
            child: Icon(
              Icons.send,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
