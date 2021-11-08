import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:argo/src/utils/boxes.dart';
import 'package:argo/src/utils/account.dart';

import 'package:argo/src/ui/components/ContentHeader.dart';
import 'package:argo/src/ui/components/AppPage.dart';
import 'package:argo/src/ui/components/Refreshable.dart';

class MijnGegevens extends StatefulWidget {
  @override
  _MijnGegevens createState() => _MijnGegevens();
}

class _MijnGegevens extends State<MijnGegevens> {
  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: Text("Mijn Gegevens"),
      body: Refreshable(
        type: "mijn gegevens",
        onRefresh: account().magister.profileInfo.refresh,
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 20,
              ),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).backgroundColor,
                      child: userdata.get("useIcon") || account().profilePicture == null
                          ? Icon(
                              Icons.person_outline,
                              size: 60,
                            )
                          : Image.memory(
                              base64Decode(
                                account().profilePicture,
                              ),
                            ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * (1 / 2),
                        child: Text(
                          account().fullName,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                      Text(
                        account().klasCode,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Divider(),
            ),
            ListTile(
              title: Text(
                "Studie",
              ),
              subtitle: Text(
                account().klas,
              ),
            ),
            Divider(),
            ContentHeader("Persoonlijke info"),
            ListTile(
              title: Text(
                "Officiële naam",
              ),
              subtitle: Text(
                account().officialFullName,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Divider(),
            ),
            ListTile(
              title: Text(
                "Geboortedatum",
              ),
              subtitle: Text(
                account().birthdate,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Divider(),
            ),
            ListTile(
              title: Text(
                "Telefoonnummer",
              ),
              subtitle: Text(
                account().phone,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Divider(),
            ),
            ListTile(
              title: Text(
                "E-mailadres",
              ),
              subtitle: Text(
                account().email,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Divider(),
            ),
            Padding(
              padding: EdgeInsets.only(
                bottom: 10,
              ),
              child: ListTile(
                title: Text(
                  "Adres",
                ),
                subtitle: Text(
                  account().address,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
