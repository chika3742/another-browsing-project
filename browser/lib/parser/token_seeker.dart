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