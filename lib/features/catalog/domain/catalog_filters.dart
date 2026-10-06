// Search, filter and sort of the catalogue. Pure functions, run locally:
// typing in the search field never calls the API.

import 'asset_overview.dart';
import 'instrument.dart';

/// The three sort orders offered in the bottom sheet.
enum CatalogSort {
  changeDesc('Variation décroissante', 'Variation sur 1 an'),
  changeAsc('Variation croissante', 'Variation sur 1 an'),
  nameAsc('Nom de A à Z', 'Nom');

  const CatalogSort(this.label, this.buttonLabel);

  /// Text in the bottom sheet.
  final String label;

  /// Text on the sort button, above the list.
  final String buttonLabel;
}

/// Lowercase and without accents, so "societe" finds "Société".
String normalizeForSearch(String text) {
  const accents = {
    'à': 'a',
    'â': 'a',
    'ä': 'a',
    'á': 'a',
    'ã': 'a',
    'ç': 'c',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'î': 'i',
    'ï': 'i',
    'í': 'i',
    'ô': 'o',
    'ö': 'o',
    'ó': 'o',
    'õ': 'o',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ú': 'u',
    'ÿ': 'y',
    'ñ': 'n',
    'œ': 'oe',
    'æ': 'ae',
  };
  final buffer = StringBuffer();
  for (final char in text.toLowerCase().split('')) {
    buffer.write(accents[char] ?? char);
  }
  return buffer.toString().trim();
}

/// True when [query] is found in the name or the symbol. An empty query
/// matches everything.
bool matchesSearch(Instrument instrument, String query) {
  final needle = normalizeForSearch(query);
  if (needle.isEmpty) return true;
  return normalizeForSearch(instrument.name).contains(needle) ||
      normalizeForSearch(instrument.symbol).contains(needle);
}

/// Applies search, type filter ([type] null means "Tout") and sort.
/// Returns a new list; the input is not modified.
List<AssetOverview> applyCatalogQuery(
  List<AssetOverview> assets, {
  String query = '',
  InstrumentType? type,
  CatalogSort sort = CatalogSort.changeDesc,
}) {
  final result = assets
      .where((a) => type == null || a.instrument.type == type)
      .where((a) => matchesSearch(a.instrument, query))
      .toList();
  result.sort((a, b) => compareAssets(a, b, sort));
  return result;
}

/// Comparison used by the sort. Assets without a known change always go
/// last, whatever the direction, so loading rows do not jump to the top.
int compareAssets(AssetOverview a, AssetOverview b, CatalogSort sort) {
  int byName() =>
      normalizeForSearch(a.instrument.name)
          .compareTo(normalizeForSearch(b.instrument.name));

  if (sort == CatalogSort.nameAsc) return byName();

  final changeA = a.yearlyChange;
  final changeB = b.yearlyChange;
  if (changeA == null && changeB == null) return byName();
  if (changeA == null) return 1;
  if (changeB == null) return -1;
  final result = sort == CatalogSort.changeDesc
      ? changeB.compareTo(changeA)
      : changeA.compareTo(changeB);
  return result != 0 ? result : byName();
}
