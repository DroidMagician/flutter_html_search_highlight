/// Result of highlighting one HTML fragment.
class HtmlPageHighlight {
  const HtmlPageHighlight({required this.html, required this.matchCount});

  final String html;
  final int matchCount;
}
