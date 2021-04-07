import 'package:argo/main.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:futuristic/futuristic.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:package_info/package_info.dart';

import 'package:argo/src/ui/components/Card.dart';
import 'package:argo/src/ui/components/Utils.dart';
import 'package:argo/src/ui/components/ListTileBorder.dart';
import 'package:argo/src/ui/components/AppPage.dart';
import 'package:argo/src/ui/components/ContentHeader.dart';

class Info extends StatefulWidget {
  @override
  _Info createState() => _Info();
}

class _Info extends State<Info> {
  String url = "https://argo-magister.net/links?";

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
              text: "Credits",
            ),
          ],
        ),
        title: Text("Info"),
        body: TabBarView(
          children: [
            ListView(
              children: [
                ContentHeader("Algemeen"),
                SeeCard(
                  column: [
                    Container(
                      child: ListTile(
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
                            msg: userdata.get("developerMode") ? "Developer modus was al ontgrendeld" : "Developer modus ontgrendeld",
                          );
                          userdata.put("developerMode", true);
                        },
                      ),
                    ),
                    ListTileBorder(
                      border: Border(
                        top: greyBorderSide(),
                      ),
                      leading: Icon(Icons.device_hub_outlined),
                      title: Text('Github'),
                      subtitle: Text("Source code"),
                      onTap: () => launch("$url?u=argo&type=website"),
                    ),
                    ListTileBorder(
                      border: Border(
                        top: greyBorderSide(),
                      ),
                      leading: Icon(Icons.chat_outlined),
                      title: Text('Discord'),
                      subtitle: Text("Gezelligheid"),
                      onTap: () => launch("$url?u=argo&type=discord"),
                    ),
                  ],
                ),
                ContentHeader("Tools"),
                SeeCard(
                  child: ListTile(
                    leading: Icon(Icons.android_outlined),
                    title: Text('Flutter'),
                    subtitle: Text("Platform gebruikt om de app te maken"),
                    onTap: () => launch("https://flutter.dev/"),
                  ),
                ),
              ],
            ),
            ListView(
              children: [
                ContentHeader("Makers"),
                SeeCard(
                  column: [
                    ExpansionTile(
                      leading: Icon(Icons.person_outlined),
                      title: Text('Guus van Meerveld'),
                      subtitle: Text('Bijdrage: UI'),
                      children: [
                        ListTile(
                          leading: Icon(Icons.public_outlined),
                          title: Text("Website"),
                          onTap: () {
                            launch("${url}u=guus&type=website");
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.device_hub_outlined),
                          title: Text("Github"),
                          onTap: () {
                            launch("${url}u=guus&type=github");
                          },
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: greyBorderSide(),
                        ),
                      ),
                    ),
                    ExpansionTile(
                      leading: Icon(Icons.person_outlined),
                      title: Text('Sam Taen'),
                      subtitle: Text('Bijdrage: Backend'),
                      children: [
                        ListTile(
                          leading: Icon(Icons.public_outlined),
                          title: Text("Website"),
                          onTap: () {
                            launch("${url}u=sam&type=website");
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.device_hub_outlined),
                          title: Text("Github"),
                          onTap: () {
                            launch("${url}u=sam&type=github");
                          },
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: greyBorderSide(),
                        ),
                      ),
                    ),
                    ExpansionTile(
                      leading: Icon(Icons.person_outlined),
                      title: Text('Martijn Oosterhuis'),
                      subtitle: Text('Bijdrage: Developer Modus'),
                      children: [
                        ListTile(
                          leading: Icon(Icons.public_outlined),
                          title: Text("Website"),
                          onTap: () {
                            launch("${url}u=martijn&type=website");
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.device_hub_outlined),
                          title: Text("Github"),
                          onTap: () {
                            launch("${url}u=martijn&type=website");
                          },
                        ),
                      ],
                    )
                  ],
                ),
                ContentHeader("Support"),
                SeeCard(
                  column: [
                    ExpansionTile(
                      tilePadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      leading: Icon(Icons.person_outlined),
                      title: Text('Sjoerd Bolten'),
                      subtitle: Text('Bijdrage: Hulp met magister inlog, iOS versie'),
                      children: [
                        ListTile(
                          leading: Icon(Icons.public_outlined),
                          title: Text("Website"),
                          onTap: () {
                            launch("${url}u=sjoerd&type=website");
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.device_hub_outlined),
                          title: Text("Github"),
                          onTap: () {
                            launch("${url}u=sjoerd&type=github");
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
