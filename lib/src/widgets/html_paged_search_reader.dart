import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../html_search_highlighter.dart';
import '../match_location.dart';

/// Builder for replacing the default search input widget.
typedef SearchFieldBuilder = Widget Function(
  BuildContext context,
  TextEditingController controller,
  ValueChanged<String> onChanged,
  String keyword,
);

/// Builder for replacing the default match counter + up/down arrows widget.
typedef MatchNavigationBuilder = Widget Function(
  BuildContext context,
  int currentMatchNumber,
  int totalMatches,
  VoidCallback onPrevious,
  VoidCallback onNext,
);

/// Controls whether input HTML is rendered as one page or multiple pages.
enum HtmlContentMode {
  /// Uses the provided shape as-is:
  /// - `htmlContent` -> single page
  /// - `htmlPages` -> multi page
  auto,

  /// Always render as one page (arrays are merged with [singlePageSeparator]).
  singlePage,

  /// Always render as multiple pages (single string becomes one page list).
  multiPage,
}

/// Paged HTML reader with search, match navigation, and `<mark>` highlights.
///
/// Pass HTML from your backend; if [cleanPagesOnLoad] is true (default),
/// each page is passed through [HtmlSearchHighlighter.cleanHtml] once.
class HtmlPagedSearchReader extends StatefulWidget {
  const HtmlPagedSearchReader({
    super.key,
    this.htmlPages,
    this.htmlContent,
    this.contentMode = HtmlContentMode.auto,
    this.singlePageSeparator = '<br/>',
    this.cleanPagesOnLoad = true,
    this.showSearchBar = true,
    this.showPaginationBar = true,
    this.initialPage = 0,
    this.highlightColor,
    this.markStyle,
    this.htmlStyles = const {},
    this.searchFieldBuilder,
    this.searchFieldDecoration,
    this.searchTextStyle,
    this.searchHintStyle,
    this.searchBarDecoration,
    this.searchLeadingIcon,
    this.hintText = 'Search keywords',
    this.showClearSearchButton = true,
    this.clearSearchIcon,
    this.matchNavigationBuilder,
    this.counterTextStyle,
    this.previousMatchIcon,
    this.nextMatchIcon,
    this.onPageChanged,
    this.scrollbarThumbVisibility = true,
  }) : assert(
          htmlPages != null || htmlContent != null,
          'Provide either htmlContent or htmlPages.',
        );

  /// Multi-page input.
  final List<String>? htmlPages;

  /// Single-page input.
  final String? htmlContent;

  /// Select how input is interpreted for rendering.
  final HtmlContentMode contentMode;

  /// Used when [contentMode] is [HtmlContentMode.singlePage] and source is list.
  final String singlePageSeparator;
  final bool cleanPagesOnLoad;

  /// Search field and match counter row.
  final bool showSearchBar;

  /// Bottom previous/next page controls.
  final bool showPaginationBar;

  final int initialPage;

  /// Sets default `<mark>` background color when [markStyle] does not specify one.
  final Color? highlightColor;

  /// Styling for injected `<mark>` elements.
  final Style? markStyle;

  /// Merged into [Html.style]; `"mark"` is merged with [markStyle].
  final Map<String, Style> htmlStyles;

  /// Replace only the search field area; counter/arrows stay separate.
  final SearchFieldBuilder? searchFieldBuilder;
  final InputDecoration? searchFieldDecoration;
  final TextStyle? searchTextStyle;
  final TextStyle? searchHintStyle;
  final BoxDecoration? searchBarDecoration;
  final Widget? searchLeadingIcon;
  final String hintText;
  final bool showClearSearchButton;
  final Widget? clearSearchIcon;

  /// Replace default match counter + up/down arrows widget.
  final MatchNavigationBuilder? matchNavigationBuilder;
  final TextStyle? counterTextStyle;
  final Widget? previousMatchIcon;
  final Widget? nextMatchIcon;

  final ValueChanged<int>? onPageChanged;
  final bool scrollbarThumbVisibility;

  @override
  State<HtmlPagedSearchReader> createState() => _HtmlPagedSearchReaderState();
}

class _HtmlPagedSearchReaderState extends State<HtmlPagedSearchReader> {
  late final PageController _pageController;
  late final TextEditingController _searchController;

  late List<String> _sourcePages;
  List<String> _displayPages = [];
  List<ScrollController> _scrollControllers = [];

  int _currentPage = 0;
  String _keyword = '';

  List<MatchLocation> _globalMatches = [];
  int _currentMatchIndex = 0;
  int _totalMatches = 0;

  Map<String, Style> get _mergedHtmlStyles {
    final defaults = <String, Style>{
      'body': Style(color: Colors.black87, fontSize: FontSize(16)),
    };
    final baseMark = widget.markStyle ??
        Style(
          backgroundColor: widget.highlightColor ?? Colors.yellow,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        );
    final normalizedBaseMark = widget.highlightColor != null
        ? baseMark.copyWith(backgroundColor: widget.highlightColor)
        : baseMark;
    final merged = <String, Style>{
      ...defaults,
      ...widget.htmlStyles,
    };
    final userMark = merged['mark'];
    merged['mark'] =
        userMark != null ? normalizedBaseMark.merge(userMark) : normalizedBaseMark;
    return merged;
  }

  @override
  void initState() {
    super.initState();
    final initial = widget.initialPage.clamp(0, _safeMaxPage(_resolvedInputPages));
    _currentPage = initial;
    _pageController = PageController(initialPage: initial);
    _searchController = TextEditingController();
    _applyIncomingPages(_resolvedInputPages);
  }

  int _safeMaxPage(List<String> pages) =>
      pages.isEmpty ? 0 : pages.length - 1;

  List<String> get _resolvedInputPages {
    final fromList = widget.htmlPages;
    final fromSingle = widget.htmlContent;
    final raw = fromList ?? (fromSingle != null ? [fromSingle] : const <String>[]);

    if (raw.isEmpty) return const <String>[];

    switch (widget.contentMode) {
      case HtmlContentMode.auto:
        return List<String>.from(raw);
      case HtmlContentMode.singlePage:
        return <String>[raw.join(widget.singlePageSeparator)];
      case HtmlContentMode.multiPage:
        return List<String>.from(raw);
    }
  }

  void _applyIncomingPages(List<String> pages) {
    for (final sc in _scrollControllers) {
      sc.dispose();
    }
    _scrollControllers = [];

    _sourcePages = widget.cleanPagesOnLoad
        ? pages.map(HtmlSearchHighlighter.cleanHtml).toList()
        : List<String>.from(pages);

    _displayPages = List<String>.from(_sourcePages);
    _scrollControllers =
        List.generate(_sourcePages.length, (_) => ScrollController());

    _keyword = '';
    _searchController.clear();
    _globalMatches = [];
    _currentMatchIndex = 0;
    _totalMatches = 0;
  }

  @override
  void didUpdateWidget(covariant HtmlPagedSearchReader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.htmlPages, widget.htmlPages) ||
        oldWidget.htmlContent != widget.htmlContent ||
        oldWidget.contentMode != widget.contentMode ||
        oldWidget.singlePageSeparator != widget.singlePageSeparator ||
        oldWidget.cleanPagesOnLoad != widget.cleanPagesOnLoad) {
      _applyIncomingPages(_resolvedInputPages);
      final safe = _safeMaxPage(_sourcePages);
      if (_currentPage > safe) {
        _currentPage = 0;
      }
      if (_pageController.hasClients && safe >= 0) {
        _pageController.jumpToPage(_currentPage.clamp(0, safe));
      }
      setState(() {});
    }
  }

  void _recomputeSearch() {
    final result = HtmlSearchHighlighter.searchPages(_sourcePages, _keyword);
    _displayPages = result.displayPages;
    _globalMatches = result.matches;
    _totalMatches = result.totalMatches;
    _currentMatchIndex = 0;
    if (_globalMatches.isNotEmpty) {
      _jumpToMatch(0);
    }
  }

  void _updateSearch(String value) {
    setState(() {
      _keyword = HtmlSearchHighlighter.normalizeSearchInput(value);
      _recomputeSearch();
    });
  }

  void _resetSearch() {
    setState(() {
      _keyword = '';
      _searchController.clear();
      _displayPages = List<String>.from(_sourcePages);
      _globalMatches = [];
      _currentMatchIndex = 0;
      _totalMatches = 0;
    });
  }

  void _jumpToMatch(int index) {
    if (_globalMatches.isEmpty) return;

    final match = _globalMatches[index];

    if (_currentPage != match.pageIndex) {
      _pageController.animateToPage(
        match.pageIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage = match.pageIndex);
      widget.onPageChanged?.call(_currentPage);
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) _scrollToMatch(match);
      });
    } else {
      _scrollToMatch(match);
    }
  }

  void _scrollToMatch(MatchLocation match, {int retries = 3}) {
    final page = match.pageIndex;
    if (page >= _scrollControllers.length) return;

    final sc = _scrollControllers[page];
    if (!sc.hasClients) {
      if (retries > 0) {
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) _scrollToMatch(match, retries: retries - 1);
        });
      }
      return;
    }

    final maxExtent = sc.position.maxScrollExtent;
    final offset = HtmlSearchHighlighter.scrollOffsetForMatch(
      sourcePageHtml: _sourcePages[page],
      keyword: _keyword,
      matchIndex: match.matchIndex,
      maxScrollExtent: maxExtent,
    );
    if (offset == null) return;

    sc.animateTo(
      offset,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _nextMatch() {
    if (_totalMatches == 0) return;
    setState(() {
      _currentMatchIndex++;
      if (_currentMatchIndex >= _totalMatches) {
        _currentMatchIndex = 0;
      }
      _jumpToMatch(_currentMatchIndex);
    });
  }

  void _previousMatch() {
    if (_totalMatches == 0) return;
    setState(() {
      _currentMatchIndex--;
      if (_currentMatchIndex < 0) {
        _currentMatchIndex = _totalMatches - 1;
      }
      _jumpToMatch(_currentMatchIndex);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    for (final sc in _scrollControllers) {
      sc.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_displayPages.isEmpty || _scrollControllers.isEmpty) {
      return const SizedBox.shrink();
    }

    final bottomPadding = widget.showPaginationBar ? 40.0 : 0.0;

    return Column(
      children: [
        if (widget.showSearchBar) _buildSearchRow(context),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: PageView.builder(
              controller: _pageController,
              itemCount: _displayPages.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
                widget.onPageChanged?.call(index);
              },
              itemBuilder: (context, index) {
                if (index >= _scrollControllers.length) {
                  return const SizedBox.shrink();
                }
                return Scrollbar(
                  controller: _scrollControllers[index],
                  thumbVisibility: widget.scrollbarThumbVisibility,
                  child: SingleChildScrollView(
                    controller: _scrollControllers[index],
                    padding: const EdgeInsets.all(16),
                    child: Html(
                      data: _displayPages[index],
                      style: _mergedHtmlStyles,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (widget.showPaginationBar) _buildPaginationBar(context),
      ],
    );
  }

  Widget _buildSearchRow(BuildContext context) {
    final keywordVisible = _keyword.trim().isNotEmpty;
    final currentMatchNumber = _totalMatches == 0 ? 0 : _currentMatchIndex + 1;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: widget.searchFieldBuilder != null
                ? widget.searchFieldBuilder!(
                    context,
                    _searchController,
                    _updateSearch,
                    _keyword,
                  )
                : _buildDefaultSearchField(context),
          ),
          const SizedBox(width: 8),
          if (keywordVisible)
            widget.matchNavigationBuilder != null
                ? widget.matchNavigationBuilder!(
                    context,
                    currentMatchNumber,
                    _totalMatches,
                    _previousMatch,
                    _nextMatch,
                  )
                : _buildDefaultMatchNavigation(context, currentMatchNumber),
          if (widget.showClearSearchButton)
            IconButton(
              tooltip: 'Clear search',
              onPressed: _resetSearch,
              icon: widget.clearSearchIcon ?? const Icon(Icons.close),
            ),
        ],
      ),
    );
  }

  Widget _buildDefaultSearchField(BuildContext context) {
    final hintStyle = widget.searchHintStyle ??
        Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            );

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: widget.searchBarDecoration ??
          BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
          ),
      child: Row(
        children: [
          widget.searchLeadingIcon ??
              Icon(
                Icons.search,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _updateSearch,
              style: widget.searchTextStyle ?? Theme.of(context).textTheme.bodyMedium,
              textAlignVertical: TextAlignVertical.center,
              decoration: widget.searchFieldDecoration ??
                  InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: hintStyle,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultMatchNavigation(BuildContext context, int currentMatchNumber) {
    return Row(
      children: [
        Text(
          _totalMatches == 0 ? '0' : '$currentMatchNumber / $_totalMatches',
          style: widget.counterTextStyle ?? Theme.of(context).textTheme.bodySmall,
        ),
        SizedBox(
          width: 32,
          height: 32,
          child: IconButton(
            icon: widget.previousMatchIcon ?? const Icon(Icons.keyboard_arrow_up),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
            onPressed: _previousMatch,
          ),
        ),
        SizedBox(
          width: 32,
          height: 32,
          child: IconButton(
            icon: widget.nextMatchIcon ?? const Icon(Icons.keyboard_arrow_down),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
            onPressed: _nextMatch,
          ),
        ),
      ],
    );
  }

  Widget _buildPaginationBar(BuildContext context) {
    final current = _currentPage + 1;
    final total = _displayPages.length;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                onPressed: current > 1
                    ? () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
              ),
              Text(
                '${current.toString().padLeft(2, '0')}/'
                '${total.toString().padLeft(2, '0')}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.arrow_forward_ios, size: 18),
                onPressed: current < total
                    ? () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
