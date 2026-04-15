import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_html_search_highlight/flutter_html_search_highlight.dart';

void main() {
  group('HtmlSearchHighlighter', () {
    test('cleanHtml normalizes apostrophe entities', () {
      const raw = "<p>Week&#8217;s plan</p>";
      expect(
        HtmlSearchHighlighter.cleanHtml(raw),
        contains("Week's plan"),
      );
    });

    test('isValidSearchKeyword rejects partial entities', () {
      expect(HtmlSearchHighlighter.isValidSearchKeyword('&nb'), isFalse);
      expect(HtmlSearchHighlighter.isValidSearchKeyword('&'), isFalse);
      expect(HtmlSearchHighlighter.isValidSearchKeyword('ok'), isTrue);
    });

    test('highlightTextNodes wraps matches outside tags', () {
      final r = HtmlSearchHighlighter.highlightTextNodes(
        '<p>Hello world</p>',
        'world',
      );
      expect(r.matchCount, 1);
      expect(r.html, contains('<mark>world</mark>'));
    });

    test('highlightTextNodes does not match inside tag markup', () {
      final r = HtmlSearchHighlighter.highlightTextNodes(
        '<p title="world">hi</p>',
        'world',
      );
      expect(r.matchCount, 0);
    });

    test('searchPages aggregates MatchLocation entries', () {
      final pages = [
        HtmlSearchHighlighter.cleanHtml('<p>alpha beta</p>'),
        HtmlSearchHighlighter.cleanHtml('<p>gamma beta</p>'),
      ];
      final result = HtmlSearchHighlighter.searchPages(pages, 'beta');
      expect(result.totalMatches, 2);
      expect(result.matches[0], const MatchLocation(0, 0));
      expect(result.matches[1], const MatchLocation(1, 0));
      expect(result.matchesPerPage, [1, 1]);
    });

    test('searchPages with invalid keyword returns originals', () {
      const pages = ['<p>x</p>'];
      final result = HtmlSearchHighlighter.searchPages(pages, '   ');
      expect(result.displayPages, pages);
      expect(result.totalMatches, 0);
    });

    test('scrollOffsetForMatch returns clamped offset', () {
      final html = '<p>${'a' * 40}find${'b' * 40}</p>';
      final cleaned = HtmlSearchHighlighter.cleanHtml(html);
      final offset = HtmlSearchHighlighter.scrollOffsetForMatch(
        sourcePageHtml: cleaned,
        keyword: 'find',
        matchIndex: 0,
        maxScrollExtent: 100,
      );
      expect(offset, isNotNull);
      expect(offset! >= 0 && offset <= 100, isTrue);
    });
  });
}
