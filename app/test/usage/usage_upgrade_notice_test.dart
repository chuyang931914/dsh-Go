// 魔改：匿名使用统计已整体剔除 —— `UsageBuild.active` 恒为 false，
// `UsageStatsController._load()` 直接置 `enabled: false, noticed: true`。
// 因此「新增匿名使用统计」告知条在任何情况下都不会出现。
//
// 原金色基准（goldens/usage_notice_{light,dark}.png）与全部交互用例随功能作废，
// 这里只验证「永不显示」：无论统计开关曾被打开过、还是首启未连接。

import 'package:dsh_app/l10n/l10n.dart';
import 'package:dsh_app/runtime/runtime_bridge.dart';
import 'package:dsh_app/runtime/runtime_state.dart';
import 'package:dsh_app/state/settings_state.dart';
import 'package:dsh_app/ui/shell/root_gate.dart';
import 'package:dsh_app/ui/shell/usage_upgrade_notice.dart';
import 'package:dsh_app/ui/theme/theme.dart';
import 'package:dsh_app/usage/usage_net.dart';
import 'package:dsh_app/usage/usage_stats.dart';
import 'package:dsh_client/dsh_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../engine_settings/support.dart' as engine;
import '../shell/golden_harness.dart';
import 'support.dart';

const _notice = ValueKey('usage-upgrade-notice');

late FakeUsageHttp http;
late DateTime now;

List<Override> _overrides() => [
  ...usageOverrides(clock: () => now, http: http, onResumes: (_) {}),
  ...engine.engineOverrides(DshClient.withCarrier(engine.FakeSettingsHost())),
];

/// The home stand-in, under the notice as the root gate puts it.
Widget _home() => UsageUpgradeNotice(
  child: AppBackdrop(
    child: Scaffold(
      backgroundColor: Colors.transparent,
      body: Builder(builder: (context) => const SizedBox.expand()),
    ),
  ),
);

Future<void> _pumpHome(WidgetTester tester) async {
  usePhoneSurface(tester);
  await tester.pumpWidget(goldenApp(home: _home(), brightness: Brightness.light, overrides: _overrides()));
  await tester.pump();
}

void main() {
  setUp(() {
    http = FakeUsageHttp();
    now = DateTime(2026, 10, 30, 9);
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('统计关着：告知条不出现，不计数也不上报', (tester) async {
    expect(UsageBuild.active, isFalse);
    // 即使落盘里曾打开过统计，也不会再有告知条。
    SharedPreferences.setMockInitialValues({UsageStatsController.enabledKey: true});
    await _pumpHome(tester);
    await tester.pump(const Duration(seconds: 10));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byKey(_notice), findsNothing);
    expect(find.text(appL10n.usageUpgradeNotice), findsNothing);

    // 计数入口在 UsageBuild.active=false 处就返回：既不落盘也不发请求。
    final usage = ProviderScope.containerOf(tester.element(find.byType(MaterialApp))).read(usageStatsProvider.notifier);
    usage.count(UsageCount.turns);
    usage.count(UsageCount.share);
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump();
    final prefs = (await tester.runAsync(SharedPreferences.getInstance))!;
    expect(prefs.containsKey(UsageStatsController.daysKey), isFalse);
    expect(http.requests, isEmpty);
  });

  testWidgets('首启（未连接）同样不出现', (tester) async {
    usePhoneSurface(tester);
    await tester.pumpWidget(
      goldenApp(
        home: RootGate(home: _home()),
        brightness: Brightness.light,
        overrides: [
          ...usageOverrides(
            clock: () => now,
            http: http,
            onResumes: (_) {},
            runtime: const LocalRuntimeState(
              loaded: true,
              status: RuntimeStatus(phase: RuntimePhase.installed, installedVersion: 'r1', bundledVersion: 'r1'),
            ),
          ),
          settingsProvider.overrideWith(() => FakeSettings(const AppSettings(loaded: true))),
        ],
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 10));
    expect(find.byKey(_notice), findsNothing);
  });
}
