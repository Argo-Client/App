import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:argo/src/utils/account.dart';
import 'package:argo/src/utils/hive/adapters.dart';
// import 'package:argo/src/utils/hive/init.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' show initializeTimeZones;
import 'package:timezone/timezone.dart' show TZDateTime, local;
import 'package:hive_flutter/hive_flutter.dart';

// void postNotificationForNextLesson() async {
//   try {
//     await initHive();
//     await Notifications().postNotificationForFirstLesson();
//   } catch (e) {
//     print("Error in postNotificationForNextLesson");
//     print(e);
//   }
// }

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
    await AndroidAlarmManager.cancel(0);
  }

  void scheduleBackground() async {
    if (userdata.get("lessonNotifications") == true && lessons.isNotEmpty) {
      // await AndroidAlarmManager.initialize();
      initializeTimeZones();

      await notifications.initialize(
        InitializationSettings(
          android: AndroidInitializationSettings("splash"),
        ),
      );

      await Future.wait(
        lessons.map((lesson) async {
          await _scheduleNotificationFor(lesson);
          // AndroidAlarmManager.oneShotAt(
          //   lesson.startDateTime.subtract(
          //     Duration(
          //       minutes: userdata.get("preNotificationMinutes") as int,
          //     ),
          //   ),
          //   // DateTime.now().add(Duration(seconds: 10)),
          //   0,
          //   postNotificationForNextLesson,
          //   rescheduleOnReboot: true,
          //   wakeup: true,
          //   allowWhileIdle: true,
          // );
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
    ); // await notifications.show(
    //   lesson.id,
    //   _lesString(lesson),
    //   futureDay.isEmpty ? null : _lesString(futureDay.first),
    //   NotificationDetails(
    //     android: AndroidNotificationDetails(
    //       lesson.id.toString(),
    //       "Afspraken",
    //       'Meldingen voor lessen',
    //       importance: Importance.max,
    //       priority: Priority.defaultPriority,
    //       ticker: 'ticker',
    //       styleInformation: InboxStyleInformation(
    //         futureDay.map(_lesString).toList(),
    //         contentTitle: _lesString(lesson),
    //       ),
    //       when: lesson.startDateTime.millisecondsSinceEpoch,
    //     ),
    //   ),
    // );
  }

  // Future<void> postNotificationForFirstLesson() async {
  //   if (lessons.isEmpty) {
  //     return print("Geen geschikte lessen voor notificatie");
  //   }
  //   await _postNotificationFor(lessons.first);
  // }

  Iterable<Les> notifiableLessons(Map<String, List<List<Les>>> lessons) {
    List<Les> lessen = lessons.values.expand((x) => x).expand((x) => x).toList();
    Iterable<Les> futureLessons = lessen.where((lesson) => lesson.startDateTime.isAfter(DateTime.now()));
    Iterable<Les> futureNoUitvalLessons = futureLessons.where((lesson) => !lesson.uitval);

    return futureNoUitvalLessons.take(10);
  }
}
