import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import 'package:Argo/src/utils/hive/adapters.dart';

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
    await flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: (ewa) {
      print("notificatie selected");
      print(ewa);
      return Future.value(" hierzo 164");
    });
  }

  void showNotification(Map<String, List<List<Les>>> lessons) {
    DateFormat formatDate = DateFormat("yyyy-MM-dd");
    DateTime now = DateTime.now();
    DateTime lastMonday = now.subtract(
      Duration(
        days: now.weekday - 1,
      ),
    );
    String weekslug = formatDate.format(lastMonday);
    if (lessons[weekslug] != null)
      for (List dag in lessons[weekslug]) {
        for (int i = 0; i < dag.length; i++) {
          Les les = dag[i];
          if (les.startDateTime.isBefore(DateTime.now())) continue;
          if (les.uitval) continue;
          flutterLocalNotificationsPlugin.zonedSchedule(
            les.id,
            lesString(les),
            dag.length > i + 1 ? lesString(dag[i + 1]) : null,
            tz.TZDateTime.from(les.startDateTime, tz.local),
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

  String lesString(Les les) => "${les.startTime} - ${les.endTime}: ${les.title}" + (les.location == null ? "" : " - ${les.location}");
  Notifications() {
    initialize();
  }
}
