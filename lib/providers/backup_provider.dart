import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/csv_file_picker.dart';
import '../database/sossoldi_database.dart';
import '../model/csv_mapping.dart';

final backupProvider = StateNotifierProvider<BackupNotifier, BackupState>((ref) {
  return BackupNotifier();
});

class BackupState {
  final bool isLoading;
  final String? errorMessage;
  final bool showSuccess;
  final List<CSVMapping> availableMappings;
  final String? selectedMapping;

  BackupState({
    this.isLoading = false, 
    this.errorMessage,
    this.showSuccess = false,
    this.availableMappings = const [],
    this.selectedMapping,
  });

  BackupState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? showSuccess,
    List<CSVMapping>? availableMappings,
    String? selectedMapping,
  }) {
    return BackupState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      showSuccess: showSuccess ?? this.showSuccess,
      availableMappings: availableMappings ?? this.availableMappings,
      selectedMapping: selectedMapping ?? this.selectedMapping,
    );
  }
}

class BackupNotifier extends StateNotifier<BackupState> {
  BackupNotifier() : super(BackupState()) {
    _initializeMappings();
  }

  Future<void> _initializeMappings() async {
    try {
      final mappings = await CSVMapping.loadMappings();
      state = state.copyWith(availableMappings: mappings);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to load mappings: ${e.toString()}');
    }
  }

  void selectMapping(String mappingName) {
    state = state.copyWith(selectedMapping: mappingName);
  }

  Future<String> _applyMapping(String csvContent, CSVMapping mapping) async {
    try {
      final lines = csvContent.split('\n');
      if (lines.isEmpty) {
        throw CSVMappingError('Empty CSV file');
      }

      // Parse headers and validate
      final sourceHeaders = lines.first.split(',');
      final outputHeaders = <String>[];
      final columnIndexMap = <String, int>{};
      
      // Create target headers and build column index map
      for (final entry in mapping.columnMap.entries) {
        final sourceColumnIndex = sourceHeaders.indexOf(entry.value);
        if (sourceColumnIndex == -1) {
          throw CSVMappingError(
            'Invalid CSV format',
            missingColumn: entry.value,
          );
        }
        columnIndexMap[entry.key] = sourceColumnIndex;
        outputHeaders.add(entry.key);
      }

      // Add default value columns to headers
      for (final defaultField in mapping.defaultValues.keys) {
        if (!outputHeaders.contains(defaultField)) {
          outputHeaders.add(defaultField);
        }
      }

      final outputLines = <String>[];
      outputLines.add(outputHeaders.join(','));

      // Process data lines
      for (var i = 1; i < lines.length; i++) {
        if (lines[i].trim().isEmpty) continue;
        
        final sourceCells = lines[i].split(',');
        final outputCells = List<String>.filled(outputHeaders.length, '');

        // Map columns according to mapping
        for (var j = 0; j < outputHeaders.length; j++) {
          final headerName = outputHeaders[j];
          
          if (columnIndexMap.containsKey(headerName)) {
            // Get value from source
            final sourceIndex = columnIndexMap[headerName]!;
            var value = sourceCells[sourceIndex];

            // Apply value mapping if exists
            if (mapping.valueMap.containsKey(headerName)) {
              final valueMapForColumn = mapping.valueMap[headerName]!;
              value = valueMapForColumn[value] ?? value;
            }
            
            outputCells[j] = value;
          } else if (mapping.defaultValues.containsKey(headerName)) {
            // Use default value
            outputCells[j] = mapping.defaultValues[headerName]?.toString() ?? '';
          }
        }

        outputLines.add(outputCells.join(','));
      }

      return outputLines.join('\n');
    } catch (e) {
      if (e is CSVMappingError) {
        rethrow;
      }
      throw CSVMappingError('Failed to apply mapping: ${e.toString()}');
    }
  }

  Future<void> importData() async {
    state = state.copyWith(isLoading: true);
    try {
      final file = await CSVFilePicker.pickCSVFile();
      if (file != null) {
        final selectedMapping = state.availableMappings
          .firstWhere((m) => m.name == state.selectedMapping,
            orElse: () => throw CSVMappingError('No mapping selected'));
        
        final csvContent = await file.readAsString();
        final transformedCsv = await _applyMapping(csvContent, selectedMapping);
        
        await SossoldiDatabase.instance.importFromCSVContent(transformedCsv);
        state = state.copyWith(showSuccess: true);
      } else {
        state = state.copyWith();
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> exportData() async {
    state = BackupState(isLoading: true);
    try {
      final csv = await SossoldiDatabase.instance.exportToCSV();
      final filePath = await CSVFilePicker.saveCSVFile(csv);
      state = BackupState(
        showSuccess: filePath != null,
        errorMessage: filePath != null ? null : 'Export cancelled'
      );
    } catch (e) {
      state = BackupState(errorMessage: e.toString());
    }
  }

  void resetState() {
    state = BackupState();
  }
}
