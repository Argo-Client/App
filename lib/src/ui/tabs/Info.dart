import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:futuristic/futuristic.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

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
                      ExpansionTile(
                        leading: Icon(Icons.ad_units),
                        title: Text("Github Commit"),
                        subtitle: Text("Commit hash: $commitSha"),
                        maintainState: true,
                        trailing: IconButton(
                          icon: Icon(Icons.launch),
                          onPressed: () {
                            launch("https://github.com/Argo-Client/App/commit/$commitSha");
                          },
                        ),
                        children: [
                          Futuristic<List<ArgoUpdateApi>>(
                            futureBuilder: () => Dio().get<Map<String, dynamic>>("https://download.argo-magister.nl/register.json").then((value) => (value.data["files"] as List)
                                .map(
                                  (e) => ArgoUpdateApi(e),
                                )
                                .toList()),
                            initialBuilder: (context, start) => ElevatedButton.icon(
                              icon: Icon(Icons.refresh),
                              onPressed: start,
                              label: Text("Check Versie"),
                            ),
                            onError: (err, _) => print(err),
                            dataBuilder: (context, versions) {
                              var currentVersion = versions.firstWhere((element) => element.commitHash.startsWith(commitSha), orElse: () => null);
                              var latestVersion = versions.isEmpty ? null : versions.last;
                              var isLatest = currentVersion == latestVersion;

                              var formatter = DateFormat("dd-MM-y HH:mm");

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (currentVersion != null)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Huidige versie: ${isLatest ? "latest" : ""}",
                                          textScaleFactor: 1.2,
                                        ),
                                        Text("Versie: ${currentVersion.commitHash.substring(0, 7)}"),
                                        Text(currentVersion.commitMessage.split("\n").first),
                                        Text(formatter.format(currentVersion.timestamp)),
                                      ],
                                    ),
                                  if (currentVersion != null && !isLatest)
                                    Padding(
                                      padding: EdgeInsets.only(top: 10),
                                    ),
                                  if (!isLatest)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Nieuwste versie:",
                                          textScaleFactor: 1.2,
                                        ),
                                        Text("Versie: ${latestVersion.commitHash.substring(0, 7)}"),
                                        Text(
                                          latestVersion.commitMessage.split("\n").first,
                                          overflow: TextOverflow.fade,
                                        ),
                                        Text(formatter.format(latestVersion.timestamp)),
                                        ElevatedButton.icon(
                                          icon: Icon(Icons.download),
                                          onPressed: () {
                                            launch("https://download.argo-magister.nl/${latestVersion.downloadURL}");
                                          },
                                          label: Text("Update"),
                                        ),
                                      ],
                                    ),
                                ],
                              );
                            },
                          )
                        ],
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
