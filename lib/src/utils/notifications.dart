import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

import 'package:argo/src/utils/hive/adapters.dart';
import 'package:argo/src/utils/boxes.dart';
import 'package:argo/src/utils/account.dart';

// Notificatie zooi:
FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('splash');
final IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings();

class Notifications {
  Future<void> initialize() async {
    tz.initializeTimeZones();
    await notificationsPlugin.initialize(
      InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      ),
    );
  }

  Future<void> lessonNotifications() async {
    await notificationsPlugin.cancel(0);

    DateFormat formatDate = DateFormat("yyyy-MM-dd");
    DateTime now = DateTime.now();
    DateTime lastMonday = now.subtract(
      Duration(
        days: now.weekday - 1,
      ),
    );
    String weekslug = formatDate.format(lastMonday);

    List<List<Les>> weekDaysLessons = account().lessons[weekslug];
    List<Les> weekLessons = weekDaysLessons == null ? null : weekDaysLessons.expand((x) => x).toList();

    if (weekLessons != null) {
      Les les = weekLessons.lastWhere(
        (les) {
          bool isFuture = lesNotificationTime(les).isAfter(DateTime.now());
          bool noUitval = !les.uitval;

          return isFuture && noUitval;
        },
      );
      List<Les> day = account().lessons[weekslug].firstWhere((day) => day.contains(les));
      List<Les> futureDay = day.skip(day.indexOf(les) + 1);

      notificationsPlugin.zonedSchedule(
        0,
        lesString(les),
        futureDay.isEmpty ? null : lesString(futureDay.first),
        tz.TZDateTime.from(lesNotificationTime(les), tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            '0',
            'Afspraken',
            'Meldingen voor lessen',
            importance: Importance.max,
            priority: Priority.defaultPriority,
            ticker: 'ticker',
            styleInformation: InboxStyleInformation(
              futureDay.map(lesString).toList(),
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

  String lesString(Les les) => "${les.startTime} - ${les.endTime}: ${les.getName()}" + (les.location == null ? "" : " - ${les.location}");
  DateTime lesNotificationTime(Les les) => les.startDateTime.subtract(Duration(minutes: userdata.get("preNotificationMinutes")));
}

Notifications notifications = Notifications();
