import 'dart:convert';
import 'dart:io';

import 'package:intl_translation/generate_common_message.dart';
import "package:test/test.dart";

main() {
  final generation = CommonMessageGeneration();
  final messages = _getMessages();

  final inputs = [
    Input(
      'コード生成テスト (none)',
      'test/generate_common_message/message_none.txt',
      MessageTextType.none,
    ),
    Input(
      'コード生成テスト (same)',
      'test/generate_common_message/message_same.txt',
      MessageTextType.same,
    ),
  ];
  inputs.forEach((input) {
    test(input.description, () async {
      final generated = generation.generate(messages, messageTextType: input.messageTextType);
      final expected = _getExpectedContent(input.expectedFilePath);

      expect(generated, equals(expected));
    });
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

String _getExpectedContent(String path) {
  final file = File(path);
  return file.readAsStringSync();
}

class Input {
  Input(
    this.description,
    this.expectedFilePath,
    this.messageTextType,
  );

  final String description;
  final String expectedFilePath;
  final MessageTextType messageTextType;
}
