import 'match_location.dart';

/// Output of searching a list of HTML pages for a keyword.
class HtmlMultiPageSearchResult {
  const HtmlMultiPageSearchResult({
    required this.displayPages,
    required this.matches,
    required this.matchesPerPage,
  });

  /// Pages with `<mark>` wrappers applied where the keyword matched.
  final List<String> displayPages;

  /// Global match order for navigation (page + index on that page).
  final List<MatchLocation> matches;

  /// Same length as pages; each entry is the number of matches on that page.
  final List<int> matchesPerPage;

  int get totalMatches => matches.length;
}
