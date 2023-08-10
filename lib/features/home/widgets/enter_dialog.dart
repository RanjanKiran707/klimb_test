import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:klimb/keys.dart';
import 'package:klimb/notifiers/selected_profile_notifier.dart';

final dialogIndexProvider = StateProvider.autoDispose<int>((ref) => 0);

class EnterDialog extends ConsumerWidget {
  EnterDialog({super.key});

  final latCtrl = TextEditingController();
  final longCtrl = TextEditingController();

  final colorCtrl = TextEditingController();

  String? themeMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(dialogIndexProvider);
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: const Text("Enter New Location"),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageTransitionSwitcher(
              transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
                return SharedAxisTransition(
                  animation: primaryAnimation,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType.horizontal,
                  child: child,
                );
              },
              child: [
                Padding(
                  key: const ValueKey(0),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: latCtrl,
                        inputFormatters: [
                          IntegerInputFormatter(),
                        ],
                        decoration:
                            const InputDecoration(labelText: "Enter Latitude"),
                      ),
                      TextFormField(
                        controller: longCtrl,
                        inputFormatters: [
                          IntegerInputFormatter(),
                        ],
                        decoration:
                            const InputDecoration(labelText: "Enter Longitude"),
                      ),
                    ],
                  ),
                ),
                Padding(
                  key: const ValueKey(1),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: colorCtrl,
                        onTap: () => openColorPicker(context, colorCtrl),
                        decoration: const InputDecoration(
                            labelText: "Enter Color in hex"),
                      ),
                      DropdownButtonFormField(
                        hint: const Text("Enter Theme (Light/Dark)"),
                        items: const [
                          DropdownMenuItem(
                            value: "Dark",
                            child: Text("Dark"),
                          ),
                          DropdownMenuItem(
                            value: "Light",
                            child: Text("Light"),
                          ),
                        ],
                        onChanged: (value) {
                          themeMode = value;
                        },
                      )
                    ],
                  ),
                ),
              ][index],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.maxFinite, 60),
                padding: const EdgeInsets.all(15),
              ),
              onPressed: () {
                if (index == 0) {
                  int lat = int.tryParse(latCtrl.text) ?? 1000;
                  int long = int.tryParse(longCtrl.text) ?? 1000;

                  if (lat < -90 || lat > 90) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Latitude must be between -90 and 90"),
                      showCloseIcon: true,
                    ));
                    return;
                  }
                  if (long < -180 || long > 180) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Longitude must be between -180 and 180"),
                        showCloseIcon: true));
                    return;
                  }

                  final values = Hive.box(Keys.profiles).values;

                  if (values.any((element) =>
                      element["lat"] == latCtrl.text &&
                      element["long"] == longCtrl.text)) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Location already exists"),
                        showCloseIcon: true));
                    return;
                  }
                  ref.read(dialogIndexProvider.notifier).state = 1;
                } else {
                  if (themeMode == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Please select a theme mode"),
                      showCloseIcon: true,
                    ));
                    return;
                  }
                  if (colorCtrl.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Please select a color"),
                      showCloseIcon: true,
                    ));
                    return;
                  }
                  Hive.box(Keys.profiles).add({
                    "lat": latCtrl.text,
                    "long": longCtrl.text,
                    "color": colorCtrl.text,
                    "themeMode": themeMode,
                  });
                  ref.read(selectedProfileProvider.notifier).refresh();
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Proceed"),
            ),
          ),
        ],
      ),
    );
  }

  void openColorPicker(BuildContext context, TextEditingController colorCtrl) {
    // create some values
    Color pickerColor = const Color(0xff443a49);

    showDialog(
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        void changeColor(Color color) {
          setState(() => pickerColor = color);
          colorCtrl.text = color.value.toString();
        }

        return AlertDialog(
          title: const Text('Pick a color!'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: changeColor,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Got it'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      }),
      context: context,
    );
  }
}

class IntegerInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Allow only digits and a single leading minus sign
    if (newValue.text == '-' || newValue.text.isEmpty) {
      return newValue;
    }

    // Parse the new value as an integer
    try {
      int parsed = int.parse(newValue.text);
      return TextEditingValue(
        text: parsed.toString(),
        selection: TextSelection.collapsed(offset: parsed.toString().length),
      );
    } catch (e) {
      // Return the oldValue if parsing fails
      return oldValue;
    }
  }
}
