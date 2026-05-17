import 'package:flutter/material.dart';
import '../services/appwrite_service.dart';
import '../widgets/note_card.dart';
import 'edit_document_page.dart';

class WelcomeScreen extends StatefulWidget {
  final String userName;

  const WelcomeScreen({super.key, required this.userName});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final AppWriteService _appWriteService = AppWriteService();
  List<Map<String, dynamic>> _recentDocuments = [];

  @override
  void initState() {
    super.initState();
    _fetchRecentDocuments();
  }

  Future<void> _fetchRecentDocuments() async {
    try {
      final documents = await _appWriteService.fetchRecentDocuments();
      if (mounted) {
        setState(() {
          _recentDocuments = documents;
        });
      }
    } catch (e) {
      print('Error fetching recent documents: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trestle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchRecentDocuments,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Welcome to Trestle, ${widget.userName}!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Recent Notes', style: TextStyle(fontSize: 18)),
            const Divider(),
            Expanded(
              child: _recentDocuments.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notes, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No recent notes found',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              'Tap the + button to create a new note',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _recentDocuments.length,
                      itemBuilder: (context, index) {
                        final document = _recentDocuments[index];
                        return NoteCard(
                          title: document['title'],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditDocumentPage(
                                  documentId: document['\$id'],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditDocumentPage(
                documentId: '',
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Note'),
      ),
    );
  }
}
