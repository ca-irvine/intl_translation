import 'dart:convert';
import 'dart:io';

import 'package:intl_translation/generate_common_message.dart';
import "package:test/test.dart";

main() {
  test('コード生成テスト', () async {
    final messages = _getMessages();
    final generation = CommonMessageGeneration();
    final generated = generation.generate(messages);
    final expected = _getExpectedContent();

    expect(generated, equals(expected));
  });
}

List<Message> _getMessages() {
  const jsonDecoder = const JsonCodec();
  final file = File('test/generate_common_message/intl_de.arb');
  final src = file.readAsStringSync();
  final Map<String, dynamic> json = jsonDecoder.decode(src);
  return json.entries.where((element) => !element.key.startsWith("@")).map((entry) {
    return Message(id: entry.key, content: entry.value.toString());
  }).toList();
}

String _getExpectedContent() {
  final file = File('test/generate_common_message/message.txt');
  return file.readAsStringSync();
}
