import 'dart:async';
import 'dart:io';
import 'package:build_growth_mobile/services/backup_helper.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class BackupPage extends StatefulWidget {
  @override
  _BackupPageState createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  static int totalFiles = 0;
  static int currentFile = 0;


  bool preparing = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startPeriodicTask();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Periodic task that runs every 500 ms to fetch the current progress.
  void _startPeriodicTask() {
    _timer = Timer.periodic(Duration(milliseconds: 200), (timer) async {
      await fetchBackupProgress();
    });
  }

  /// Mock function to fetch backup progress (replace with actual data source).
  Future<void> fetchBackupProgress() async {
    // Simulate fetching data from a data source.
    // Replace this with actual logic to fetch progress.
    setState(() {
      totalFiles = GoogleDriveBackupHelper.total_file;
      currentFile = GoogleDriveBackupHelper.current_file;
      preparing = totalFiles == 0  && preparing;
      if (totalFiles <= currentFile && !preparing) {
         _completeBackup();
        _timer?.cancel();
      }
    });

  }

  /// Function to display a notification when the backup completes.
  Future<void> _completeBackup() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Backup process completed successfully!')),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Backup Information'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (preparing) ...[
              Text('Calculating Total Files...'),
            ] else ...[
              Text(
                'Total Files: $totalFiles',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                'Current File: $currentFile',
                style: TextStyle(fontSize: 18),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
