// 魔改基线：匿名使用统计已剔除（UsageBuild.active 恒为 false）。端到端用
// 真实 loopback HTTP 服务器锁住这个决定：整条链路全程安静，服务器什么也
// 收不到 —— 即使本地留有旧开关状态、即使开关被重新打开。另保留一条网络
// 层契约：永不应答的服务器会被按时放弃。

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dsh_app/phone/phone_channel.dart';
import 'package:dsh_app/runtime/runtime_bridge.dart';
import 'package:dsh_app/runtime/runtime_state.dart';
import 'package:dsh_app/state/phone_state.dart' show phoneChannelProvider;
import 'package:dsh_app/usage/usage_ledger.dart';
import 'package:dsh_app/usage/usage_net.dart';
import 'package:dsh_app/usage/usage_stats.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../shell/golden_harness.dart' show FakeRuntime;

class _NoPhone extends PhoneChannel {
  @override
  Future<PhoneStatus> status() async => const PhoneStatus.notReady();
}

void main() {
  late HttpServer server;
  late List<String> received;
  late DateTime now;

  setUp(() async {
    received = [];
    now = DateTime(2026, 10, 28, 9);
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      received.add('${request.method} ${request.uri.path}');
      request.response.statusCode = 204;
      await request.response.close();
    });
  });

  tearDown(() async {
    await server.close(force: true);
  });

  Future<void> settle([int ms = 0]) async {
    // Real sockets: wait in real time until the server could have answered.
    for (var i = 0; i < 40; i++) {
      await Future<void>.delayed(Duration(milliseconds: ms == 0 ? 5 : ms));
    }
  }

  Future<ProviderContainer> start(Map<String, Object> prefs) async {
    SharedPreferences.setMockInitialValues(prefs);
    final container = ProviderContainer(
      overrides: [
        usageClockProvider.overrideWithValue(() => now),
        usageEndpointProvider.overrideWithValue(Uri.parse('http://127.0.0.1:${server.port}/api/usage/v1')),
        usageDeviceProvider.overrideWithValue(
          () async => const UsageDevice(app: '0.9.9', build: 10301000, sdk: 34, abi: 'arm64-v8a', maker: 'vivo'),
        ),
        usageLanguageProvider.overrideWithValue(() => 'en'),
        localRuntimeProvider.overrideWith(
          () => FakeRuntime(
            const LocalRuntimeState(
              loaded: true,
              status: RuntimeStatus(phase: RuntimePhase.running, currentExecutionMode: 'proot'),
            ),
          ),
        ),
        phoneChannelProvider.overrideWithValue(_NoPhone()),
      ],
    );
    addTearDown(container.dispose);
    container.read(usageStatsProvider);
    await settle();
    return container;
  }

  test('the whole chain stays silent: the server hears nothing, ever', () async {
    final c = await start({
      UsageStatsController.enabledKey: true,
      UsageStatsController.noticedKey: true,
    });
    final usage = c.read(usageStatsProvider.notifier);
    usage
      ..count(UsageCount.turns)
      ..count(UsageCount.phone)
      ..plugins(1);
    for (var d = 29; d <= 31; d++) {
      now = DateTime(2026, 10, d, 9);
      await usage.foreground();
      await usage.send();
      await settle();
    }
    // 即使开关被重新打开，本版本也不会发（UsageBuild.active 恒 false）。
    await usage.setEnabled(true);
    await usage.markNoticed();
    usage.count(UsageCount.share);
    now = DateTime(2026, 11, 1, 9);
    await usage.foreground();
    await usage.send();
    await settle();
    expect(received, isEmpty, reason: '本版本不发送任何匿名使用统计');
    expect(UsageBuild.active, isFalse);
  });

  test('a server that never answers is given up on in time, quietly', () async {
    final silent = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final sockets = <Socket>[];
    silent.listen(sockets.add);
    addTearDown(() async {
      for (final s in sockets) {
        s.destroy();
      }
      await silent.close();
    });
    final watch = Stopwatch()..start();
    await expectLater(
      const IoUsageHttp().post(
        Uri.parse('http://127.0.0.1:${silent.port}/api/usage/v1'),
        '{}',
        timeout: const Duration(milliseconds: 300),
      ),
      throwsA(isA<TimeoutException>()),
    );
    expect(watch.elapsed, lessThan(const Duration(seconds: 3)));
  });
}
