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
  Key? parent;
  Value? value;

  MapValue({this.parent, this.value})
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

class ParsingException implements Exception {
  String? message;

  ParsingException([this.message]);

  @override
  String toString() {
    return "$runtimeType: ${message.toString()}";
  }
}