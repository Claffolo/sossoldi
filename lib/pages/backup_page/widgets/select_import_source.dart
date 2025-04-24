import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../providers/import_sources_provider.dart';
import '../../../providers/backup_provider.dart'; // Added import for backupProvider

class SelectImportSource extends ConsumerWidget {
  const SelectImportSource({super.key});

  Future<void> _pickFile(BuildContext context, WidgetRef ref, String sourceName) async {
    ref.read(backupProvider.notifier).selectMapping(sourceName);
    
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      await ref.read(backupProvider.notifier).importData();
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sources = ref.watch(filteredSourcesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Source'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => ref.read(filteredSourcesProvider.notifier).filter(value),
              decoration: InputDecoration(
                hintText: 'Search apps and banks...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: sources.length + 1, // +1 for the custom mapper option
              itemBuilder: (context, index) {
                if (index == sources.length) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: OutlinedButton(
                      onPressed: () => Navigator.pushNamed(context, '/backup-page/custom-mapper'),
                      child: Text("Can't find your app or bank? Click here to design your custom file mapper."),
                    ),
                  );
                }

                final source = sources[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Image.asset(
                      source.logoUrl,
                      width: 40,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.account_balance),
                    ),
                    title: Text(source.name),
                    onTap: () => _pickFile(context, ref, source.name),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
