import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/backup_provider.dart';

class ChooseImportType extends ConsumerStatefulWidget {
  const ChooseImportType({super.key});

  @override
  ConsumerState<ChooseImportType> createState() => _ChooseImportTypeState();
}

class _ChooseImportTypeState extends ConsumerState<ChooseImportType> {
  bool isFirstQuestion = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isFirstQuestion ? 'Choose Import Type' : 'Choose Import Source'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            if (!isFirstQuestion) {
              setState(() => isFirstQuestion = true);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isFirstQuestion
                  ? 'Do you want to import a previously Sossoldi exported file?'
                  : 'Do you want to import from an app or bank?',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    if (isFirstQuestion) {
                      await ref.read(backupProvider.notifier).importData();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/backup-page');
                      }
                    } else {
                      Navigator.pushReplacementNamed(context, '/backup-page/select-source');
                    }
                  },
                  child: Text('Yes'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (isFirstQuestion) {
                      setState(() => isFirstQuestion = false);
                    } else {
                      Navigator.pushReplacementNamed(context, '/settings');
                    }
                  },
                  child: Text('No'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
