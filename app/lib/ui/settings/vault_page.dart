// 设置 → 密钥保险箱：录入 / 解锁 / 清除归档私钥。
// 私钥从不落普通存储；解锁后写一个 5 分钟临时文件给引擎解密归档。

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../service/vault_service.dart';
import '../../share_code/guest_fs.dart';
import '../common/brief_notice.dart';
import '../providers/provider_widgets.dart' show FormFieldGroup;
import '../shell/page_frame.dart';
import '../theme/theme.dart';

class VaultPage extends ConsumerStatefulWidget {
  const VaultPage({super.key});

  @override
  ConsumerState<VaultPage> createState() => _VaultPageState();
}

class _VaultPageState extends ConsumerState<VaultPage> {
  final _key = TextEditingController();
  bool _enrolled = false;
  bool _busy = false;
  bool _hardwareBacked = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_refresh());
    unawaited(_harden());
  }

  /// 打开页面就禁止截屏，并读一次环境事实（是否硬件密钥）。
  Future<void> _harden() async {
    final service = ref.read(vaultServiceProvider);
    await service.secure(true);
    final info = await service.security();
    if (mounted) setState(() => _hardwareBacked = info['hardwareBacked'] == true);
  }

  Future<void> _refresh() async {
    try {
      final enrolled = await ref.read(vaultServiceProvider).enrolled();
      if (mounted) setState(() => _enrolled = enrolled);
    } on PlatformException {
      if (mounted) setState(() => _enrolled = false);
    }
  }

  Future<void> _run(Future<void> Function() action, String done) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      if (!mounted) return;
      showBriefNotice(context, done);
      await _refresh();
    } on PlatformException catch (e) {
      if (mounted) setState(() => _error = e.code == 'no_lock' ? appL10n.vaultNoLock : e.message ?? e.code);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _enroll() async {
    final secret = _key.text.trim();
    if (secret.isEmpty) {
      setState(() => _error = appL10n.vaultNeedKey);
      return;
    }
    await _run(
      () => ref.read(vaultServiceProvider).enroll(secret),
      appL10n.vaultEnrolledDone(secret.length),
    );
    if (mounted) _key.clear();
  }

  Future<void> _unlock() async {
    final fs = await ref.read(guestFsProvider.future);
    if (fs == null) {
      setState(() => _error = appL10n.vaultUnlockedFailed(appL10n.commonThisPhone));
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final key = await ref.read(vaultServiceProvider).unlock();
      await writeTempKey(key, fs.root);
      if (mounted) showBriefNotice(context, appL10n.vaultUnlockedDone);
    } on PlatformException catch (e) {
      if (mounted) setState(() => _error = e.code == 'no_lock' ? appL10n.vaultNoLock : e.message ?? e.code);
    } catch (e) {
      if (mounted) setState(() => _error = appL10n.vaultUnlockedFailed('$e'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _clear() async {
    await _run(() => ref.read(vaultServiceProvider).clear(), appL10n.vaultClearDone);
  }

  @override
  void dispose() {
    unawaited(ref.read(vaultServiceProvider).secure(false));
    _key.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return AppPage.list(
      title: l10n.vaultTitle,
      subtitle: Text(l10n.vaultIntro),
      children: [
        FormFieldGroup(
          children: [
            ListTile(
              title: Text(_enrolled ? l10n.vaultStatusEnrolled : l10n.vaultStatusEmpty),
              leading: Icon(_enrolled ? Icons.lock : Icons.lock_open, color: _enrolled ? Theme.of(context).colorScheme.primary : null),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextField(
                key: const ValueKey('vault-key-input'),
                controller: _key,
                enabled: !_busy,
                minLines: 3,
                maxLines: 6,
                decoration: InputDecoration(hintText: l10n.vaultPaste),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(l10n.vaultEnrollHint, style: theme.textTheme.bodySmall),
            ),
            if (_error case final error?)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(error, style: theme.textTheme.bodySmall?.copyWith(color: DshColors.of(context).danger)),
              ),
            if (_enrolled && !_hardwareBacked)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Text(
                  l10n.vaultNotHardwareBacked,
                  style: theme.textTheme.bodySmall?.copyWith(color: DshColors.of(context).warning),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton(onPressed: _busy ? null : _enroll, child: Text(l10n.vaultEnroll)),
                  OutlinedButton(onPressed: _busy || !_enrolled ? null : _unlock, child: Text(l10n.vaultUnlock)),
                  TextButton(onPressed: _busy || !_enrolled ? null : _clear, child: Text(l10n.vaultClear)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
