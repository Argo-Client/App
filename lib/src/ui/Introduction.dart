import 'package:flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';

import 'package:intro_slider/dot_animation_enum.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:flutter_placeholder_textlines/flutter_placeholder_textlines.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:argo/main.dart';
import 'package:argo/src/utils/hive/adapters.dart';

import 'package:argo/src/ui/components/Card.dart';

import 'package:argo/src/utils/login.dart';

class Introduction extends StatefulWidget {
  @override
  _Introduction createState() => _Introduction();
}

class _Introduction extends State<Introduction> {
  List<Color> _colors = [
    Colors.blue,
    Colors.red[400],
    Colors.green,
  ];

  ValueNotifier<bool> akkoord = ValueNotifier(false);
  ValueNotifier<bool> showDot = ValueNotifier(false);

  void onLoggedIn(Account acc, BuildContext context, {String error}) {
    account = acc;
    userdata.put("introduction", true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => App(),
      ),
    );
  }

  void loginPress() {
    if (!akkoord.value) {
      FlushbarHelper.createInformation(message: "Je moet eerst akkoord gaan met ons beleid.").show(context);
      showDot.value = true;
      return;
    }

    MagisterLogin().launch(context, onLoggedIn);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) => new IntroSlider(
          isShowSkipBtn: false,
          renderPrevBtn: Icon(
            Icons.navigate_before,
            color: Colors.white,
          ),
          isShowPrevBtn: true,
          isScrollable: false,
          colorDot: Color.fromRGBO(255, 255, 255, .5),
          sizeDot: 10.0,
          renderNextBtn: Icon(
            Icons.navigate_next,
            color: Colors.white,
          ),
          typeDotAnimation: dotSliderAnimation.SIZE_TRANSITION,
          nameDoneBtn: "LOGIN",
          onDonePress: loginPress,
          slides: [
            Slide(
              widgetTitle: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Welkom",
                    style: TextStyle(color: Colors.white, fontSize: 35),
                  ),
                  ValueListenableBuilder(
                    valueListenable: showDot,
                    builder: (BuildContext context, value, _a) {
                      return !value
                          ? Container()
                          : Container(
                              margin: EdgeInsets.only(bottom: 7.5, left: 2.5),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                                border: Border.all(color: userdata.get("accentColor")),
                              ),
                              width: 7.5,
                              height: 7.5,
                            );
                    },
                  )
                ],
              ),
              widgetDescription: Column(
                children: [
                  Text(
                    "Bedankt voor het downloaden van Argo!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17.5,
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      "Voordat je deze app gebruikt, moet je eerst akkoord gaan met ons beleid:",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 15),
                    child: TextButton(
                      child: Text(
                        "Bekijk hier ons beleid",
                        style: TextStyle(
                          fontSize: 17.5,
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      onPressed: () => launch("https://argo-magister.net/beleid"),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      akkoord.value = !akkoord.value;
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ValueListenableBuilder(
                          valueListenable: akkoord,
                          builder: (context, _, _a) {
                            return Checkbox(
                              activeColor: Colors.orange,
                              value: akkoord.value,
                              onChanged: (value) {
                                akkoord.value = value;
                              },
                            );
                          },
                        ),
                        Text(
                          "Ik ga akkoord",
                          style: TextStyle(
                            fontSize: 17.5,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              backgroundColor: _colors[0],
            ),
            Slide(
              title: "Kies je thema",
              widgetDescription: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(
                                () {
                                  userdata.put("theme", "licht");
                                },
                              );
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width / 2 - 70,
                              child: Column(
                                children: [
                                  SeeCard(
                                    margin: EdgeInsets.symmetric(
                                      vertical: 25,
                                    ),
                                    child: Container(
                                      height: 75,
                                    ),
                                  ),
                                  PlaceholderLines(
                                    count: 3,
                                    align: TextAlign.right,
                                    color: Colors.white,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: 15,
                                    ),
                                    child: RadioListTile(
                                      title: Text("Licht",
                                          softWrap: false,
                                          overflow: TextOverflow.visible,
                                          style: TextStyle(
                                            color: Colors.white,
                                          )),
                                      value: "licht",
                                      groupValue: userdata.get("theme"),
                                      activeColor: Colors.white,
                                      onChanged: (value) {
                                        setState(
                                          () {
                                            userdata.put("theme", value);
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(
                                () {
                                  userdata.put("theme", "donker");
                                },
                              );
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width / 2 - 70,
                              child: Column(
                                children: [
                                  Container(
                                    color: Colors.grey[800],
                                    margin: EdgeInsets.symmetric(
                                      vertical: 25,
                                    ),
                                    height: 75,
                                  ),
                                  PlaceholderLines(
                                    count: 3,
                                    color: Colors.grey[800],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: 15,
                                    ),
                                    child: RadioListTile(
                                      value: "donker",
                                      title: Text("Donker",
                                          softWrap: false,
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                          overflow: TextOverflow.visible),
                                      activeColor: Colors.grey[800],
                                      groupValue: userdata.get("theme"),
                                      onChanged: (value) {
                                        setState(
                                          () {
                                            userdata.put("theme", value);
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width * (3 / 4),
                          child: RadioListTile(
                            title: Text("Gebruik systeem standaard",
                                softWrap: false,
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.visible),
                            value: "systeem",
                            activeColor: Colors.white,
                            groupValue: userdata.get("theme"),
                            onChanged: (value) {
                              setState(
                                () {
                                  userdata.put("theme", value);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              backgroundColor: _colors[1],
            ),
            Slide(
              title: "Inloggen",
              widgetDescription: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 150,
                    ),
                    child: Text(
                      "Om de app te kunnen gebruiken, moet je eerst even inloggen.",
                      style: TextStyle(
                        fontSize: 17.5,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Center(
                    child: TextButton(
                      child: Text(
                        "Log nu in!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                        ),
                      ),
                      onPressed: loginPress,
                    ),
                  ),
                ],
              ),
              backgroundColor: _colors[2],
            ),
          ],
        ),
      ),
    );
  }
}
