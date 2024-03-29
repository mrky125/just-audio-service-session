import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'app_lifecycle_observer.dart';
import 'audio/audio_controller.dart';
import 'audio/audio_listener.dart';
import 'audio/audio_state_notifier.dart';
import 'audio/ui/audio_progress.dart';
import 'audio/ui/control_buttons.dart';
import 'service_locator.dart';

void main() async {
  await initServiceLocator();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _listenAppLifecycleState(ref);
    ref
        .read(audioListenerProvider)
        .startListen(); // initialize and listen stream
    final state = ref.watch(playbackStateProvider).processingState;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 300,
              child: Image.network(
                '${ref.watch(mediaItemProvider)?.artUri}',
                width: 300,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                ref.watch(mediaItemProvider)?.album ?? 'no album',
                style: Theme.of(context).textTheme.titleMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                ref.watch(mediaItemProvider)?.title ?? 'no song',
                style: Theme.of(context).textTheme.headlineSmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: AudioProgress(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: ControlButtons(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (state == AudioProcessingState.idle) {
            ref.read(audioControllerProvider).setInitialItems();
          } else {
            ref.read(audioControllerProvider).stopAndRemoveAll();
          }
        },
        child: state == AudioProcessingState.idle
            ? const Icon(Icons.add)
            : const Icon(Icons.delete),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  /// [appLifecycleProvider]を通してアプリのライフサイクルを監視
  void _listenAppLifecycleState(WidgetRef ref) {
    ref.listen(appLifecycleProvider, (previous, next) async {
      switch (next) {
        case AppLifecycleState.detached:
          // アプリ終了したら、音声再生を停止し再生状態の監視を止める
          ref.read(audioControllerProvider).dispose();
          break;
        default:
          break;
      }
    });
  }
}
