import 'package:argo/src/utils/account.dart';
import 'package:argo/src/utils/hive/adapters.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' show initializeTimeZones;
import 'package:timezone/timezone.dart' show TZDateTime, local;
import 'package:hive_flutter/hive_flutter.dart';

class Notifications {
  Account _account;
  Box userdata;
  var notifications = FlutterLocalNotificationsPlugin();
  Iterable<Les> lessons;

  Notifications() {
    _account = account();
    userdata = Hive.box("userdata");
    lessons = notifiableLessons(_account.lessons);
  }

  static void cancel() async {
    await FlutterLocalNotificationsPlugin().cancelAll();
  }

  void scheduleBackground() async {
    Notifications.cancel();

    if (userdata.get("lessonNotifications") == true && lessons.isNotEmpty) {
      initializeTimeZones();

      await notifications.initialize(
        InitializationSettings(
          android: AndroidInitializationSettings("splash"),
          linux: LinuxInitializationSettings(
            defaultActionName: "afspraken",
          ),
        ),
      );

      await Future.wait(
        lessons.map((lesson) async {
          await _scheduleNotificationFor(lesson);
        }),
      );
    } else {
      print("Notifications are disabled");
    }
  }

  String _lesString(Les les) => "${les.startTime} - ${les.endTime}: ${les.getName()}" + (les.location == null ? "" : " - ${les.location}");

  Future<void> _scheduleNotificationFor(Les lesson) async {
    Iterable<Les> day = lessons.where((les) => les.date == lesson.date);
    Iterable<Les> futureDay = day.skip(day.toList().indexOf(lesson) + 1);

    await notifications.zonedSchedule(
      lesson.id,
      _lesString(lesson),
      futureDay.isEmpty ? null : _lesString(futureDay.first),
      TZDateTime.from(
        lesson.startDateTime.subtract(
          Duration(
            minutes: userdata.get("preNotificationMinutes") as int,
          ),
        ),
        local,
      ),
      NotificationDetails(
        android: AndroidNotificationDetails(
          '0',
          'Afspraken',
          channelDescription: 'Meldingen voor lessen',
          importance: Importance.max,
          priority: Priority.defaultPriority,
          ticker: 'ticker',
          styleInformation: InboxStyleInformation(
            futureDay.map(_lesString).toList(),
            contentTitle: _lesString(lesson),
          ),
          when: lesson.startDateTime.millisecondsSinceEpoch,
          timeoutAfter: userdata.get("lessonNotificationsExpire") == true ? userdata.get("lessonNotificationExpiry") * 60000 : null,
        ),
      ),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
  }

  Iterable<Les> notifiableLessons(Map<String, List<List<Les>>> lessons) {
    List<Les> lessen = lessons.values.expand((x) => x).expand((x) => x).toList();
    Iterable<Les> futureLessons = lessen.where((lesson) => lesson.startDateTime.isAfter(DateTime.now()));
    Iterable<Les> futureNoUitvalLessons = futureLessons.where((lesson) => !lesson.uitval);

    return futureNoUitvalLessons.take(10);
  }
}
