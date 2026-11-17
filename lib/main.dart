import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'data/local_store.dart';
import 'data/notification_service.dart';
import 'presentation/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final store = await LocalStore.open();
    final notifications = NotificationService();
    await notifications.init();
    runApp(ProviderScope(overrides: [storeProvider.overrideWithValue(store),
      notificationProvider.overrideWithValue(notifications)], child: const GorselAraApp()));
  } catch (_) {
    runApp(MaterialApp(home: Scaffold(body: Center(child: Padding(padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.storage, size: 48), const SizedBox(height: 16),
        const Text('Yerel veriler açılamadı. Depolama alanını kontrol edip yeniden deneyin.\n\nCould not open local data. Check device storage and retry.', textAlign: TextAlign.center),
        const SizedBox(height: 16), FilledButton(onPressed: main, child: const Text('Yeniden dene / Retry')),
      ]))))));
  }
}
