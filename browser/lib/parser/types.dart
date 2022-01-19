class AbmlObject {
  AbmlMeta? meta;

  AbmlObject({this.meta});
}

class AbmlMeta {
  String? title;
  String? lang;
  List<String>? attrs;
  List<Map<String, String>>? props;

  AbmlMeta({
    this.title,
    this.lang,
    this.attrs,
    this.props,
  });
}

class Indent {
  int count;

  Indent(this.count);

  @override
  String toString() {
    return "($count indents)";
  }
}

class Key {
  String value;
  bool atMark;

  Key(this.value, { this.atMark = false });

  @override
  String toString() {
    return "${atMark ? '@' : ''}$value";
  }
}

class Colon {
  @override
  String toString() {
    return ":";
  }
}

class Hyphen {
  @override
  String toString() {
    return "-";
  }
}

class Value {
  String lexical;

  Value(this.lexical);

  @override
  String toString() {
    return lexical;
  }
}


class ListEntry {
  Value value;

  ListEntry(this.value);
}

class MapValue {
  Key? key;
  Map<String, dynamic>? map;

  MapValue({this.key, this.map});
}

class Token {
  Key key;
  Value? value;
  Token? parent;

  Token(this.key, {this.parent, this.value});

  @override
  String toString() {
    return "$key -> $value ${ parent != null ? "(parent: ${parent!.key})" : ""}";
  }
}

enum TokenizingState {
  lineStart,
  key,
  atMarkKey,
  separator,
  value,
  waitForValue,
  listEntry,
  waitForListEntry,
}

enum LineTokenizingState {
  normal,
  contentsWriting,
}

class TokenSeeker {
  var map = {};
  var cursor = -1;
  List<dynamic> tokens;

  get length => tokens.length;

  get current => tokens[cursor];

  TokenSeeker(this.tokens);

  dynamic peek([int index = 1]) {
    return tokens.length >= cursor + index + 1 ?  tokens[cursor + index] : null;
  }

  bool next() {
    if (cursor + 1 < length) {
      cursor++;
      return true;
    }
    return false;
  }

  bool back() {
    if (cursor - 1 >= 0) {
      cursor--;
      return true;
    }
    return false;
  }
}

class ParsingException implements Exception {
  String? message;

  ParsingException([this.message]);

  @override
  String toString() {
    return "$runtimeType: ${message.toString()}";
  }
}