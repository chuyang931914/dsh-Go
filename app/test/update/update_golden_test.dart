// The update sheet's behaviour and the launch check, over a bare home.
//
// 魔改：自动更新已整体剔除 —— 关于页不再有「检查更新」「自动更新」两行，
// `Spots.updateCheck/updateAuto` 与 `AppUpdateTiles` 已删除，因此原来的
// 「关于」分组金色基准与手工检查/自动检查开关用例一并移除；这里直接打开
// 更新面板，只保留仍存在代码的行为验证。

import 'dart:async';
import 'dart:convert';

import 'package:dsh_app/runtime/runtime_state.dart';
import 'package:dsh_app/state/settings_state.dart';
import 'package:dsh_app/state/star_prompt.dart';
import 'package:dsh_app/state/update_state.dart';
import 'package:dsh_app/ui/update/update_launch_check.dart';
import 'package:dsh_app/ui/update/update_sheet.dart';
import 'package:dsh_app/update/release.dart';
import 'package:dsh_app/update/version.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../shell/golden_harness.dart';
import 'support.dart';

/// Fixed state; records what the sheet asked for.
class FakeUpdate extends AppUpdateController {
  FakeUpdate(this.initial, {this.checkResult = UpdateCheckPhase.upToDate});

  final AppUpdateState initial;
  final UpdateCheckPhase checkResult;
  final calls = <String>[];

  @override
  AppUpdateState build() => initial;

  @override
  Future<void> get ready async {}

  @override
  Future<UpdateCheckPhase> check() async {
    calls.add('check');
    state = state.copyWith(check: checkResult);
    return checkResult;
  }

  @override
  Future<void> startDownload() async {
    calls.add('startDownload');
    state = state.copyWith(task: UpdateTaskPhase.downloading, received: 0, total: () => state.asset?.size);
  }

  @override
  void cancelDownload() {
    calls.add('cancelDownload');
    state = state.copyWith(task: UpdateTaskPhase.idle);
  }

  @override
  Future<void> skipLatest() async {
    calls.add('skipLatest');
    state = state.copyWith(skippedVersion: () => state.latest?.version.toString());
  }

  /// What [autoCheckIfDue] answers.
  bool offer = false;

  @override
  Future<bool> autoCheckIfDue() async {
    calls.add('autoCheckIfDue');
    return offer;
  }

  @override
  Future<void> onAppResumed({Duration confirmGrace = Duration.zero}) async => calls.add('resumed');

  /// What [installWithSystem] answers.
  bool systemInstallerOpens = true;

  @override
  Future<bool> installWithSystem() async {
    calls.add('installWithSystem');
    return systemInstallerOpens;
  }

  @override
  Future<void> setAutoCheck(bool value) async {
    calls.add('autoCheck:$value');
    state = state.copyWith(autoCheck: value);
  }
}

final _release = parseGithubRelease(jsonDecode(fixture('github_release.json')));

AppUpdateState _offer({
  UpdateTaskPhase task = UpdateTaskPhase.idle,
  int received = 0,
  String? source,
  UpdateProblem? problem,
}) => AppUpdateState(
  loaded: true,
  current: AppVersion.tryParse('1.0.0+1')!,
  flavor: ApkFlavor.arm64,
  check: UpdateCheckPhase.available,
  latest: _release,
  task: task,
  received: received,
  total: _release.apkFor(ApkFlavor.arm64)!.size,
  source: source,
  problem: problem,
);

List<Override> _overrides(FakeUpdate update) => [
  localRuntimeProvider.overrideWith(() => FakeRuntime(const LocalRuntimeState(loaded: true, status: runningStatus))),
  settingsProvider.overrideWith(() => FakeSettings(const AppSettings(loaded: true))),
  appUpdateProvider.overrideWith(() => update),
];

/// A bare home; the sheet is opened from it directly.
class _Home extends StatelessWidget {
  const _Home();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Builder(
        builder: (context) => TextButton(
          onPressed: () => unawaited(showUpdateSheet(context)),
          child: const Text('打开更新面板'),
        ),
      ),
    ),
  );
}

Future<void> _openSheet(WidgetTester tester) async {
  await tester.tap(find.text('打开更新面板'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  group('behaviour', () {
    Future<FakeUpdate> pump(WidgetTester tester, FakeUpdate update) async {
      usePhoneSurface(tester);
      await tester.pumpWidget(goldenApp(home: const _Home(), brightness: Brightness.light, overrides: _overrides(update)));
      await tester.pump();
      return update;
    }

    testWidgets('立即更新 starts the download; 取消下载 stops it', (tester) async {
      final update = await pump(tester, FakeUpdate(_offer()));
      await _openSheet(tester);
      expect(find.text('发现新版本'), findsOneWidget);
      expect(find.text('DSH 1.2.0'), findsOneWidget);
      expect(find.textContaining('171.8 MB'), findsOneWidget);
      expect(find.byKey(const ValueKey('update-star')), findsNothing);
      await tester.tap(find.text('立即更新'));
      await tester.pump();
      expect(update.calls, ['startDownload']);
      expect(find.text('正在下载 0%'), findsOneWidget);
      await tester.tap(find.text('取消下载'));
      await tester.pump();
      expect(update.calls, ['startDownload', 'cancelDownload']);
      expect(find.text('立即更新'), findsOneWidget);
    });

    testWidgets('public builds ask for a star too: 去 Star opens the project, then the button goes', (tester) async {
      final opened = <Uri>[];
      final update = FakeUpdate(_offer());
      usePhoneSurface(tester);
      await tester.pumpWidget(
        goldenApp(
          home: const _Home(),
          brightness: Brightness.light,
          overrides: [
            ..._overrides(update),
            starPromptGateProvider.overrideWithValue(true),
            starPromptStoreProvider.overrideWithValue(_StarStore()),
            starLinkOpenerProvider.overrideWithValue((uri) async {
              opened.add(uri);
              return true;
            }),
          ],
        ),
      );
      await tester.pump();
      await _openSheet(tester);
      expect(find.text('去 Star'), findsOneWidget);
      expect(find.text('稍后'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('update-star')));
      await tester.pump();
      expect(opened, [starProjectPage]);
      expect(find.byKey(const ValueKey('update-star')), findsNothing);
      await tester.tap(find.text('立即更新'));
      await tester.pump();
      expect(update.calls, ['startDownload']);
    });

    testWidgets('跳过这个版本 records the skip and closes the sheet', (tester) async {
      final update = await pump(tester, FakeUpdate(_offer()));
      await _openSheet(tester);
      await tester.tap(find.text('跳过这个版本'));
      await tester.pumpAndSettle();
      expect(update.calls, ['skipLatest']);
      expect(find.text('发现新版本'), findsNothing);
    });

    testWidgets('an unconfirmed install keeps neutral wording and the system installer', (tester) async {
      final update = await pump(
        tester,
        FakeUpdate(_offer(task: UpdateTaskPhase.ready, problem: UpdateProblem.installUnconfirmed)),
      );
      await _openSheet(tester);
      expect(find.text('尚未确认安装结果'), findsOneWidget);
      expect(find.text('已取消安装'), findsNothing);
      await tester.tap(find.text('用系统安装器安装'));
      await tester.pump();
      expect(update.calls, ['installWithSystem']);
    });

    testWidgets('a stopped or failed install offers the system installer', (tester) async {
      final update = await pump(
        tester,
        FakeUpdate(_offer(task: UpdateTaskPhase.ready, problem: UpdateProblem.installCancelled)),
      );
      await _openSheet(tester);
      expect(find.text('已取消安装'), findsOneWidget);
      await tester.tap(find.text('用系统安装器安装'));
      await tester.pump();
      expect(update.calls, ['installWithSystem']);
      update.systemInstallerOpens = false;
      await tester.tap(find.text('用系统安装器安装'));
      await tester.pump();
      expect(find.text('没能打开系统安装器'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await pump(tester, FakeUpdate(_offer(task: UpdateTaskPhase.failed, problem: UpdateProblem.installFailed)));
      await _openSheet(tester);
      expect(find.text('用系统安装器安装'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await pump(tester, FakeUpdate(_offer(task: UpdateTaskPhase.ready)));
      await _openSheet(tester);
      expect(find.text('用系统安装器安装'), findsNothing);
    });

    testWidgets('signature mismatch offers the release page, not a retry', (tester) async {
      await pump(tester, FakeUpdate(_offer(task: UpdateTaskPhase.failed, problem: UpdateProblem.signature)));
      await _openSheet(tester);
      expect(find.text('签名不一致，不能直接覆盖'), findsOneWidget);
      expect(find.text('打开发布页'), findsOneWidget);
      expect(find.text('重试'), findsNothing);
    });
  });

  group('launch check', () {
    Future<FakeUpdate> mount(WidgetTester tester, {bool keyboard = false}) async {
      final update = FakeUpdate(_offer())..offer = true;
      usePhoneSurface(tester);
      if (keyboard) tester.view.viewInsets = const FakeViewPadding(bottom: 300 * 2);
      await tester.pumpWidget(
        goldenApp(
          home: const Scaffold(body: UpdateLaunchCheck(delay: Duration(seconds: 2))),
          brightness: Brightness.light,
          overrides: _overrides(update),
        ),
      );
      return update;
    }

    testWidgets('offers the sheet once the delay has passed', (tester) async {
      final update = await mount(tester);
      await tester.pump(const Duration(seconds: 1));
      expect(update.calls, isEmpty);
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 600));
      expect(update.calls, ['autoCheckIfDue']);
      expect(find.text('发现新版本'), findsOneWidget);
    });

    testWidgets('does not interrupt typing', (tester) async {
      final update = await mount(tester, keyboard: true);
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 600));
      expect(update.calls, ['autoCheckIfDue']);
      expect(find.text('发现新版本'), findsNothing);
    });

    testWidgets('coming back to the app tells the controller', (tester) async {
      final update = await mount(tester);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(update.calls, contains('resumed'));
    });
  });
}

class _StarStore implements StarPromptStore {
  StarPromptRecord? record;

  @override
  Future<StarPromptRecord?> read() async => record;

  @override
  Future<void> write(StarPromptRecord r) async => record = r;
}
