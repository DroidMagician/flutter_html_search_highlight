import 'package:html/parser.dart' as html_parser;

import 'html_multi_page_search_result.dart';
import 'html_page_highlight.dart';
import 'match_location.dart';

/// HTML cleanup, keyword validation, highlighting, and scroll helpers.
///
/// Designed for use with [flutter_html](https://pub.dev/packages/flutter_html):
/// clean HTML once, inject `<mark>` for matches, style `"mark"` in [Html].
class HtmlSearchHighlighter {
  HtmlSearchHighlighter._();

  /// Normalizes iOS “smart” apostrophes to ASCII `'` for consistent matching.
  static String normalizeSearchInput(String keyword) {
    return keyword.replaceAll('\u2018', "'").replaceAll('\u2019', "'");
  }

  /// Cleans HTML once at ingestion so display and search share the same text.
  static String cleanHtml(String raw) {
    return raw
        .replaceAll('&nbsp;', ' ')
        .replaceAll('\u00A0', ' ')
        .replaceAll('</h1><h1>', ' ')
        .replaceAll(
          RegExp(
            r"&#39;|&#8217;|&#8216;|&#x27;|&#x2019;|&#x2018;"
            r"|&apos;|&rsquo;|&lsquo;",
          ),
          "'",
        )
        .replaceAll('\u2018', "'")
        .replaceAll('\u2019', "'")
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Returns false for empty, lone `&`, or partial entities like `&nb`.
  static bool isValidSearchKeyword(String keyword) {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed == '&') return false;
    if (trimmed.startsWith('&') && !trimmed.endsWith(';')) return false;
    return true;
  }

  /// Walks the string treating tags and entities as opaque; only plain text
  /// runs are matched. Matches are wrapped in `<mark>`.
  static HtmlPageHighlight highlightTextNodes(String rawHtml, String keyword) {
    final buffer = StringBuffer();
    var i = 0;
    var matchCount = 0;
    final regex = RegExp(RegExp.escape(keyword), caseSensitive: false);

    while (i < rawHtml.length) {
      final ch = rawHtml[i];

      if (ch == '<') {
        final end = rawHtml.indexOf('>', i);
        if (end == -1) {
          buffer.write(rawHtml.substring(i));
          break;
        }
        buffer.write(rawHtml.substring(i, end + 1));
        i = end + 1;
        continue;
      }

      if (ch == '&') {
        final semi = rawHtml.indexOf(';', i);
        if (semi != -1 && semi - i <= 12) {
          buffer.write(rawHtml.substring(i, semi + 1));
          i = semi + 1;
          continue;
        }
      }

      final nextSpecial = _nextSpecialIndex(rawHtml, i);
      final textNode = rawHtml.substring(i, nextSpecial);

      final highlighted = textNode.replaceAllMapped(regex, (match) {
        matchCount++;
        return '<mark>${match.group(0)}</mark>';
      });

      buffer.write(highlighted);
      i = nextSpecial;
    }

    return HtmlPageHighlight(html: buffer.toString(), matchCount: matchCount);
  }

  /// Full search across [cleanedHtmlPages] (already [cleanHtml] output).
  static HtmlMultiPageSearchResult searchPages(
    List<String> cleanedHtmlPages,
    String rawKeyword,
  ) {
    final keyword = normalizeSearchInput(rawKeyword);

    if (!isValidSearchKeyword(keyword)) {
      return HtmlMultiPageSearchResult(
        displayPages: List<String>.from(cleanedHtmlPages),
        matches: const [],
        matchesPerPage: List<int>.filled(cleanedHtmlPages.length, 0),
      );
    }

    final trimmed = keyword.trim();
    final updatedPages = <String>[];
    final globalMatches = <MatchLocation>[];
    final perPage = <int>[];

    for (var page = 0; page < cleanedHtmlPages.length; page++) {
      final pageHtml = cleanedHtmlPages[page];
      final doc = html_parser.parse(pageHtml);
      final visibleText = doc.body?.text ?? '';

      if (!visibleText.toLowerCase().contains(trimmed.toLowerCase())) {
        perPage.add(0);
        updatedPages.add(pageHtml);
        continue;
      }

      final result = highlightTextNodes(pageHtml, trimmed);
      for (var i = 0; i < result.matchCount; i++) {
        globalMatches.add(MatchLocation(page, i));
      }
      perPage.add(result.matchCount);
      updatedPages.add(result.html);
    }

    return HtmlMultiPageSearchResult(
      displayPages: updatedPages,
      matches: globalMatches,
      matchesPerPage: perPage,
    );
  }

  /// Maps a match to a scroll offset using visible text length (same approach
  /// as a fraction of [maxScrollExtent]). Returns null if scrolling is not
  /// applicable.
  static double? scrollOffsetForMatch({
    required String sourcePageHtml,
    required String keyword,
    required int matchIndex,
    required double maxScrollExtent,
  }) {
    if (maxScrollExtent <= 0) return null;

    final trimmed = normalizeSearchInput(keyword).trim();
    if (!isValidSearchKeyword(trimmed)) return null;

    final doc = html_parser.parse(sourcePageHtml);
    final fullText = doc.body?.text ?? '';
    if (fullText.isEmpty) return null;

    final matches = RegExp(RegExp.escape(trimmed), caseSensitive: false)
        .allMatches(fullText)
        .toList();

    if (matchIndex < 0 || matchIndex >= matches.length) return null;

    final charOffset = matches[matchIndex].start;
    final fraction = charOffset / fullText.length;
    return (fraction * maxScrollExtent).clamp(0.0, maxScrollExtent);
  }

  static int _nextSpecialIndex(String s, int from) {
    for (var j = from; j < s.length; j++) {
      if (s[j] == '<' || s[j] == '&') return j;
    }
    return s.length;
  }
}
