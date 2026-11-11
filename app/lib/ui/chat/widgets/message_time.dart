// 消息时间戳：气泡外侧的一行小灰字，点一下切换“精简/完整”。
//
// 精简：今天 23:42 / 昨天 23:42 / 11月9日 23:42
// 完整：23:42:53 / 昨天 周一 23:42:53 / 11月9日 周一 23:42:53
//
// 日期只在每天第一条消息上出现（由列表算好 showDate），同一天后面只写时刻。
// 点击是全局的：点任意一条，整个当前聊天一起切换（由 ChatList 持有状态）。

import 'package:flutter/material.dart';
import 'dart:ui' show FontFeature;

import '../../../l10n/l10n.dart';

/// 两个时刻是不是同一个本地自然日。
bool sameChatDay(DateTime a, DateTime b) {
  final x = a.toLocal();
  final y = b.toLocal();
  return x.year == y.year && x.month == y.month && x.day == y.day;
}

String _two(int n) => n.toString().padLeft(2, '0');

String _clock(DateTime t, {required bool seconds}) =>
    '${_two(t.hour)}:${_two(t.minute)}${seconds ? ':${_two(t.second)}' : ''}';

const _zhWeek = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
const _enWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _enMonth = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/// 给 [time] 排一行时间文本。[now] 由调用方传入，方便测试。
String chatTimeLabel(
  DateTime time, {
  required DateTime now,
  required bool expanded,
  required bool showDate,
  required String yesterday,
  required bool chinese,
}) {
  final t = time.toLocal();
  final n = now.toLocal();
  final today = sameChatDay(t, n);
  final wasYesterday = sameChatDay(t, n.subtract(const Duration(days: 1)));
  final weekday = (chinese ? _zhWeek : _enWeek)[t.weekday - 1];
  final date = chinese
      ? (t.year == n.year ? '${t.month}月${t.day}日' : '${t.year}年${t.month}月${t.day}日')
      : (t.year == n.year ? '${_enMonth[t.month - 1]} ${t.day}' : '${_enMonth[t.month - 1]} ${t.day}, ${t.year}');

  if (expanded) {
    if (today) return _clock(t, seconds: true);
    if (wasYesterday) return '$yesterday $weekday ${_clock(t, seconds: true)}';
    return '$date $weekday ${_clock(t, seconds: true)}';
  }
  if (today) return _clock(t, seconds: false);
  final prefix = wasYesterday ? yesterday : date;
  return showDate ? '$prefix ${_clock(t, seconds: false)}' : _clock(t, seconds: false);
}

/// One message's time, aligned to the side its bubble sits on.
class MessageTime extends StatelessWidget {
  const MessageTime({
    super.key,
    required this.time,
    required this.expanded,
    required this.showDate,
    this.onTap,
    this.alignEnd = false,
  });

  final DateTime time;
  final bool expanded;
  final bool showDate;
  final VoidCallback? onTap;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final chinese = Localizations.localeOf(context).languageCode == 'zh';
    final label = chatTimeLabel(
      time,
      now: DateTime.now(),
      expanded: expanded,
      showDate: showDate,
      yesterday: l10n.commonYesterday,
      chinese: chinese,
    );
    final style = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.62),
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final text = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Text(label, style: style),
    );
    return Align(
      alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
      child: Semantics(
        button: onTap != null,
        label: label,
        child: onTap == null
            ? text
            : GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTap,
                child: text,
              ),
      ),
    );
  }
}
