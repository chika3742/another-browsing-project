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

  print(_parse(tokenizedLines.expand((element) => element).toList()));
  // print(_parse(tokenizedLines));

  return null;
}

dynamic _parse(List<dynamic> tokenized) {
  var result = <Token>[];

  var tokenId = -1;
  var currentIndent = 0;
  var nestList = <Token>[];

  for (var token in tokenized) {
    tokenId++;
    print(nestList);

    if (token is Key) {
      nestList.add(Token(token, parent: nestList.isNotEmpty ? nestList.last : null));
    }

    if (token is Colon) {
      // do nothing
    }

    if (token is Indent) {
      if (currentIndent > token.count) {
        result.addAll(nestList.getRange(token.count ~/ 2, nestList.length));
        nestList.removeRange(token.count ~/ 2, nestList.length);
      }
      currentIndent = token.count;
    }

    if (token is Value) {
      nestList.last.value = token;
    }
  }

  print(result);
}