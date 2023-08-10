import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:klimb/keys.dart';

class SelectedProfileNotifier extends Notifier<Map> {
  @override
  Map build() {
    final box = Hive.box(Keys.profiles);

    return box.values.toList()[0];
  }

  setNew(Map value) {
    state = value;
  }

  refresh() {
    final box = Hive.box(Keys.profiles);

    return box.values.toList()[0];
  }
}

final selectedProfileProvider =
    NotifierProvider<SelectedProfileNotifier, Map>(() {
  return SelectedProfileNotifier();
});
