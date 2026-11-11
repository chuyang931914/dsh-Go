import 'package:dsh_app/ui/chat/widgets/message_time.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 11, 11, 23, 59, 30);
  String label(DateTime time, {bool expanded = false, bool showDate = true}) => chatTimeLabel(
    time,
    now: now,
    expanded: expanded,
    showDate: showDate,
    yesterday: '昨天',
    chinese: true,
  );

  test('today keeps the clock; expanded adds seconds', () {
    final time = DateTime(2026, 11, 11, 23, 42, 53);
    expect(label(time), '23:42');
    expect(label(time, expanded: true), '23:42:53');
    expect(label(time, showDate: false), '23:42');
  });

  test('yesterday names the day; expanded adds weekday and seconds', () {
    final time = DateTime(2026, 11, 10, 23, 42, 53);
    expect(label(time), '昨天 23:42');
    expect(label(time, expanded: true), '昨天 周二 23:42:53');
    expect(label(time, showDate: false), '23:42');
  });

  test('older dates keep month/day; expanded adds weekday and seconds', () {
    final time = DateTime(2026, 11, 9, 23, 42, 53);
    expect(label(time), '11月9日 23:42');
    expect(label(time, expanded: true), '11月9日 周一 23:42:53');
    expect(label(time, showDate: false), '23:42');
  });

  test('a different year shows the year', () {
    final time = DateTime(2025, 12, 31, 8, 5, 7);
    expect(label(time), '2025年12月31日 08:05');
    expect(label(time, expanded: true), '2025年12月31日 周三 08:05:07');
  });

  test('English labels follow the locale', () {
    final time = DateTime(2026, 11, 10, 23, 42, 53);
    expect(
      chatTimeLabel(time, now: now, expanded: false, showDate: true, yesterday: 'Yesterday', chinese: false),
      'Yesterday 23:42',
    );
    expect(
      chatTimeLabel(time, now: now, expanded: true, showDate: true, yesterday: 'Yesterday', chinese: false),
      'Yesterday Tue 23:42:53',
    );
  });
}
