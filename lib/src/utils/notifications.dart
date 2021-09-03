import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

import 'package:argo/src/utils/hive/adapters.dart';
import 'package:argo/src/utils/boxes.dart';
import 'package:argo/src/utils/account.dart';

// Notificatie zooi:
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('splash');
final IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings();
final InitializationSettings initializationSettings = InitializationSettings(
  android: initializationSettingsAndroid,
  iOS: initializationSettingsIOS,
);

class Notifications {
  void initialize() async {
    tz.initializeTimeZones();
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void lessonNotifications() async {
    Map<String, List<List<Les>>> lessons = account.lessons;

    await flutterLocalNotificationsPlugin.cancel(0);
    DateFormat formatDate = DateFormat("yyyy-MM-dd");
    DateTime now = DateTime.now();
    DateTime lastMonday = now.subtract(
      Duration(
        days: now.weekday - 1,
      ),
    );
    String weekslug = formatDate.format(lastMonday);
    if (lessons[weekslug] != null)
      for (int d = lessons[weekslug].length - 1; d >= 0; d--) {
        // in reverse zodat de dichtsbijzijnde als laatst is en dus de anderen overwrite (indien nodig)
        List<Les> dag = lessons[weekslug][d];
        for (int i = dag.length - 1; i >= 0; i--) {
          Les les = dag[i];
          if (les.startDateTime.subtract(Duration(minutes: userdata.get("preNotificationMinutes"))).isBefore(DateTime.now())) continue;
          if (les.uitval) continue;
          flutterLocalNotificationsPlugin.zonedSchedule(
            0,
            lesString(les),
            dag.length > i + 1 ? lesString(dag[i + 1]) : null,
            tz.TZDateTime.from(les.startDateTime.subtract(Duration(minutes: userdata.get("preNotificationMinutes"))), tz.local),
            NotificationDetails(
              android: AndroidNotificationDetails(
                '0',
                'Afspraken',
                'Meldingen voor lessen',
                importance: Importance.max,
                priority: Priority.defaultPriority,
                ticker: 'ticker',
                styleInformation: InboxStyleInformation(
                  dag.skip(i + 1).map((les) => lesString(les)).toList(),
                  contentTitle: lesString(les),
                ),
                when: les.startDateTime.millisecondsSinceEpoch,
              ),
            ),
            androidAllowWhileIdle: true,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          );
        }
      }
  }

  String lesString(Les les) => "${les.startTime} - ${les.endTime}: ${les.getName()}" + (les.location == null ? "" : " - ${les.location}");
  Notifications() {
    initialize();
  }
}

Notifications notifications = Notifications();
