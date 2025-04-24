import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/csv_mapping.dart';
import 'backup_provider.dart';

class ImportSource {
  final String name;
  final String logoUrl;
  final String id;

  ImportSource({required this.name, required this.logoUrl, required this.id});

  factory ImportSource.fromMapping(CSVMapping mapping) {
    return ImportSource(
      name: mapping.name,
      logoUrl: mapping.logoUrl,
      id: mapping.id,
    );
  }
}

final importSourcesProvider = Provider<List<ImportSource>>((ref) {
  final mappings = ref.watch(backupProvider).availableMappings;
  return mappings.map((m) => ImportSource.fromMapping(m)).toList();
});

final filteredSourcesProvider = StateNotifierProvider<FilteredSourcesNotifier, List<ImportSource>>((ref) {
  return FilteredSourcesNotifier(ref.read(importSourcesProvider));
});

class FilteredSourcesNotifier extends StateNotifier<List<ImportSource>> {
  final List<ImportSource> _allSources;

  FilteredSourcesNotifier(this._allSources) : super(_allSources);

  void filter(String query) {
    if (query.isEmpty) {
      state = _allSources;
      return;
    }
    state = _allSources
        .where((source) => source.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
