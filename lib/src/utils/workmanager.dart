import 'package:argo/src/utils/notifications.dart';
import 'package:workmanager/workmanager.dart';

enum Names { LessonNotifications }

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == Names.LessonNotifications.toString()) {
      await notifications.lessonNotifications();
    }
    return Future.value(true);
  });
}

void enableBackground() {
  Workmanager().initialize(callbackDispatcher);
  Workmanager().registerPeriodicTask(
    Names.LessonNotifications.toString(),
    Names.LessonNotifications.toString(),
    existingWorkPolicy: ExistingWorkPolicy.replace,
    frequency: Duration(minutes: 15),
  );
}
