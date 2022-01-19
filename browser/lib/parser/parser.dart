import 'dart:ffi';

import 'package:another_browser/parser/lexer.dart';
import 'package:another_browser/parser/types.dart';

AbmlObject? parse(String input) {
  var result = {};

  var lines = input.split("\n");
  var tokenizedLines = <dynamic>[];

  var lineTokenizingState = LineTokenizingState.normal;
  var lineNum = 0;
  for (var line in lines) {
    lineNum++;
    List<dynamic> tokenized;
    if (lineTokenizingState == LineTokenizingState.normal) {
      tokenized = tokenize(line, lineNum);
    } else {
      tokenized = [];
    }
    if (tokenized.any((element) => element is Key && element.atMark)) {
      lineTokenizingState = LineTokenizingState.contentsWriting;
    } else if (isEndOfCW(line)) {
      lineTokenizingState = LineTokenizingState.normal;
    }

    tokenizedLines.add(tokenized);
  }

  return _parse(tokenizedLines.expand((element) => element).toList());
}

dynamic _parse(List<dynamic> tokenized) {
  var map = <MapEntry<String, dynamic>>[];
  var seeker = TokenSeeker(tokenized);

  print(tokenized);

  map = _parseObject(seeker, 0);

  print(Map.fromEntries(map));
}

List<MapEntry<String, dynamic>> _parseObject(TokenSeeker seeker, int currentIndent) {
  var map = <MapEntry<String, dynamic>>[];

  String? key;
  dynamic value;
  while (seeker.next()) {
    var token = seeker.current;

    if (token is Key) {
      key = token.value;
    }
    if (token is Value) {
      value = token;
      if (key == null) {
        throw ParsingException("Key not found for value $value");
      }
      map.add(MapEntry(key, value));
    }

    if (token is Colon) {
      if (seeker.peek() is Indent) {
        if (key == null) {
          throw ParsingException("Key not found for map");
        }
        if (seeker.peek(2) is Hyphen) {
          map.add(MapEntry(key, parseArray(seeker, currentIndent + 1)));
        } else {
          map.add(MapEntry(key, Map.fromEntries(_parseObject(seeker, currentIndent + 1))));
        }
      }
    }

    if (token is Indent) {
      if (token.count < currentIndent) {
        seeker.back();
        break;
      }
    }

  }

  return map;
}

List<dynamic> parseArray(TokenSeeker seeker, int currentIndent) {
  var array = [];
  while (seeker.next()) {
    var token = seeker.current;

    if (token is Hyphen) {
      // do nothing
    }

    if (token is ListEntry) {
      array.add(token.value);
    }

    if (token is Colon) {
      if (seeker.peek() is Indent) {
        if (seeker.peek(2) is Hyphen) {
          array.add(parseArray(seeker, currentIndent + 1));
        } else {
          array.add(Map.fromEntries(_parseObject(seeker, currentIndent + 1)));
        }
      }
    }

    if (token is Indent && token.count < currentIndent) {
      break;
    }
  }

  return array;
}