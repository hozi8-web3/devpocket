import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../api_tester/models/request_model.dart';
import '../../api_tester/models/response_model.dart';

class CollectionExportService {
  static const String _requestsBoxName = 'api_requests';
  static const String _collectionsBoxName = 'api_collections';

  /// Export all collections and requests to a JSON string
  static String exportToJson() {
    final requestsBox = Hive.box<String>(_requestsBoxName);
    final collectionsBox = Hive.box<String>(_collectionsBoxName);

    final List<Map<String, dynamic>> requestsList = requestsBox.values
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .toList();

    final List<Map<String, dynamic>> collectionsList = collectionsBox.values
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .toList();

    final exportData = {
      'version': '1.0',
      'exportDate': DateTime.now().toIso8601String(),
      'collections': collectionsList,
      'requests': requestsList,
    };

    return jsonEncode(exportData);
  }

  /// Trigger the export process: write to temp file and open share dialog
  static Future<void> exportAndShare(BuildContext context) async {
    try {
      final jsonString = exportToJson();
      final directory = await getTemporaryDirectory();
      
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
      final file = File('${directory.path}/devpocket_collections_$timestamp.json');
      
      await file.writeAsString(jsonString);

      if (context.mounted) {
        final box = context.findRenderObject() as RenderBox?;
        await Share.shareXFiles(
          [XFile(file.path)], 
          subject: 'DevPocket API Collections Backup',
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
        );
      }
    } catch (e) {
      debugPrint('Export failing: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Trigger the import process
  static Future<bool> importFromFile(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        
        final Map<String, dynamic> importData = jsonDecode(jsonString);
        
        // Basic validation
        if (!importData.containsKey('collections') || !importData.containsKey('requests')) {
          throw Exception('Invalid DevPocket backup format');
        }

        final requestsBox = Hive.box<String>(_requestsBoxName);
        final collectionsBox = Hive.box<String>(_collectionsBoxName);

        final rawCols = importData['collections'] as List;
        final rawReqs = importData['requests'] as List;

        // Upsert Collections by ID
        for (var rawCol in rawCols) {
          final col = CollectionModel.fromJson(rawCol);
          await collectionsBox.put(col.id, jsonEncode(col.toJson()));
        }

        // Upsert Requests by ID
        for (var rawReq in rawReqs) {
          final req = RequestModel.fromJson(rawReq);
          await requestsBox.put(req.id, jsonEncode(req.toJson()));
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Successfully imported collections!'), backgroundColor: Colors.green),
          );
        }
        return true;
      }
    } catch (e) {
      debugPrint('Import failing: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to import: $e'), backgroundColor: Colors.red),
        );
      }
    }
    return false;
  }
}
