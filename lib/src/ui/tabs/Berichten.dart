part of main;

class Berichten extends StatefulWidget {
  @override
  _Berichten createState() => _Berichten();
}

class _Berichten extends State<Berichten> {
  _Berichten() {
    if (account.id != 0) {
      account.magister.berichten.refresh().then((_) {
        setState(() {});
      }).catchError((e) {
        FlushbarHelper.createError(message: "Fout tijdens verversen van berichten:\n$e")..show(context);
        throw (e);
      });
    }
  }
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
              Map ber = account.berichten[i];
              if (lastDay != ber["dag"]) {
                berichten.add(
                  Padding(
                    padding: EdgeInsets.only(
                      left: 15,
                      top: 20,
                      bottom: 20,
                    ),
                    child: Text(
                      ber["dag"],
                      style: TextStyle(color: userdata.get("accentColor")),
                    ),
                  ),
                );
              }
              berichten.add(
                Container(
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      trailing: Padding(
                        child: ber["prioriteit"] ? Icon(Icons.error, color: Colors.redAccent) : null,
                        padding: EdgeInsets.only(
                          top: 7,
                          left: 7,
                        ),
                      ),
                      subtitle: Text(ber["onderwerp"]),
                      title: Text(ber["afzender"]),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BerichtPagina(ber),
                          ),
                        );
                      },
                    ),
                  ),
                  decoration: account.berichten.length - 1 == i || account.berichten[i + 1]["dag"] != ber["dag"]
                      ? null
                      : BoxDecoration(
                          border: Border(
                            bottom: greyBorderSide(),
                          ),
                        ),
                ),
              );
              lastDay = ber["dag"];
            }
            return ListView(
              children: berichten,
            );
          },
        ),
        onRefresh: () async {
          try {
            await account.magister.berichten.refresh();
            setState(() {});
          } catch (e) {
            FlushbarHelper.createError(message: "Kon berichten niet verversen:\n$e")..show(context);
            throw (e);
          }
        },
      ),
    );
  }
}

class BerichtPagina extends StatelessWidget {
  final Map ber;
  const BerichtPagina(this.ber);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ber["onderwerp"],
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
      body: FutureBuilder(
        future: account.magister.berichten.getBerichtFromId(ber["id"]),
        builder: (BuildContext context, AsyncSnapshot data) {
          Map loaded = data.data;
          return SingleChildScrollView(
            child: Column(
              children: [
                Card(
                  margin: EdgeInsets.only(
                    bottom: 20,
                    top: 0,
                    left: 0,
                    right: 0,
                  ),
                  child: Column(
                    children: [
                      if (ber["afzender"] != null)
                        ListTile(
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
                            ber["afzender"],
                          ),
                          subtitle: Text(
                            "Afzender",
                          ),
                        ),
                      if (ber["dag"] != null)
                        ListTile(
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
                            ber["dag"],
                          ),
                          subtitle: Text(
                            "Verzonden",
                          ),
                        ),
                      if (loaded != null && loaded["ontvangers"] != null)
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
                            loaded["ontvangers"],
                          ),
                          subtitle: Text(
                            "Ontvanger(s)",
                          ),
                        ),
                      if (loaded != null && loaded["cc"] != null)
                        ListTile(
                          leading: Padding(
                            child: Icon(
                              Icons.people,
                            ),
                            padding: EdgeInsets.only(
                              top: 7,
                              left: 7,
                            ),
                          ),
                          title: Text(
                            loaded["cc"],
                          ),
                          subtitle: Text(
                            "CC",
                          ),
                        ),
                    ],
                  ),
                ),
                if (loaded != null && loaded["inhoud"] != null)
                  Card(
                    margin: EdgeInsets.zero,
                    child: Container(
                      padding: EdgeInsets.all(
                        20,
                      ),
                      child: Html(
                        onLinkTap: (link) {
                          launch(link);
                        },
                        data: loaded["inhoud"],
                      ),
                    ),
                  ),
                if (loaded == null) CircularProgressIndicator()
              ],
            ),
          );
        },
      ),
    );
  }
}

class NieuwBerichtPagina extends StatelessWidget {
  final Map ber;
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
              Card(
                margin: EdgeInsets.only(
                  bottom: 20,
                ),
                child: Column(
                  children: [
                    Container(
                      child: ListTile(
                        leading: Icon(Icons.person_outlined),
                        title: TextFormField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            hintText: 'Aan',
                          ),
                          initialValue: ber != null ? ber["afzender"] : null,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Veld verplicht';
                            }
                            return null;
                          },
                        ),
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: greyBorderSide(),
                        ),
                      ),
                    ),
                    Container(
                      child: ListTile(
                        leading: Icon(Icons.people_outlined),
                        title: TextFormField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            hintText: 'CC',
                          ),
                          initialValue: ber != null ? ber["cc"] : null,
                        ),
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: greyBorderSide(),
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.subject),
                      title: TextFormField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          hintText: 'Onderwerp',
                        ),
                        initialValue: ber != null ? "RE: " + ber["onderwerp"] : null,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Veld verplicht';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.edit),
                      title: TextFormField(
                        keyboardType: TextInputType.multiline,
                        maxLines: 20,
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
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.send,
          color: Colors.white,
        ),
      ),
    );
  }
}
