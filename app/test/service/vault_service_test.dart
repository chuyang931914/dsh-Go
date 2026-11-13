// 密钥保险箱 Dart 侧：只测通道契约（原生侧由真机验），不碰 Keystore。

import 'package:dsh_app/service/vault_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel(VaultService.channelName);
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      switch (call.method) {
        case 'status':
          return true;
        case 'unlock':
          return 'AGE-SECRET-KEY-1TEST';
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('status reads the enrolled flag', () async {
    expect(await const VaultService().enrolled(), isTrue);
    expect(calls.single.method, 'status');
  });

  test('enroll passes the secret through the channel', () async {
    await const VaultService().enroll('AGE-SECRET-KEY-1TEST');
    expect(calls.single.method, 'enroll');
    expect(calls.single.arguments, {'secret': 'AGE-SECRET-KEY-1TEST'});
  });

  test('unlock returns the key text', () async {
    expect(await const VaultService().unlock(), 'AGE-SECRET-KEY-1TEST');
    expect(calls.single.method, 'unlock');
  });

  test('clear asks the native side to forget the key', () async {
    await const VaultService().clear();
    expect(calls.single.method, 'clear');
  });
}
