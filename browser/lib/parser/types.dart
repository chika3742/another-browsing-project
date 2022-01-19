import 'package:another_browser/parser/exception.dart';

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

  int asInt() {
    return int.parse(lexical);
  }

  dynamic asEnum(List<Enum> enumValues) {
    if (!lexical.startsWith("\\.")) {
      throw ParsingException("This value is not enum type");
    }

    return enumValues.firstWhere((e) => lexical.replaceRange(0, 0, "") == e.name, orElse: () {
      throw ParsingException("No matching enum value");
    });
  }

  @override
  String toString() {
    return lexical.startsWith('"') && lexical.endsWith('"') ? lexical.substring(1, lexical.length - 1) : lexical;
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
