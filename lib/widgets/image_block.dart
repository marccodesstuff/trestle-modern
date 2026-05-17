import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ImageBlock extends StatefulWidget {
  final String? imageUrl;

  const ImageBlock({super.key, this.imageUrl});

  @override
  _ImageBlockState createState() => _ImageBlockState();
}

class _ImageBlockState extends State<ImageBlock> {
  String? _imageUrl;
  bool _isLoading = false;
  double _imageHeight = 150;
  Alignment _alignment = Alignment.center;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showImageOptionsDialog,
      child: Container(
        height: _imageUrl != null ? _imageHeight : 150,
        color: Colors.grey[200],
        alignment: _alignment,
        child: _imageUrl == null
            ? _buildPlaceholder()
            : _buildImage(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          if (_isLoading) ...[
            const CircularProgressIndicator(),
          ] else const Text('Tap to add image'),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Image.network(
      _imageUrl!,
      fit: BoxFit.contain,
      alignment: _alignment,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(height: 8),
              Text('Failed to load image'),
            ],
          ),
        );
      },
    );
  }

  void _showAddImageDialog() {
    final imageUrlController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Insert Image URL'),
        content: TextField(
          controller: imageUrlController,
          decoration: InputDecoration(hintText: 'Enter image URL', isDense: true),
          autofocus: true,
          onChanged: (value) {
            if (widget.imageUrl != null) {
              _insertImage(widget.imageUrl!);
            } else if (value.isNotEmpty && value.startsWith('http')) {
              _insertImage(value);
            }
          },
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Insert'),
            onPressed: () {
              final url = imageUrlController.text.isNotEmpty ? imageUrlController.text : widget.imageUrl;
              if (url != null && url.isNotEmpty) {
                _insertImage(url);
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _insertImage(String imageUrl) async {
    if (imageUrl.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        setState(() {
          _imageUrl = imageUrl;
          _isLoading = false;
        });
      } else {
        _showSnackBar('Image cannot be found');
      }
    } catch (e) {
      _showSnackBar('Failed to load image: ${e.toString()}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showImageOptionsDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Image Options'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Height', style: TextStyle(fontSize: 12)),
              Slider(
                value: _imageHeight,
                min: 50,
                max: 400,
                divisions: 30,
                label: '${_imageHeight.round().toString()}px',
                onChanged: (value) {
                  setState(() => _imageHeight = value);
                },
              ),
              DropdownButton<Alignment>(
                value: _alignment,
                underline: const SizedBox(),
                items: [
                  DropdownMenuItem(
                    value: Alignment.centerLeft,
                    child: Row(children: [const Icon(Icons.format_align_left), const Text('Left')]),
                  ),
                  DropdownMenuItem(
                    value: Alignment.center,
                    child: Row(children: [const Icon(Icons.format_align_center), const Text('Center')]),
                  ),
                  DropdownMenuItem(
                    value: Alignment.centerRight,
                    child: Row(children: [const Icon(Icons.format_align_right), const Text('Right')]),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _alignment = value);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Apply'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
