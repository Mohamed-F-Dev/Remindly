class TextNormalizer {
  static final _tashkeel = RegExp(r'[\u064B-\u065F]');
  static final _nonLetters = RegExp(r'[^\p{L}\p{N}\s]', unicode: true);
  static final _spaces = RegExp(r'\s+');

  static String normalize(String input) {
    var s = input;
    s = s.replaceAll(RegExp('[أإآ]'), 'ا');

    // s = s.replaceAll('ة', 'ه');

    s = s.replaceAll(_tashkeel, '');

    s = s.replaceAll(_nonLetters, ' ');

    s = s.replaceAll(_spaces, ' ').trim();

    return s;
  }
}
