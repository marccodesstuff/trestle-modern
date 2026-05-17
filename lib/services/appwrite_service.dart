import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';

/// Singleton service for AppWrite operations
class AppWriteService {
  // Singleton instance - create once, use everywhere
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
  Future<void> saveNewDocument(String title, List<Widget> blocks) async {
    try {
      if (_client == null) {
        print('AppWrite client not initialized');
        return;
      }

      // Convert blocks to map format for storage
      List<Map<String, dynamic>> blockData = blocks.map((block) {
        if (block is TextField) {
          return {
            'type': 'text',
            'content': block.controller.text,
            'maxLines': 3,
          };
        } else if (block is ImageBlock) {
          return {
            'type': 'image',
            'url': _getImageUrlFromBlock(block),
          };
        }
        return {} as Map<String, dynamic>;
      }).toList();

      // Convert to JSON string
      String blockDataJson = jsonEncode(blockData);

      // Create document
      final documentId = ID.unique();
      
      await _databases.createDocument(
        databaseId: 'trestle_notes',
        collectionId: 'trestle_docs',
        documentId: documentId,
        data: {
          'title': title,
          'content': blockDataJson,
          'date_created': DateTime.now().toIso8601String(),
          'date_updated': DateTime.now().toIso8601String(),
          'version': 1, // Semantic versioning for documents
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
      if (_client == null) {
        print('AppWrite client not initialized');
        return [];
      }

      final response = await _databases.listDocuments(
        databaseId: 'trestle_notes',
        collectionId: 'trestle_docs',
        queries: [
          Query.orderDesc('date_updated'),
          Query.limit(10), // Return top 10 most recent
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
      if (_client == null) {
        print('AppWrite client not initialized');
        return null;
      }

      final response = await _databases.getDocument(
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

  /// Helper to extract image URL from ImageBlock widget
  String? _getImageUrlFromBlock(ImageBlock block) {
    // Since we're working with Widget tree, we'll store null and fetch via HTTP
    // or implement proper serialization in the future
    return 'placeholder';
  }
}
