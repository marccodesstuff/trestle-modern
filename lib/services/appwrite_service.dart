import 'package:appwrite/appwrite.dart';
import 'dart:convert';

/// Singleton service for AppWrite operations
class AppWriteService {
  static final AppWriteService _instance = AppWriteService._internal();
  
  factory AppWriteService() => _instance;
  
  AppWriteService._internal();
  
  Client? _client;
  Databases? _databases;

  /// Initialize AppWrite client (call once in main.dart or initState)
  Future<void> initClient({String endpoint = 'https://cloud.appwrite.io/v1'}) async {
    if (_client == null) {
      _client = Client()
        .setEndpoint(endpoint)
        .setProject('675448ef003e37a9488a');
      _databases = Databases(_client!);
    }
  }

  /// Create a new document
  Future<void> saveNewDocument(String title, List<dynamic> blocks) async {
    try {
      if (_client == null || _databases == null) {
        print('AppWrite client or databases not initialized');
        return;
      }

      // Convert blocks to map format for storage (simplified - manual construction needed in UI)
      List<Map<String, dynamic>> blockData = [];
      for (var block in blocks) {
        if (block is Map<String, dynamic>) {
          blockData.add(block);
        } else {
          print('Unsupported block type: ${block.runtimeType}');
        }
      }

      // Convert to JSON string
      String blockDataJson = jsonEncode(blockData);

      // Create document
      final documentId = ID.unique();
      
      await _databases!.createDocument(
        databaseId: 'trestle_notes',
        collectionId: 'trestle_docs',
        documentId: documentId,
        data: {
          'title': title,
          'content': blockDataJson,
          'date_created': DateTime.now().toIso8601String(),
          'date_updated': DateTime.now().toIso8601String(),
          'version': 1,
        },
      );

      print('Document saved successfully');
    } catch (e) {
      print('Error creating document: $e');
      rethrow;
    }
  }

  /// Fetch recent documents (most recently updated)
  Future<List<Map<String, dynamic>>> fetchRecentDocuments() async {
    try {
      if (_client == null || _databases == null) {
        print('AppWrite client or databases not initialized');
        return [];
      }

      final response = await _databases!.listDocuments(
        databaseId: 'trestle_notes',
        collectionId: 'trestle_docs',
        queries: [
          Query.orderDesc('date_updated'),
          Query.limit(10),
        ],
      );

      return response.documents.map((doc) => doc.data).toList();
    } catch (e) {
      print('Error fetching documents: $e');
      return [];
    }
  }

  /// Fetch a single document by ID
  Future<Map<String, dynamic>?> fetchDocumentById(String documentId) async {
    try {
      if (_client == null || _databases == null) {
        print('AppWrite client or databases not initialized');
        return null;
      }

      final response = await _databases!.getDocument(
        databaseId: 'trestle_notes',
        collectionId: 'trestle_docs',
        documentId: documentId,
      );

      return response.data;
    } catch (e) {
      print('Error fetching document: $e');
      return null;
    }
  }
}
