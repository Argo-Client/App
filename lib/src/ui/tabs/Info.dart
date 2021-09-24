import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:futuristic/futuristic.dart';
import 'package:dio/dio.dart';

import 'package:confetti/confetti.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:package_info/package_info.dart';

import 'package:argo/src/utils/boxes.dart';

import 'package:argo/src/ui/components/Card.dart';
import 'package:argo/src/ui/components/AppPage.dart';
import 'package:argo/src/ui/components/ContentHeader.dart';
import 'package:argo/src/ui/components/ListTileDivider.dart';

class ArgoUpdateApi {
  String commitHash;
  String commitMessage;
  String downloadURL;
  DateTime timestamp;

  ArgoUpdateApi(Map<String, dynamic> json) {
    this.commitHash = json["commitID"];
    this.downloadURL = json["downloadURL"];
    this.commitMessage = json["commitMessage"];
    this.timestamp = DateTime.parse(json["timestamp"]).toLocal();
  }
}

class Info extends StatefulWidget {
  @override
  _Info createState() => _Info();
}

class _Info extends State<Info> {
  final String commitSha = const bool.hasEnvironment("GITHUB_SHA") ? const String.fromEnvironment("GITHUB_SHA").substring(0, 7) : null;

  ConfettiController _controllerCenter;

  @override
  void initState() {
    super.initState();
    _controllerCenter = ConfettiController(
      duration: const Duration(seconds: 10),
    );
  }

  @override
  void dispose() {
    _controllerCenter.dispose();
    super.dispose();
  }

  Widget _showVersionDownloader(BuildContext context, List<ArgoUpdateApi> versions) {
    var latestVersion = versions.isEmpty ? null : versions.last;

    var commitMessage = latestVersion.commitMessage.split("\n");

    var title = commitMessage.removeAt(0);

    if (latestVersion.commitHash.substring(0, 7) != commitSha) {
      return AlertDialog(
        title: Text("Nieuwste versie downloaden"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  "Nieuw in deze versie:",
                ),
              ),
              Text(title),
              if (commitMessage.isNotEmpty)
                Padding(
                  child: Text(
                    commitMessage.join("\n"),
                  ),
                  padding: EdgeInsets.only(left: 10),
                )
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Sluit"),
          ),
          ElevatedButton(
            onPressed: () => launch("https://download.argo-magister.nl/${latestVersion.downloadURL}"),
            child: Text("Download"),
          )
        ],
      );
    }

    _controllerCenter.play();

    return AlertDialog(
      title: Text("Je hebt de nieuwste versie al!"),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ConfettiWidget(
              shouldLoop: true,
              confettiController: _controllerCenter,
              numberOfParticles: 50,
              blastDirectionality: BlastDirectionality.explosive,
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Oke"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: AppPage(
        bottom: TabBar(
          tabs: [
            Tab(
              text: "Over",
            ),
            Tab(
              text: "Auteurs",
            ),
          ],
        ),
        title: Text("Info"),
        body: TabBarView(
          children: [
            ListView(
              children: [
                ContentHeader("Algemeen"),
                MaterialCard(
                  children: divideListTiles([
                    ListTile(
                      leading: Icon(Icons.verified_user_outlined),
                      title: Text('Versie'),
                      subtitle: Futuristic(
                        futureBuilder: PackageInfo.fromPlatform,
                        busyBuilder: (BuildContext context) => CircularProgressIndicator(),
                        dataBuilder: (BuildContext context, packageInfo) => Text(packageInfo.version),
                        onError: (err, retry) => print(err),
                        autoStart: true,
                      ),
                      onLongPress: () {
                        Fluttertoast.showToast(
                          msg: "Ontwikkelaars opties ontgrendeld",
                        );
                        userdata.put("developerMode", true);
                      },
                    ),
                    if (commitSha != null)
                      ListTile(
                        leading: Icon(Icons.download_outlined),
                        title: Text("Download de nieuwste bèta"),
                        subtitle: Text("Versie: $commitSha"),
                        onTap: () => showDialog(
                          context: context,
                          builder: (context) => Futuristic<List<ArgoUpdateApi>>(
                            autoStart: true,
                            futureBuilder: () => Dio().get<Map<String, dynamic>>("https://download.argo-magister.nl/register.json").then(
                                  (value) => (value.data["files"] as List)
                                      .map(
                                        (e) => ArgoUpdateApi(e),
                                      )
                                      .toList(),
                                ),
                            errorBuilder: (context, error, retry) {
                              DioError dioError = error;

                              return AlertDialog(
                                title: Text("Fout tijdens het ophalen van de nieuwste versie:"),
                                content: Text(dioError.message),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Sluit"),
                                  ),
                                  ElevatedButton(
                                    child: Text("Opnieuw proberen"),
                                    onPressed: retry,
                                  )
                                ],
                              );
                            },
                            dataBuilder: _showVersionDownloader,
                            busyBuilder: (context) => AlertDialog(
                              content: SingleChildScrollView(
                                child: Column(
                                  children: [CircularProgressIndicator()],
                                ),
                              ),
                              title: Text("Nieuwste versie aan het ophalen..."),
                            ),
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.launch),
                          onPressed: () {
                            launch("https://github.com/Argo-Client/App/commit/$commitSha");
                          },
                        ),
                      ),
                    ListTile(
                      leading: Icon(Icons.device_hub_outlined),
                      title: Text('Github'),
                      subtitle: Text("Broncode"),
                      onTap: () => launch("https://github.com/Argo-Client/App"),
                    ),
                    ListTile(
                      leading: Icon(Icons.chat_outlined),
                      title: Text('Discord'),
                      subtitle: Text("Aankondigingen, feedback en gezelligheid"),
                      onTap: () => launch("https://discord.com/invite/Xc4Xzsm"),
                    )
                  ]),
                ),
                ContentHeader("Tools"),
                MaterialCard(
                  children: divideListTiles([
                    ListTile(
                      leading: Icon(Icons.android_outlined),
                      title: Text('Flutter'),
                      subtitle: Text("Toolkit waarmee de app is gemaakt."),
                      onTap: () => launch("https://flutter.dev/"),
                    )
                  ]),
                ),
              ],
            ),
            ListView(
              children: [
                ContentHeader("Makers"),
                MaterialCard(
                  children: divideListTiles([
                    ExpansionTile(
                      leading: Icon(Icons.person_outlined),
                      title: Text('Guus van Meerveld'),
                      subtitle: Text('Bijdrage: UI'),
                      children: [
                        ListTile(
                          leading: Icon(Icons.public_outlined),
                          title: Text("Website"),
                          onTap: () {
                            launch("https://guusvanmeerveld.dev");
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.device_hub_outlined),
                          title: Text("Github"),
                          onTap: () {
                            launch("https://github.com/Guusvanmeerveld");
                          },
                        ),
                      ],
                    ),
                    ExpansionTile(
                      leading: Icon(Icons.person_outlined),
                      title: Text('Sam Taen'),
                      subtitle: Text('Bijdrage: Magister'),
                      children: [
                        ListTile(
                          leading: Icon(Icons.public_outlined),
                          title: Text("Website"),
                          onTap: () {
                            launch("https://samtaen.nl");
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.device_hub_outlined),
                          title: Text("Github"),
                          onTap: () {
                            launch("https://github.com/Netfloex");
                          },
                        ),
                      ],
                    ),
                    ListTile(
                      leading: Icon(Icons.person_outlined),
                      title: Text('Martijn Oosterhuis'),
                      subtitle: Text('Bijdrage: Ontwikkelaarsmodus'),
                    )
                  ]),
                ),
                ContentHeader("Support"),
                MaterialCard(
                  children: [
                    ExpansionTile(
                      tilePadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      leading: Icon(Icons.person_outlined),
                      title: Text('Sjoerd Bolten'),
                      subtitle: Text('Bijdrage: Inloggen Magister & iOS-versie'),
                      children: [
                        ListTile(
                          leading: Icon(Icons.public_outlined),
                          title: Text("Website"),
                          onTap: () {
                            launch("https://sjoerd.dev");
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.device_hub_outlined),
                          title: Text("Github"),
                          onTap: () {
                            launch("https://github.com/netlob");
                          },
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
