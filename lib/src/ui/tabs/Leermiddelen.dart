part of main;

class Leermiddelen extends StatefulWidget {
  @override
  _Leermiddelen createState() => _Leermiddelen();
}

class _Leermiddelen extends State<Leermiddelen> {
  void afterFirstLayout(BuildContext context) => handleError(account.magister.leermiddelen.refresh, "Fout tijdens verversen van leermiddelen", context);
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
        title: Text("Leermiddelen"),
      ),
      body: RefreshIndicator(
        child: ValueListenableBuilder(
            valueListenable: updateNotifier,
            builder: (BuildContext context, _, _a) {
              return Column(
                children: [
                  for (Leermiddel leermiddel in account.leermiddelen)
                    SeeCard(
                      child: Tooltip(
                        message: leermiddel.title,
                        child: ListTileBorder(
                          onTap: () => account.magister.leermiddelen.launch(leermiddel),
                          border: account.leermiddelen.last == leermiddel
                              ? null
                              : Border(
                                  bottom: greyBorderSide(),
                                ),
                          title: Text(
                            leermiddel.title,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            leermiddel?.uitgeverij,
                          ),
                          trailing: Text(
                            leermiddel?.vak?.code ?? "",
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }),
        onRefresh: () async {
          await handleError(account.magister.leermiddelen.refresh, "Fout tijdens verversen van leermiddelen", context);
        },
      ),
    );
  }
}
