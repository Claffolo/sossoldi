import 'dart:convert';
import 'package:flutter/services.dart';

class CSVMapping {
  final String id;
  final String name;
  final String logoUrl;
  final Map<String, String> columnMap;
  final Map<String, Map<String, String>> valueMap;
  final Map<String, dynamic> defaultValues;
  
  const CSVMapping({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.columnMap,
    required this.valueMap,
    required this.defaultValues,
  });

  factory CSVMapping.fromJson(Map<String, dynamic> json) {
    return CSVMapping(
      id: json['id'] as String,
      name: json['name'] as String,
      logoUrl: json['logoUrl'] as String,
      columnMap: Map<String, String>.from(json['columnMap'] as Map),
      valueMap: Map<String, Map<String, String>>.from(
        (json['valueMap'] as Map).map(
          (key, value) => MapEntry(key, Map<String, String>.from(value as Map))
        ),
      ),
      defaultValues: Map<String, dynamic>.from(json['defaultValues'] as Map),
    );
  }

  static Future<List<CSVMapping>> loadMappings() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    
    final mappingPaths = manifestMap.keys
        .where((String key) => key.startsWith('assets/mappings/') && key.endsWith('.json'));
    
    final mappings = <CSVMapping>[];
    for (final path in mappingPaths) {
      final content = await rootBundle.loadString(path);
      final jsonData = json.decode(content);
      mappings.add(CSVMapping.fromJson(jsonData));
    }
    
    return mappings;
  }
}

class CSVMappingError implements Exception {
  final String message;
  final String? missingColumn;

  CSVMappingError(this.message, {this.missingColumn});

  @override
  String toString() => missingColumn != null 
    ? '$message (Missing column: $missingColumn)'
    : message;
}
