library generate_common_message;

enum MessageTextType {
  none,
  same,
}

extension MessageTextTypeExt on MessageTextType {
  static MessageTextType fromString(String str) {
    switch (str.toLowerCase()) {
      case 'none':
        return MessageTextType.none;
      case 'same':
        return MessageTextType.same;
    }
    throw FallThroughError();
  }
}

class CommonMessageGeneration {
  String generate(
    List<Message> messages, {
    MessageTextType messageTextType = MessageTextType.none,
  }) {
    final output = StringBuffer();

    output.write('''
import 'dart:ui';

import 'package:domain/domain.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:intl/intl.dart';

class Message {
  const Message._(this.locale, this.datePickerLocale);

  factory Message.of(Locale locale) {
    switch (SupportedLanguage.fromString(locale.languageCode)) {
      case SupportedLanguage.ja:
        return Message._(locale, DateTimePickerLocale.jp);
      case SupportedLanguage.en:
        return Message._(locale, DateTimePickerLocale.en_us);
    }

    throw FallThroughError();
  }

  final Locale locale;
  final DateTimePickerLocale datePickerLocale;

''');

    messages.forEach((element) {
      output.write(element.toCode(messageTextType: messageTextType));
      output.write("\n");
    });

    output.write("}\n");

    return output.toString();
  }
}

enum MessageType {
  field,
  method,
}

class Message {
  Message({
    String id,
    String content,
  })  : id = id.replaceAll("@", ""),
        content = content.escapeAndValidateString();

  final String id;
  final String content;

  String toCode({
    MessageTextType messageTextType = MessageTextType.none,
  }) {
    final exp = RegExp('\{([a-zA-Z]+)\}');
    final matches = exp.allMatches(content);

    String messageText;
    switch (messageTextType) {
      case MessageTextType.none:
        messageText = 'null';
        break;
      case MessageTextType.same:
        messageText = '\'$content\'';
        break;
    }

    if (matches.isEmpty) {
      return '''
  String get $id {
    return Intl.message(
      $messageText,
      name: '$id',
    );
  }
''';
    }

    final arguments = matches.map((e) => e.group(0).replaceAll('{', '').replaceAll('}', ''));
    final argumentsWithType = arguments.map((e) => 'dynamic $e').join(', ');

    return '''
  String $id($argumentsWithType) {
    return Intl.message(
      $messageText,
      name: '$id',
      args: [${arguments.join(', ')}],
    );
  }
''';
  }
}

extension StringExt on String {
  String escapeAndValidateString() {
    const Map<String, String> escapes = const {
      r"\": r"\\",
      '"': r'\"',
      "\b": r"\b",
      "\f": r"\f",
      "\n": r"\n",
      "\r": r"\r",
      "\t": r"\t",
      "\v": r"\v",
      "'": r"\'",
      r"$": r"\$",
    };

    String _escape(String s) => escapes[s] ?? s;

    return this.splitMapJoin("", onNonMatch: _escape);
  }
}
