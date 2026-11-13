// 密钥保险箱的 Dart 侧：只负责和原生插件说话，不保存密钥明文。
//
// 原生侧（VaultPlugin.kt）用 Android Keystore 里绑定锁屏的 AES 密钥包住私钥；
// 录入和解锁都要过系统确认（指纹 / 锁屏密码），确认后 30 秒内可用。

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VaultService {
  const VaultService([this.channel = const MethodChannel(channelName)]);

  static const channelName = 'dsh/vault';

  final MethodChannel channel;

  Future<bool> enrolled() async => await channel.invokeMethod<bool>('status') ?? false;

  Future<void> enroll(String secret) =>
      channel.invokeMethod<void>('enroll', {'secret': secret});

  Future<String> unlock() async =>
      await channel.invokeMethod<String>('unlock') ?? '';

  Future<void> clear() => channel.invokeMethod<void>('clear');

  /// 当前环境事实：调试版、密钥是否在安全硬件、是否要求设备已解锁。
  Future<Map<String, Object?>> security() async =>
      (await channel.invokeMapMethod<String, Object?>('security')) ?? const {};

  /// 密钥箱页面打开时禁止截屏/录屏。
  Future<void> secure(bool on) => channel.invokeMethod<void>('secure', {'on': on});
}

final vaultServiceProvider = Provider<VaultService>((ref) => const VaultService());

/// 把解锁出来的私钥写到引擎能读到的地方，5 分钟后由引擎侧脚本删除。
/// 返回写入的路径；`guestRoot` 是 rootfs 根目录（GuestFs.root）。
Future<String> writeTempKey(String key, Directory guestRoot) async {
  final dir = Directory('${guestRoot.path}/root/.dsh/memory/vault');
  await dir.create(recursive: true);
  final file = File('${dir.path}/.unlocked-key');
  await file.writeAsString(key, flush: true);
  await Process.run('chmod', ['600', file.path]);
  return file.path;
}
