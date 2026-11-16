String settingsContentText(String? html) {
  if (html == null || html.trim().isEmpty) return '';
  var text = html
      .replaceAll(
    RegExp(
      r'<(script|style)\b[^>]*>.*?</\1>',
      caseSensitive: false,
      dotAll: true,
    ),
    '',
  )
      .replaceAll(
    RegExp(r'<br\s*/?>|</(?:p|div|h[1-6]|ul|ol)>', caseSensitive: false),
    '\n\n',
  )
      .replaceAll(RegExp(r'<li\b[^>]*>', caseSensitive: false), '\n• ')
      .replaceAll(RegExp(r'<[^>]*>'), ' ');
  const entities = {
    '&nbsp;': ' ',
    '&amp;': '&',
    '&lt;': '<',
    '&gt;': '>',
    '&quot;': '"',
    '&apos;': "'",
  };
  for (final entry in entities.entries) {
    text = text.replaceAll(entry.key, entry.value);
  }
  text = text.replaceAllMapped(RegExp(r'&#(x[0-9a-fA-F]+|[0-9]+);'), (match) {
    final raw = match[1]!;
    final code = raw.startsWith('x')
        ? int.tryParse(raw.substring(1), radix: 16)
        : int.tryParse(raw);
    return code != null && code > 0 && code <= 0x10ffff
        ? String.fromCharCode(code)
        : match[0]!;
  });
  return text
      .split('\n')
      .map((line) => line.replaceAll(RegExp(r'[\t\r ]+'), ' ').trim())
      .join('\n')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();
}
