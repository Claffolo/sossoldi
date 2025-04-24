import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/backup_provider.dart';

class BackupPage extends ConsumerStatefulWidget {
  const BackupPage({super.key});

  @override
  ConsumerState<BackupPage> createState() => _BackupPageState();
}

class BackupOption {
  final String title;
  final String description;
  final Future<void> Function()? action;
  final IconData icon;

  BackupOption({
    required this.title,
    required this.description,
    this.action,
    required this.icon,
  });

  BackupOption copyWith({
    String? title,
    String? description,
    Future<void> Function()? action,
    IconData? icon,
  }) {
    return BackupOption(
      title: title ?? this.title,
      description: description ?? this.description,
      action: action ?? this.action,
      icon: icon ?? this.icon,
    );
  }
}

class _BackupPageState extends ConsumerState<BackupPage> {
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                ),
                padding: EdgeInsets.all(16),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Success',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 24),
              TextButton(
                onPressed: () => {
                  Navigator.of(context).pop(),
                  ref.read(backupProvider.notifier).resetState(),
                },
                child: Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  late final List<BackupOption> options = [
    BackupOption(
      title: 'Import data',
      description: 'Import a CSV file to update your database',
      icon: Icons.upload_file,
    ),
    BackupOption(
      title: 'Export data',
      description: 'Save your data as a CSV file',
      icon: Icons.download,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final backupState = ref.watch(backupProvider);

    // Show success or error messages
    if (backupState.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(backupState.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      });
    } else if (!backupState.isLoading && backupState.showSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSuccessDialog();
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Manage your data',
          style: Theme.of(context)
              .textTheme
              .headlineLarge!
              .copyWith(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      body: backupState.isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListView.separated(
                      itemCount: options.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, i) {
                        final option = options[i];
                        return Card(
                          elevation: 2,
                          child: InkWell(
                            onTap: () {
                              if (i == 0) {
                                Navigator.pushNamed(context, '/backup-page/choose-import');
                              } else {
                                ref.read(backupProvider.notifier).exportData();
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Icon(
                                    option.icon,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: 32,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          option.title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge!
                                              .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          option.description,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
