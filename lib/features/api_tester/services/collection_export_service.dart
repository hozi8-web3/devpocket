import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/services/toast_service.dart';
import '../../api_tester/models/request_model.dart';
import '../../api_tester/models/response_model.dart';
import '../utils/postman_parser.dart';

class CollectionExportService {
  static const String _requestsBoxName = 'api_saved_requests';
  static const String _collectionsBoxName = 'api_collections';

  /// Export all collections and requests to a JSON string
  static Future<String> exportToJson() async {
    final requestsBox = await Hive.openBox<String>(_requestsBoxName);
    final collectionsBox = await Hive.openBox<String>(_collectionsBoxName);

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
      final jsonString = await exportToJson();
      final directory = await getTemporaryDirectory();

      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')
          .first;
      final file =
          File('${directory.path}/devpocket_collections_$timestamp.json');

      await file.writeAsString(jsonString);

      if (context.mounted) {
        final box = context.findRenderObject() as RenderBox?;
        // ignore: deprecated_member_use
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'DevPocket API Collections Backup',
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
        );
      }
    } catch (e) {
      debugPrint('Export failing: $e');
      if (context.mounted) {
        ToastService.show(
          context,
          message: 'Failed to export: $e',
          type: ToastType.error,
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

        final requestsBox = await Hive.openBox<String>(_requestsBoxName);
        final collectionsBox = await Hive.openBox<String>(_collectionsBoxName);

        // Native DevPocket format check
        if (importData.containsKey('collections') &&
            importData.containsKey('requests')) {
          final rawCols = importData['collections'] as List;
          final rawReqs = importData['requests'] as List;

          for (var rawCol in rawCols) {
            final col = CollectionModel.fromJson(rawCol);
            await collectionsBox.put(col.id, jsonEncode(col.toJson()));
          }

          for (var rawReq in rawReqs) {
            final req = RequestModel.fromJson(rawReq);
            await requestsBox.put(req.id, jsonEncode(req.toJson()));
          }
        }
        // Postman v2.1 format check
        else if (PostmanCollectionParser.isPostmanCollection(importData)) {
          final result = PostmanCollectionParser.parse(importData);
          final col = result['collection'] as CollectionModel;
          final reqs = result['requests'] as List<RequestModel>;

          await collectionsBox.put(col.id, jsonEncode(col.toJson()));
          for (var req in reqs) {
            await requestsBox.put(req.id, jsonEncode(req.toJson()));
          }
        } else {
          throw Exception(
              'Invalid DevPocket backup or Postman collection format');
        }

        if (context.mounted) {
          ToastService.show(
            context,
            message: 'Successfully imported collections!',
            type: ToastType.success,
          );
        }
        return true;
      }
    } catch (e) {
      debugPrint('Import failing: $e');
      if (context.mounted) {
        ToastService.show(
          context,
          message: 'Failed to import: $e',
          type: ToastType.error,
        );
      }
    }
    return false;
  }
}
