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
        
    }
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
    this.id,
    this.content,
  });

  final String id;
  final String content;

  String toCode() {
    final exp = RegExp('^.+\{(.+)\}');
    final matches = exp.allMatches(content);
    if (matches.isEmpty) {
      return '''
        String get $id {
          return Intl.message(
            '$content',
            name: '$id',
          );
        }
    ''';
    }

    final arguments = matches.map((e) => e.group(0));
    final argumentsWithType = arguments.map((e) => 'dynamic $e').join(',');

    return '''
    String $id($argumentsWithType) {
      Intl.message(
        '$content',
        name: '$id',
        args: [${arguments.join(',')}],
      );
    }
    ''';
  }
}
