import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class VibrateScreen extends StatefulWidget {
  const VibrateScreen({Key? key}) : super(key: key);

  @override
  State<VibrateScreen> createState() => _VibrateScreenState();
}

class _VibrateScreenState extends State<VibrateScreen> {
  late TextEditingController controller;

  final int pauseDuration = const Duration(milliseconds: 200).inMilliseconds;
  final int vibrateDuration = const Duration(milliseconds: 50).inMilliseconds;
  int amplitude = 1;
  @override
  void initState() {
    controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("vibrate"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: controller,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[. ]')),
              ],
              decoration: const InputDecoration(
                hintText: "pattern in dots (.. .... .)",
              ),
            ),
            const SizedBox(height: 16),
            Slider(
              value: amplitude.toDouble(),
              max: 255,
              min: 1,
              divisions: 254,
              label: amplitude.toString(),
              onChanged: (val) {
                amplitude = val.toInt();
                setState(() {});
              },
            ),
            ElevatedButton(
              onPressed: vibratePackage,
              child: const Text("start"),
            )
          ],
        ),
      ),
    );
  }

  List<int> vibratePattern() {
    List<String> chars = controller.text.split('');
    List<int> pattern = [];
    int pause = 0;
    int vibrate = 0;
    for (int i = 0; i < chars.length; i++) {
      /// found space after dot (pause after vibrate)
      if (chars[i] == ' ' && vibrate != 0) {
        pattern.addAll([pause * pauseDuration, vibrate * vibrateDuration]);
        vibrate = 0;
        pause = 1;
      } else if (chars[i] == ' ') {
        pause++;
      } else if (chars[i] == '.') {
        vibrate++;
      }

      if (i == chars.length - 1 && vibrate > 0) {
        pattern.addAll([pause * pauseDuration, vibrate * vibrateDuration]);
      }
    }

    return pattern;
  }

  void vibratePackage() async {
    await Vibration.cancel();
    print(await Vibration.hasVibrator());
    print(await Vibration.hasAmplitudeControl());
    print(await Vibration.hasCustomVibrationsSupport());
    if (await Vibration.hasCustomVibrationsSupport() == true) {
      List<int> pattern = vibratePattern();
      Vibration.vibrate(
        pattern: pattern,
        intensities: List.generate(
          pattern.length,
          (index) => index.isOdd ? 0 : amplitude,
        ),
      );
    }
  }
}
