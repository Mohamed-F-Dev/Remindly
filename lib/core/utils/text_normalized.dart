class TextNormalizer {
  static String normalize(final String input) {
    var s = input.toLowerCase();
    s = s.replaceAll(RegExp('[أإآ]'), 'ا');

    s = s.replaceAll('ة', 'ه');

    s = s.replaceAll(RegExp('[ًٌٍَُِّْ]'), '');
    s = s.replaceAll(RegExp(r'[^\w\s]'), ' ');

    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();

    return s;
  }
}
