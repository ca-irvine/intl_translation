library generate_message_from_arb;

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:intl_translation/generate_common_message.dart';

const jsonDecoder = const JsonCodec();

main(List<String> args) {
  final parser = ArgParser();
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

  translationFile = args.firstWhere((element) => element.endsWith("arb"), orElse: () => null);

  if ((translationFile ?? '').isEmpty) {
    print('Usage: generate_message_from_arb [options]'
        ' path/to/translation_file.arb');
    print(parser.usage);
    exit(0);
  }

  final file = File(translationFile);
  final src = file.readAsStringSync();
  final Map<String, dynamic> json = jsonDecoder.decode(src);
  final messages = json.entries.where((element) => !element.key.startsWith("@")).map((entry) {
    return Message(id: entry.key, content: entry.value.toString());
  }).toList();

  final generation = CommonMessageGeneration();
  final generated = generation.generate(messages);

  File(outputPath).writeAsStringSync(generated);
}
