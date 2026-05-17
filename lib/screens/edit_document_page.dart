import 'package:flutter/material.dart';
import '../services/appwrite_service.dart';
import '../widgets/image_block.dart';
import 'dart:convert';

class EditDocumentPage extends StatefulWidget {
  final String documentId;
  final String? initialTitle;

  const EditDocumentPage({
    super.key,
    required this.documentId,
    this.initialTitle,
  });

  @override
  _EditDocumentPageState createState() => _EditDocumentPageState();
}

class _EditDocumentPageState extends State<EditDocumentPage> {
  final AppWriteService _appWriteService = AppWriteService();
  late TextEditingController _titleController;
  List<Widget> _blocks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeEditor();
  }

  void _initializeEditor() {
    _titleController = widget.initialTitle != null
        ? TextEditingController(text: widget.initialTitle!)
        : TextEditingController();
    _fetchDocument();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _fetchDocument() async {
    try {
      final document = await _appWriteService.fetchDocumentById(widget.documentId);
      if (document != null && mounted) {
        setState(() {
          _titleController = TextEditingController(text: document['title']);
          _blocks = _parseBlocks(document['content']);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching document: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load document')),
        );
      }
    }
  }

  List<Widget> _parseBlocks(String content) {
    try {
      final List<dynamic> blockData = jsonDecode(content);
      return blockData.map<Widget>((block) {
        if (block['type'] == 'text') {
          return TextField(
            controller: TextEditingController(text: block['content']),
            decoration: const InputDecoration(hintText: 'Enter text here'),
            maxLines: 3,
          );
        } else if (block['type'] == 'image') {
          return ImageBlock(imageUrl: block['url']);
        }
        return Container();
      }).toList();
    } catch (e) {
      print('Error parsing blocks: $e');
      return [];
    }
  }

  void _addTextBlock() {
    setState(() {
      _blocks.add(
        TextField(
          controller: TextEditingController(),
          decoration: InputDecoration(
            hintText: 'Enter text here',
            contentPadding: const EdgeInsets.all(8.0),
          ),
          maxLines: 3,
        ),
      );
    });
  }

  void _addImageBlock() {
    setState(() {
      _blocks.add(const ImageBlock());
    });
  }

  Future<void> _saveDocument() async {
    try {
      await _appWriteService.saveNewDocument(
        _titleController.text,
        _blocks,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document saved successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Error saving document: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _titleController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Document Title',
            border: InputBorder.none,
          ),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveDocument,
            tooltip: 'Save Document',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ReorderableListView(
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final item = _blocks.removeAt(oldIndex);
                  _blocks.insert(newIndex, item);
                });
              },
              children: _blocks.asMap().entries.map((entry) {
                final index = entry.key;
                final block = entry.value;
                return ReorderableWidget(
                  child: block,
                  index: index,
                );
              }).toList(),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTextBlock,
        icon: const Icon(Icons.add_circle),
        label: const Text('Add Text'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class ReorderableWidget extends StatelessWidget {
  final Widget child;
  final int index;

  const ReorderableWidget({super.key, required this.child, required this.index});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      key: ValueKey(index),
      child: Row(
        children: [
          Expanded(child: child),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_handle, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
