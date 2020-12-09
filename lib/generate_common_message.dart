library generate_common_message;

class CommonMessageGeneration {
  String generate(List<Message> messages) {
    var output = StringBuffer();

    output.write('''
    import 'dart:ui';

    import 'package:intl/intl.dart';
    
    class Message {
        const Message._(this.locale);

        factory Message.of(Locale locale) {
          return Message._(locale);
        }
      
        final Locale locale;
        
    ''');

    messages.forEach((element) {
      output.write(element.toCode());
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

  String toCode() {
    final exp = RegExp('^.+\{([a-z].+)\}');
    final matches = exp.allMatches(content);
    if (matches.isEmpty) {
      return '''
        String get $id {
          return Intl.message(
            "$content",
            name: "$id",
          );
        }
    ''';
    }

    final arguments = matches.map((e) => e.group(1));
    final argumentsWithType = arguments.map((e) => 'dynamic $e').join(',');

    return '''
    String $id($argumentsWithType) {
      return Intl.message(
        "$content",
        name: "$id",
        args: [${arguments.join(',')}],
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

    var escaped = this.splitMapJoin("", onNonMatch: _escape);
    return escaped;
  }
}
