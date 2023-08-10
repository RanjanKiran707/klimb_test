import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:klimb/features/home/widgets/enter_dialog.dart';
import 'package:klimb/keys.dart';
import 'package:klimb/notifiers/selected_profile_notifier.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final selected = ref.watch(selectedProfileProvider);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Home View"),
          elevation: 1,
        ),
        body: ValueListenableBuilder(
          valueListenable: Hive.box(Keys.profiles).listenable(),
          builder: (context, value, child) {
            final list = value.values.toList();

            if (list.isEmpty) {
              return const Center(
                child: Text("Nothing here, Empty"),
              );
            }
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                final profile = list[index];
                return Dismissible(
                  background: Container(color: Colors.red),
                  key: ValueKey(profile),
                  onDismissed: (direction) {
                    value.deleteAt(index);
                    // ref.read(selectedProfileProvider.notifier).refresh();
                  },
                  child: RadioListTile(
                    controlAffinity: ListTileControlAffinity.trailing,
                    title: Text(
                        "Latitude ${profile["lat"]} and Longitude ${profile["long"]}"),
                    subtitle: Text(profile["themeMode"]),
                    value: profile,
                    groupValue: selected,
                    onChanged: (value) {
                      ref
                          .read(selectedProfileProvider.notifier)
                          .setNew(profile);
                    },
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: const Text("Add new Location"),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return EnterDialog();
                },
                fullscreenDialog: true,
              ),
            );
          },
        ),
      ),
    );
  }
}
