// 长按选字的工具栏：只留复制、全选、翻译和「⋯」里的分享/朗读/问AI。
//
// OEM 的文本选择菜单会把 AI 搜索、浏览器搜索、翻译、朗读、问问 DeepSeek 等
// 全部塞进一根长条；这里用自己的 SelectionArea.contextMenuBuilder 接管，
// 系统菜单就不出现了。翻译仍走系统翻译（ACTION_PROCESS_TEXT），和原来的
// 「翻译」是同一个东西，不新增模型调用。

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/l10n.dart';
import '../../common/app_sheet.dart';
import 'message_actions.dart' show copyMessage;

/// 选区工具栏要用的动作，由聊天页提供（问AI 要能写进输入框）。
@immutable
class SelectionActions {
  const SelectionActions({
    required this.onTranslate,
    required this.onShare,
    required this.onRead,
    this.onAsk,
  });

  final ValueChanged<String> onTranslate;
  final ValueChanged<String> onShare;
  final ValueChanged<String> onRead;

  /// 只读对话没有输入框：为 null 时「问AI」不出现。
  final ValueChanged<String>? onAsk;
}

/// 把聊天页的动作交给正文里的 SelectionArea。
class SelectionActionsScope extends InheritedWidget {
  const SelectionActionsScope({super.key, required this.actions, required super.child});

  final SelectionActions actions;

  static SelectionActions? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SelectionActionsScope>()?.actions;

  @override
  bool updateShouldNotify(SelectionActionsScope oldWidget) => !identical(actions, oldWidget.actions);
}

/// Android 系统翻译（PROCESS_TEXT）：优先 vivo 翻译，找不到就让系统选。
class SelectionTranslate {
  static const _channel = MethodChannel('dsh/selection');

  static Future<bool> open(String text) async {
    if (text.trim().isEmpty) return false;
    try {
      return await _channel.invokeMethod<bool>('translate', {'text': text}) ?? false;
    } on Object {
      return false;
    }
  }
}

/// 正文长按后出现的工具条。
class SelectionToolbar extends StatelessWidget {
  const SelectionToolbar({super.key, required this.region, required this.text, this.actions});

  final SelectableRegionState region;
  final String text;

  /// 由正文在作用域内捕获后传进来：工具栏画在 Overlay 上，
  /// 那个 context 已经不在 [SelectionActionsScope] 下面了。
  final SelectionActions? actions;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final actions = this.actions ?? SelectionActionsScope.maybeOf(context);
    final selected = text.trim();
    if (actions == null || selected.isEmpty) {
      // 没有聊天页作用域（例如独立的说明页）：至少别把 OEM 菜单带出来。
      return AdaptiveTextSelectionToolbar.buttonItems(
        anchors: region.contextMenuAnchors,
        buttonItems: [
          for (final item in region.contextMenuButtonItems)
            if (item.type == ContextMenuButtonType.copy || item.type == ContextMenuButtonType.selectAll) item,
        ],
      );
    }
    ContextMenuButtonItem? selectAll;
    for (final item in region.contextMenuButtonItems) {
      if (item.type == ContextMenuButtonType.selectAll) {
        selectAll = item;
        break;
      }
    }
    final items = <ContextMenuButtonItem>[
      ContextMenuButtonItem(
        label: l10n.commonCopy,
        onPressed: () {
          region.hideToolbar();
          copyMessage(context, selected);
        },
      ),
      if (selectAll != null)
        ContextMenuButtonItem(
          label: selectAll.label ?? l10n.chatSelectAll,
          onPressed: region.selectAll,
        ),
      ContextMenuButtonItem(
        label: l10n.chatTranslate,
        onPressed: () {
          region.hideToolbar();
          actions.onTranslate(selected);
        },
      ),
      ContextMenuButtonItem(
        label: '⋯',
        onPressed: () {
          region.hideToolbar();
          _more(context, selected, actions);
        },
      ),
    ];
    return AdaptiveTextSelectionToolbar.buttonItems(anchors: region.contextMenuAnchors, buttonItems: items);
  }

  Future<void> _more(BuildContext context, String text, SelectionActions actions) async {
    final l10n = context.l10n;
    await showAppSheet<void>(
      context,
      builder: (sheet) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.ios_share),
              title: Text(l10n.commonShare),
              onTap: () {
                Navigator.pop(sheet);
                actions.onShare(text);
              },
            ),
            ListTile(
              leading: const Icon(Icons.volume_up_outlined),
              title: Text(l10n.chatReadAloud),
              onTap: () {
                Navigator.pop(sheet);
                actions.onRead(text);
              },
            ),
            if (actions.onAsk case final ask?)
              ListTile(
                leading: const Icon(Icons.forum_outlined),
                title: Text(l10n.askAiTooltip),
                onTap: () {
                  Navigator.pop(sheet);
                  ask(text);
                },
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
