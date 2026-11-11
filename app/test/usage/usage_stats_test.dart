// 魔改基线：本版本不做匿名使用统计 —— UsageBuild.active 恒为 false
//（lib/usage/usage_net.dart），加载后开关恒为关闭（lib/usage/usage_stats.dart
// 的 _load）。这组测试锁住这个决定：不计数、不落盘、不发送；旧版本留下的
// 账本不会再发出去；即使开关被重新打开，也不会有任何一个请求。
// 若将来有人误把上报打开，这里应当第一个红。

import 'package:dsh_app/phone/phone_channel.dart';
import 'package:dsh_app/usage/usage_ledger.dart';
import 'package:dsh_app/usage/usage_net.dart';
import 'package:dsh_app/usage/usage_stats.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support.dart';

late FakeUsageHttp http;
late DateTime now;

Future<void> settle() async {
  for (var i = 0; i < 30; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

Future<ProviderContainer> start({Map<String, Object> prefs = const {}}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final container = ProviderContainer(overrides: usageOverrides(clock: () => now, http: http, onResumes: (_) {}));
  addTearDown(container.dispose);
  container.read(usageStatsProvider);
  await settle();
  return container;
}

extension on ProviderContainer {
  UsageStatsController get usage => read(usageStatsProvider.notifier);
}

Future<Map<String, Object?>> stored() async {
  final prefs = await SharedPreferences.getInstance();
  return {for (final k in prefs.getKeys()) k: prefs.get(k)};
}

/// Usage data keys that must never be written by this build. The switch keys
/// ([UsageStatsController.enabledKey] / [UsageStatsController.noticedKey])
/// are not usage data: setEnabled/markNoticed may still write them.
const dataKeys = [
  UsageStatsController.daysKey,
  UsageStatsController.iidKey,
  UsageStatsController.iidSinceKey,
  UsageStatsController.failedAtKey,
  UsageStatsController.closedDayKey,
];

void expectNoUsageData(Map<String, Object?> prefs) {
  for (final key in dataKeys) {
    expect(prefs.containsKey(key), isFalse, reason: key);
  }
}

void main() {
  setUp(() {
    http = FakeUsageHttp();
    now = DateTime(2026, 10, 28, 9);
  });

  test('this build never counts or reports: UsageBuild.active is false', () {
    // 产品决策：本版本关闭匿名使用统计。锁住它，防止将来误开。
    expect(UsageBuild.active, isFalse);
  });

  test('a fresh install counts nothing, stores nothing, sends nothing', () async {
    final c = await start();

    for (var d = 28; d <= 31; d++) {
      now = DateTime(2026, 10, d, 9);
      for (final count in UsageCount.values) {
        c.usage.count(count);
      }
      c.usage.plugins(3);
      await c.usage.foreground();
      await c.usage.send();
      await settle();
    }
    expect(http.requests, isEmpty);
    expect(http.urls, isEmpty);
    final prefs = await stored();
    expectNoUsageData(prefs);
    expect(prefs, isEmpty, reason: '从未落盘任何 usage 键');

    // 冷启动再来一遍：依旧安静。
    final again = await start();
    now = DateTime(2026, 11, 2, 9);
    await again.usage.foreground();
    await settle();
    expect(http.requests, isEmpty);
    expect(await stored(), isEmpty);
  });

  test('a leftover ledger from an older build is never sent', () async {
    final ledger = UsageLedger()
      ..count(UsageCount.share, DateTime(2026, 10, 26, 9))
      ..count(UsageCount.turns, DateTime(2026, 10, 27, 9));
    final initial = <String, Object>{
      UsageStatsController.enabledKey: true,
      UsageStatsController.noticedKey: true,
      UsageStatsController.daysKey: ledger.encode(),
      UsageStatsController.iidKey: 'leftover-iid',
    };
    final c = await start(prefs: initial);
    await c.usage.foreground();
    await c.usage.send();
    now = DateTime(2026, 10, 29, 9);
    await c.usage.foreground();
    await settle();
    expect(http.requests, isEmpty);
    // 本版本不主动清旧数据，但也绝不读它、发它、改它。
    expect((await stored()).keys, unorderedEquals(initial.keys));
  });

  test('even switched back on, nothing is counted or sent', () async {
    final c = await start();
    await c.usage.setEnabled(true);
    await c.usage.markNoticed();
    for (var d = 28; d <= 30; d++) {
      now = DateTime(2026, 10, d, 12);
      c.usage.count(UsageCount.turns);
      c.usage.count(UsageCount.voice);
      await c.usage.foreground();
      await c.usage.send();
      await settle();
    }
    expect(http.requests, isEmpty);
    expectNoUsageData(await stored());

    // 冷启动后依旧安静（落盘的开关状态不会被读，也不会有任何数据键）。
    final again = await start(prefs: Map<String, Object>.from(await stored()));
    now = DateTime(2026, 11, 2, 9);
    again.usage.count(UsageCount.gen);
    await again.usage.foreground();
    await settle();
    expect(http.requests, isEmpty);
    expectNoUsageData(await stored());
  });

  test('phoneTaskStarted: a new number or active again', () {
    const idle = PhoneTaskStatus();
    expect(phoneTaskStarted(idle, const PhoneTaskStatus(active: true)), isTrue);
    expect(phoneTaskStarted(const PhoneTaskStatus(active: true), const PhoneTaskStatus(active: true)), isFalse);
    expect(
      phoneTaskStarted(const PhoneTaskStatus(id: 1, active: true), const PhoneTaskStatus(id: 2, active: true)),
      isTrue,
    );
    expect(phoneTaskStarted(const PhoneTaskStatus(id: 1, active: true), const PhoneTaskStatus(id: 1)), isFalse);
  });
}
