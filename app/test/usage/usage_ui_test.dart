// 魔改基线：匿名使用统计已剔除，首屏 welcome 页不再有「发送匿名使用统计」
// 告知行（UsageNoticeRow 已删除），也没有任何开关可打开它。这组测试锁住
// 这个决定：zh/en 都没有该行、窄屏大字体不溢出、看完首屏不落下任何
// usage 存储。welcome 页其余布局仍由金色基准守住：
//
//   flutter test --update-goldens test/usage/usage_ui_test.dart

import 'package:dsh_app/l10n/l10n.dart';
import 'package:dsh_app/ui/onboarding/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../shell/golden_harness.dart';
import '../support/english_preview.dart';

const _row = ValueKey('usage-notice');
const _switch = ValueKey('usage-notice-switch');

Future<void> _pumpWelcome(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  double scale = 1,
  bool english = false,
  Brightness brightness = Brightness.light,
}) async {
  if (english) useEnglish();
  tester.view.devicePixelRatio = 2;
  tester.view.physicalSize = size * 2;
  tester.view.padding = const FakeViewPadding(top: 32 * 2, bottom: 24 * 2);
  tester.view.viewPadding = const FakeViewPadding(top: 32 * 2, bottom: 24 * 2);
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  final page = WelcomePage(onStart: () {});
  await tester.pumpWidget(goldenApp(home: english ? inEnglish(page) : page, brightness: brightness));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

Future<Map<String, Object?>> _stored() async {
  final prefs = await SharedPreferences.getInstance();
  return {for (final k in prefs.getKeys()) k: prefs.get(k)};
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('welcome, in English (light)', (tester) async {
    await tester.runAsync(loadGoldenFonts);
    await _pumpWelcome(tester, english: true);
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/en_welcome_light.png'));
  });

  group('the welcome page has no usage row', () {
    for (final english in [false, true]) {
      testWidgets('no notice row, no switch, nothing stored (${english ? 'en' : 'zh'})', (tester) async {
        await tester.runAsync(loadGoldenFonts);
        await _pumpWelcome(tester, english: english);
        expect(find.byKey(_row), findsNothing);
        expect(find.byKey(_switch), findsNothing);
        // 文案键仍在（防误删），但不得出现在首屏。
        expect(find.text(appL10n.usageStatsTitle), findsNothing);
        expect(find.text(appL10n.usageNoticeBody), findsNothing);
        expect(tester.takeException(), isNull);
        // 首屏之后：不落下任何 usage 存储（provider 从未被触发计数）。
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
        await tester.pump();
        expect((await tester.runAsync(_stored))!.keys.where((k) => k.startsWith('usage_stats')), isEmpty);
      });
    }

    for (final (english, scale) in [(false, 1.3), (false, 2.0), (true, 1.3), (true, 2.0)]) {
      testWidgets('320 dp, ×$scale (${english ? 'en' : 'zh'}): nothing overflows or is cut', (tester) async {
        await tester.runAsync(loadGoldenFonts);
        await _pumpWelcome(tester, size: const Size(320, 640), scale: scale, english: english);
        expect(tester.takeException(), isNull);
        for (final paragraph in tester.allRenderObjects.whereType<RenderParagraph>()) {
          expect(paragraph.didExceedMaxLines, isFalse, reason: paragraph.text.toPlainText());
        }
      });
    }

    testWidgets('no switch for a screen reader either', (tester) async {
      final semantics = tester.ensureSemantics();
      await _pumpWelcome(tester);
      expect(find.bySemanticsLabel(appL10n.usageStatsTitle), findsNothing);
      expect(find.bySemanticsLabel(appL10n.usageNoticeBody), findsNothing);
      semantics.dispose();
    });
  });

  // 魔改：隐私页已删除，「设置 › 隐私与分享」测试组移除
}
