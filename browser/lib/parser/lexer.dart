import 'package:another_browser/parser/types.dart';

List<dynamic> tokenize(String line, int lineNum) {
  var lexicalSeq = [];
  var tokenizingState = TokenizingState.lineStart;

  // indent counter
  var indent = 0;

  var charNum = 0;

  // builder
  var keyBuilder = StringBuffer();
  var valueBuilder = StringBuffer();
  for (var char in line.toCharList()) {
    charNum++;

    // count indent
    if (tokenizingState == TokenizingState.lineStart) {
      if (char == " ") {
        indent++;
      } else {
        if (char == "@") {
          tokenizingState = TokenizingState.atMarkKey;
        } else {
          tokenizingState = TokenizingState.key;
        }
        if (indent >= 1) lexicalSeq.add(Indent(indent));
      }
    }

    if (tokenizingState == TokenizingState.key || tokenizingState == TokenizingState.atMarkKey) {
      if (char == "@") {
        continue;
      } else if (RegExp("[a-zA-Z0-9.]").hasMatch(char)) {
        keyBuilder.write(char);
      } else if (char == "-") {
        lexicalSeq.add(Hyphen());
        tokenizingState = TokenizingState.waitForListEntry;
      } else {
        // confirmed expression
        var key = keyBuilder.toString();
        keyBuilder.clear();
        lexicalSeq.add(Key(key, atMark: tokenizingState == TokenizingState.atMarkKey));

        tokenizingState = TokenizingState.separator;
      }
    }

    if (tokenizingState == TokenizingState.separator) {
      if (char == ":") {
        lexicalSeq.add(Colon());
        tokenizingState = TokenizingState.waitForValue;
        continue;
      } else if (char == " ") {
        continue;
      } else {
        throw ParsingException('Unexpected Token "$char" on line $lineNum char $charNum');
      }
    }

    if (tokenizingState == TokenizingState.waitForValue) {
      if (char == " ") {
        continue;
      } else {
        tokenizingState = TokenizingState.value;
      }
    }

    if (tokenizingState == TokenizingState.value) {
      valueBuilder.write(char);
    }

    if (tokenizingState == TokenizingState.waitForListEntry) {
      if (char == " ") {
        continue;
      } else {
        tokenizingState = TokenizingState.listEntry;
      }
    }

    if (tokenizingState == TokenizingState.listEntry) {
      valueBuilder.write(char);
    }
  }

  if (valueBuilder.length >= 1) {
    if (tokenizingState == TokenizingState.value) {
      lexicalSeq.add(Value(valueBuilder.toString()));
    }
    if (tokenizingState == TokenizingState.listEntry) {
      lexicalSeq.add(ListEntry(Value(valueBuilder.toString())));
    }
  }

  return lexicalSeq;
}

bool isEndOfCW(String line) {
  return line.isNotEmpty && line.startsWith("[^ ]");
}

extension StringToCharList on String {
  List<String> toCharList() {
    return codeUnits.map((e) => String.fromCharCode(e)).toList();
  }
}