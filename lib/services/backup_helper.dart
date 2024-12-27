import 'dart:convert';
import 'dart:io';
import 'package:build_growth_mobile/models/transaction.dart';
import 'package:build_growth_mobile/models/user_backup.dart';
import 'package:build_growth_mobile/models/user_token.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

const _scopes = ['https://www.googleapis.com/auth/drive.file'];

class GoogleDriveBackupHelper {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: _scopes);
  static auth.AuthClient? _authClient;

  static String? main_folder_id;
  static String? image_folder_id;

  static int total_file = 0;
  static int current_file = 0;
  static bool backup_running = false;

  /// Initialize function: Sign in the user and set up necessary folders
  static Future<bool> initialize() async {
    var status1 = await signIn();
    var status2 = await checkAndCreateFolders();

    return status1 && status2;
  }

  static final folder_name =
      'Build_Growth_${UserToken.user_code?.substring(10) ?? '_Data'}';

  /// Sign in the user using Google Sign-In
  static Future<bool> signIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print("User canceled the sign-in process");
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final auth.AccessCredentials credentials = auth.AccessCredentials(
        auth.AccessToken('Bearer', googleAuth.accessToken!,
            DateTime.now().toUtc().add(Duration(hours: 1))),
        googleAuth.accessToken,
        _scopes,
      );

      _authClient = await auth.authenticatedClient(http.Client(), credentials);
      return true;
      print("User signed in successfully");
    } catch (e) {
      print("Sign-in error: $e");
      return false;
    }
  }

  /// Check and create the "Build_Growth_{user_id}" folder and the "images" subfolder
  static Future<bool> checkAndCreateFolders() async {
    if (_authClient == null) {
      print("User is not authenticated");
      return false;
    }

    try {
      final mainFolderId = await createFolder(folder_name);

      main_folder_id = mainFolderId;
      if (main_folder_id != null) {
        image_folder_id =
            await createFolder('images', parentFolderId: main_folder_id);
      }

      return true;
    } catch (e) {
      print("Error creating folders: $e");
      return false;
    }
  }

  /// Create a folder in Google Drive if it does not exist
  static Future<String?> createFolder(String folderName,
      {String? parentFolderId}) async {
    final folderId = await getFolderId(folderName);
    if (folderId != null) return folderId;

    if (_authClient == null) {
      print("User is not authenticated");
      return null;
    }

    try {
      final driveApi = ga.DriveApi(_authClient!);
      final folder = ga.File()
        ..name = folderName
        ..mimeType = 'application/vnd.google-apps.folder'
        ..parents = parentFolderId != null ? [parentFolderId] : [];

      final createdFolder = await driveApi.files.create(folder);
      print("Folder created with ID: ${createdFolder.id}");
      return createdFolder.id;
    } catch (e) {
      print("Error creating folder: $e");
      return null;
    }
  }

  /// Get the folder ID if the folder exists
  static Future<String?> getFolderId(String folderName) async {
    if (_authClient == null) {
      print("User is not authenticated");
      return null;
    }

    try {
      final driveApi = ga.DriveApi(_authClient!);
      final fileList = await driveApi.files.list(
        q: "mimeType = 'application/vnd.google-apps.folder' and name = '$folderName'",
      );

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        return fileList.files!.first.id;
      }
      return null;
    } catch (e) {
      print("Error checking folder: $e");
      return null;
    }
  }

  static Future<bool> updateJsonFile(String folderId,
      Map<String, dynamic> newBackupData, String jsonFileName) async {
    if (_authClient == null) {
      print("User is not authenticated");
      return false;
    }

    try {
      final driveApi = ga.DriveApi(_authClient!);
      List<Map<String, dynamic>> existingData = [];

      // Check if the file exists in the folder
      final fileList = await driveApi.files.list(
        q: "name = '$jsonFileName' and '$folderId' in parents",
      );

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        // File exists, download its content
        final fileId = fileList.files!.first.id!;
        final media = await driveApi.files
            .get(fileId, downloadOptions: ga.DownloadOptions.fullMedia);

        if (media is ga.Media) {
          final tempFile =
              File('${(await getTemporaryDirectory()).path}/$jsonFileName');
          final fileSink = tempFile.openWrite();
          await media.stream.pipe(fileSink);
          await fileSink.close();

          // Read the file content and parse JSON as a list
          final existingJson = await tempFile.readAsString();
          existingData =
              List<Map<String, dynamic>>.from(jsonDecode(existingJson));

          // Delete the temporary file after reading
          tempFile.deleteSync();
        }
      }

      // Add the new backup data
      existingData.add(newBackupData);

      // Sort by the 'backup_at' datetime in descending order (most recent first)
      existingData.sort((a, b) {
        DateTime dateA = DateTime.parse(a['backup_at']);
        DateTime dateB = DateTime.parse(b['backup_at']);
        return dateB.compareTo(dateA);
      });

      // Keep only the most recent 2 backups plus the new one
      existingData = existingData.take(3).toList();

      // Create a temporary file with the updated JSON data
      final tempFile =
          File('${(await getTemporaryDirectory()).path}/$jsonFileName')
            ..writeAsStringSync(jsonEncode(existingData));

      // Upload the updated file to Google Drive
      await uploadFile(tempFile, folderId, isOverwrite: true);

      // Delete the temporary file
      tempFile.deleteSync();

      print(
          "JSON file '$jsonFileName' updated successfully with the latest backup.");
      return true;
    } catch (e) {
      print("Error updating JSON file: $e");
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> readJsonFile(
      {String jsonFileName = 'backup_info.json'}) async {
    String folderId = main_folder_id ?? '';
    if (_authClient == null) {
      print("User is not authenticated");
      return [];
    }

    try {
      final driveApi = ga.DriveApi(_authClient!);
      List<Map<String, dynamic>> jsonData = [];

      // Check if the file exists in the folder
      final fileList = await driveApi.files.list(
        q: "name = '$jsonFileName' and '$folderId' in parents",
      );

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        // File exists, download its content
        final fileId = fileList.files!.first.id!;
        final media = await driveApi.files
            .get(fileId, downloadOptions: ga.DownloadOptions.fullMedia);

        if (media is ga.Media) {
          final tempFile =
              File('${(await getTemporaryDirectory()).path}/$jsonFileName');
          final fileSink = tempFile.openWrite();
          await media.stream.pipe(fileSink);
          await fileSink.close();

          // Read the file content and parse JSON as a list
          final existingJson = await tempFile.readAsString();
          jsonData = List<Map<String, dynamic>>.from(jsonDecode(existingJson));

          // Delete the temporary file after reading
          tempFile.deleteSync();

          print("JSON file '$jsonFileName' read successfully.");
        }
      } else {
        print("JSON file '$jsonFileName' does not exist in the folder.");
      }

      return jsonData;
    } catch (e) {
      print("Error reading JSON file: $e");
      return [];
    }
  }

  /// Upload a file to Google Drive
  static Future<void> uploadFile(File file, String folderId,
      {bool isOverwrite = false}) async {
    if (_authClient == null) {
      print("User is not authenticated");
      return;
    }

    try {
      final driveApi = ga.DriveApi(_authClient!);
      final fileName = path.basename(file.path);

      // Check if the file already exists in the folder
      final fileList = await driveApi.files.list(
        q: "name = '$fileName' and '$folderId' in parents",
      );

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        if (isOverwrite) {
          // Delete the existing file before uploading the new one
          await driveApi.files.delete(fileList.files!.first.id!);
          print("Existing file '$fileName' deleted.");
        } else {
          // Skip the upload if isOverwrite is false
          print("File '$fileName' already exists. Skipping upload.");
          return;
        }
      }

      // Upload the file
      final fileMetadata = ga.File()
        ..name = fileName
        ..parents = [folderId];
      final media = ga.Media(file.openRead(), file.lengthSync());

      final uploadedFile =
          await driveApi.files.create(fileMetadata, uploadMedia: media);
      print(
          "File '$fileName' uploaded successfully with ID: ${uploadedFile.id}");
    } catch (e) {
      print("Error uploading file: $e");
    }
  }

  static Future<void> startBackup() async {
    if (main_folder_id == null) {
      await initialize();
    }

    if (main_folder_id == null) {
      return;
    }
    await signIn();

    backup_running = true;

    var data = await UserBackup.getData();
    var status2 =
        await updateJsonFile(main_folder_id!, data, 'backup_info.json');

    var status1 = await uploadAllImages();

    backup_running = false;
    if (status2 || status1) {
      UserBackup.lastBackUpTime = DateTime.now();
      UserToken.save();
    }
  }

  static Future<void> startRestore() async {
    if (main_folder_id == null) {
      await initialize();
    }

    if (main_folder_id == null) {
      return;
    }
    await signIn();

    backup_running = true;

    var status = await downloadAllImages();

    backup_running = false;
  }

  /// Upload all images from the application directory to Google Drive
  static Future<bool> uploadAllImages() async {
    if (_authClient == null) {
      print("User is not authenticated");
      return false;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      final imageFiles = Directory(dir.path)
          .listSync()
          .where((file) =>
              file is File &&
              (file.path.endsWith('.jpg') ||
                  file.path.endsWith('.png') ||
                  file.path.endsWith('.jpeg')))
          .toList();

      total_file = imageFiles.length;
      current_file = 0;
      if (main_folder_id != null) {
        final imagesFolderId =
            await createFolder('images', parentFolderId: main_folder_id);
        if (imagesFolderId != null) {
          for (var file in imageFiles) {
            if (file is File) {
              await uploadFile(file, imagesFolderId);
              current_file++;
            }
          }
        }
      }

      total_file = 0;
      current_file = 0;
      return true;
    } catch (e) {
      print("Error uploading images: $e");
      return false;
    }
  }

  static Future<bool> uploadTransactionImage(Transaction transaction) async {
    if (_authClient == null) {
      print("User is not authenticated");
      return false;
    }

    try {
      // Check if the transaction has an image
      if (transaction.image == null || transaction.image!.isEmpty) {
        print("No image found for this transaction");
        return false;
      }

      // Verify the image file exists
      final imageFile = File(transaction.image!);
      if (!await imageFile.exists()) {
        print("Image file does not exist: ${transaction.image}");
        return false;
      }

      // Create or get the images folder
      if (main_folder_id != null) {
        final imagesFolderId = await createFolder('images',
            parentFolderId: main_folder_id);

        if (imagesFolderId != null) {
          // Generate a unique filename using transaction details
          // String fileName =
          //     'transaction_${transaction.id}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';

          // Upload the file
          final uploadedFile = await uploadFile(
            imageFile,
            imagesFolderId,
          );

          print("Transaction image uploaded successfully");
          return true;
        }
      }

      return false;
    } catch (e) {
      print("Error uploading transaction image: $e");
      return false;
    }
  }

  static Future<bool> downloadAllImages() async {
    if (_authClient == null) {
      print("User is not authenticated");
      return false;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      final localFiles = Directory(dir.path)
          .listSync()
          .where((file) =>
              file is File &&
              (file.path.endsWith('.jpg') ||
                  file.path.endsWith('.png') ||
                  file.path.endsWith('.jpeg')))
          .map((file) => path.basename(file.path))
          .toSet(); // Store local file names in a set for quick lookup

      if (image_folder_id != null) {
        final driveApi = ga.DriveApi(_authClient!);

        final fileList = await driveApi.files.list(
          q: "'$image_folder_id' in parents and (mimeType='image/jpeg' or mimeType='image/png' or mimeType='image/gif' or mimeType='image/webp' or mimeType='image/bmp')",
          spaces: 'drive',
        );

        if (fileList.files != null && fileList.files!.isNotEmpty) {
          total_file = fileList.files!.length;
          current_file = 0;

          for (var driveFile in fileList.files!) {
            final fileName = driveFile.name ?? '';

            // Skip if the image already exists locally
            if (localFiles.contains(fileName)) {
              print("Image '$fileName' already exists locally. Skipping.");
              continue;
            }

            // Download the file from Google Drive
            final fileId = driveFile.id!;
            final media = await driveApi.files
                .get(fileId, downloadOptions: ga.DownloadOptions.fullMedia);

            if (media is ga.Media) {
              final localFilePath = path.join(dir.path, fileName);
              final localFile = File(localFilePath);
              final fileSink = localFile.openWrite();

              await media.stream.pipe(fileSink);
              await fileSink.close();

              print("Image '$fileName' downloaded successfully.");
            }

            current_file++;
          }

          total_file = 0;
          current_file = 0;
        } else {
          print("No images found in the Google Drive folder.");
        }
      } else {
        print("Main folder ID is not set.");
        return false;
      }

      return true;
    } catch (e) {
      print("Error downloading images: $e");
      return false;
    }
  }

  /// Sign out the user
  static Future<void> signOut() async {
    await _googleSignIn.signOut();

    main_folder_id = null;
    image_folder_id = null;

    total_file = 0;
    current_file = 0;
    backup_running = false;
    print("User signed out successfully");
  }
}

// class DriveBackupWidget extends StatelessWidget {
//   final GoogleDriveBackup _driveBackup = GoogleDriveBackup();

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: Text('Google Drive Backup')),
//         body: Center(
//           child: ElevatedButton(
//             onPressed: () async {
//               await _driveBackup.initialize();
//               await _driveBackup.uploadAllImages();
//             },
//             child: Text('Authenticate and Upload Images'),
//           ),
//         ),
//       ),
//     );
//   }
// }
