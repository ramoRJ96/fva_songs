/// Tri naturel des numéros de chant (ex. 2 avant 10, 28 avant 28 bis).
class SongNumberComparator {
  const SongNumberComparator._();

  static int compare(String a, String b) {
    final parsedA = _parse(a);
    final parsedB = _parse(b);

    if (parsedA.numeric != null && parsedB.numeric != null) {
      final numericCompare = parsedA.numeric!.compareTo(parsedB.numeric!);
      if (numericCompare != 0) return numericCompare;
      return parsedA.suffix.compareTo(parsedB.suffix);
    }

    if (parsedA.numeric != null && parsedB.numeric == null) return -1;
    if (parsedA.numeric == null && parsedB.numeric != null) return 1;

    return parsedA.raw.compareTo(parsedB.raw);
  }

  static _ParsedNumber _parse(String raw) {
    final trimmed = raw.trim().toLowerCase();
    final match = RegExp(r'^(\d+)(?:\s+(.*))?$').firstMatch(trimmed);
    if (match == null) {
      return _ParsedNumber(raw: trimmed);
    }

    return _ParsedNumber(
      raw: trimmed,
      numeric: int.parse(match.group(1)!),
      suffix: match.group(2)?.trim() ?? '',
    );
  }
}

class _ParsedNumber {
  const _ParsedNumber({
    required this.raw,
    this.numeric,
    this.suffix = '',
  });

  final String raw;
  final int? numeric;
  final String suffix;
}
