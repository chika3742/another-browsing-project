class ParsingException implements Exception {
  String? message;

  ParsingException([this.message]);

  @override
  String toString() {
    return "$runtimeType: ${message.toString()}";
  }
}