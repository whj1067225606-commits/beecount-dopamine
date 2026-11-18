import 'package:flutter/services.dart';
import 'package:quick_actions/quick_actions.dart';

typedef ShortcutOpenCallback = void Function(String type);

class ShortcutService {
  ShortcutService();

  static const _channel = MethodChannel('inspiration_spark/shortcuts');
  final QuickActions _quickActions = const QuickActions();

  Future<void> setupQuickActions(ShortcutOpenCallback onOpen) async {
    await _quickActions.initialize((shortcutType) {
      onOpen(shortcutType);
    });
    await _quickActions.setShortcutItems(const <ShortcutItem>[
      ShortcutItem(
        type: 'inspiration',
        localizedTitle: '写灵感',
        icon: 'ic_launcher',
      ),
      ShortcutItem(
        type: 'notes',
        localizedTitle: '写记事',
        icon: 'ic_launcher',
      ),
    ]);
  }

  /// Ask the launcher to pin a home-screen shortcut.
  Future<bool> pinHomeShortcut({String type = 'home'}) async {
    try {
      final result = await _channel.invokeMethod<bool>('pinShortcut', {
        'type': type,
      });
      return result ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}
