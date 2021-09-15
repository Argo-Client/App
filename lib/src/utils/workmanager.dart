import 'package:workmanager/workmanager.dart';

import 'package:argo/src/utils/notifications.dart';

enum Tasks { LessonNotifications }

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("Running background job: $task");
    if (task == Tasks.LessonNotifications.toString()) {
      await notifications.initialize();
      await notifications.lessonNotifications();
    }
    return Future.value(true);
  });
}

void enableBackground() async {
  await Workmanager().initialize(callbackDispatcher);
  Workmanager().registerPeriodicTask(
    Tasks.LessonNotifications.toString(),
    Tasks.LessonNotifications.toString(),
    frequency: Duration(minutes: 15),
  );
}
