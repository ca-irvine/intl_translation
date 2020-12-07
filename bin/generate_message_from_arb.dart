library generate_message_from_arb;

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:intl_translation/generate_common_message.dart';

const jsonDecoder = const JsonCodec();

main(List<String> args) {
  var parser = new ArgParser();
  String translationFile;
  String outputPath;

  parser.addOption(
    'translation_file',
    callback: (value) => translationFile = value,
    help: '',
  );
  parser.addOption(
    'output-path',
    defaultsTo: './message.dart',
    callback: (x) => outputPath = x,
    help: '',
  );

  parser.parse(args);

  if ((translationFile ?? '').isEmpty) {
    print('翻訳ファイルを指定してください。');
    print(parser.usage);
    exit(0);
  }

  final file = File(translationFile);
  final src = file.readAsStringSync();
  final Map<String, String> json = jsonDecoder.decode(src);
  final messages = json.entries.where((element) => element.key.startsWith("@")).map((entry) {
    return Message(id: entry.key, content: entry.value);
  });

  final generation = CommonMessageGeneration();
  String generated = generation.generate(messages);

  File(outputPath).writeAsStringSync(generated);
}
