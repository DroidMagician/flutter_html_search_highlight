/// A single keyword occurrence inside [pageIndex], identified by its order
/// on that page among all matches (0-based [matchIndex]).
class MatchLocation {
  const MatchLocation(this.pageIndex, this.matchIndex);

  final int pageIndex;
  final int matchIndex;

  @override
  bool operator ==(Object other) =>
      other is MatchLocation &&
      other.pageIndex == pageIndex &&
      other.matchIndex == matchIndex;

  @override
  int get hashCode => Object.hash(pageIndex, matchIndex);
}
