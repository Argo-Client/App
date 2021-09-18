import 'package:flutter/material.dart';

ValueNotifier<bool> updateNotifier = ValueNotifier(false);

void update() => updateNotifier.value = !updateNotifier.value;
