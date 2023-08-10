import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:klimb/features/home/home_view.dart';
import 'package:klimb/notifiers/selected_profile_notifier.dart';

void main() async {
  await Hive.initFlutter();

  await Hive.openBox("profiles");

  await Hive.openBox("selected");

  runApp(const ProviderScope(child: Main()));
}

class Main extends ConsumerWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final color =
        int.tryParse(ref.watch(selectedProfileProvider)["color"]) ?? 0;
    final themeMode = ref.watch(selectedProfileProvider)["themeMode"];
    return MaterialApp(
      title: 'KLimbB',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(color),
          brightness: themeMode == "Light" ? Brightness.light : Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeView(),
    );
  }
}
