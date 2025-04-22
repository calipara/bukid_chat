import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../models/news_model.dart';
import '../../image_upload.dart';

class NewsAdminScreen extends StatefulWidget {
  const NewsAdminScreen({Key? key}) : super(key: key);

  @override
  _NewsAdminScreenState createState() => _NewsAdminScreenState();
}

class _NewsAdminScreenState extends State<NewsAdminScreen> {
  List<AgricultureNewsModel> _newsList = [];
  bool _isAdding = false;
  bool _isEditing = false;
  int? _editingIndex;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  final _sourceController = TextEditingController();
  final _urlController = TextEditingController();
  String _imageUrl = '';

  @override
  void initState() {
    super.initState();
    // Load news data - in a real app, this would come from a provider or backend
    _newsList = NewsData.getAgricultureNews();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _sourceController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _titleController.text = '';
    _summaryController.text = '';
    _sourceController.text = 'Department of Agriculture';
    _urlController.text = '';
    _imageUrl = '';
    _editingIndex = null;
  }

  void _prepareForEdit(AgricultureNewsModel news, int index) {
    _titleController.text = news.title;
    _summaryController.text = news.summary;
    _sourceController.text = news.source;
    _urlController.text = news.fullArticleUrl;
    _imageUrl = news.imageUrl;
    _editingIndex = index;
  }

  void _showAddEditForm({AgricultureNewsModel? newsToEdit, int? index}) {
    setState(() {
      if (newsToEdit != null && index != null) {
        _isEditing = true;
        _isAdding = false;
        _prepareForEdit(newsToEdit, index);
      } else {
        _isAdding = true;
        _isEditing = false;
        _resetForm();
      }
    });
  }

  void _cancelAddEdit() {
    setState(() {
      _isAdding = false;
      _isEditing = false;
      _resetForm();
    });
  }

  Future<void> _pickImage() async {
    try {
      final imageData = await ImageUploadHelper.pickImageFromGallery();
      if (imageData != null) {
        // In a real app, you would upload the image to a server and get a URL
        // For now, we'll just use a placeholder URL
        setState(() {
          _imageUrl = "Agriculture News Image";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image selected successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: $e')),
      );
    }
  }

  void _saveNews() {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Validate image URL
      if (_imageUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image')),
        );
        return;
      }

      // Create news model
      final news = AgricultureNewsModel(
        title: _titleController.text,
        summary: _summaryController.text,
        source: _sourceController.text,
        date: DateTime.now(),
        imageUrl: _imageUrl,
        fullArticleUrl: _urlController.text,
      );

      setState(() {
        if (_isEditing && _editingIndex != null) {
          // Update existing news
          _newsList[_editingIndex!] = news;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('News updated successfully')),
          );
        } else {
          // Add new news
          _newsList.add(news);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('News added successfully')),
          );
        }

        // Close form
        _isAdding = false;
        _isEditing = false;
        _resetForm();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _deleteNews(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "${_newsList[index].title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _newsList.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('News deleted successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Management'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Agriculture News & Updates',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!_isAdding && !_isEditing)
                  ElevatedButton.icon(
                    onPressed: () => _showAddEditForm(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add News'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  ),
              ],
            ),
          ),
          if (_isAdding || _isEditing) _buildAddEditForm(),
          Expanded(
            child: _newsList.isEmpty
                ? Center(
                    child: Text(
                      'No news available. Add your first news!',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _newsList.length,
                    itemBuilder: (context, index) {
                      final news = _newsList[index];
                      return _buildNewsCard(news, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(AgricultureNewsModel news, int index) {
    final dateFormat = DateFormat('MMM d, yyyy');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              image: DecorationImage(
                image: NetworkImage(
                  "https://images.unsplash.com/photo-1598030473096-21290804e1b2?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NDM3Mzk4OTJ8&ixlib=rb-4.0.3&q=80&w=1080",
                ),
                fit: BoxFit.cover,
              ),
            ),
            alignment: Alignment.topRight,
            child: Container(
              margin: const EdgeInsets.all(12.0),
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                news.source,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  news.title,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  news.summary,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Published: ${dateFormat.format(news.date)}',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'URL: ${news.fullArticleUrl.split('/').last}...',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showAddEditForm(newsToEdit: news, index: index),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                    const SizedBox(width: 8.0),
                    TextButton.icon(
                      onPressed: () => _deleteNews(index),
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddEditForm() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditing ? 'Edit News Article' : 'Add New News Article',
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 16.0),
              
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              
              // Summary
              TextFormField(
                controller: _summaryController,
                decoration: const InputDecoration(
                  labelText: 'Summary',
                  prefixIcon: Icon(Icons.short_text),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a summary';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              
              // Source
              TextFormField(
                controller: _sourceController,
                decoration: const InputDecoration(
                  labelText: 'Source',
                  prefixIcon: Icon(Icons.source),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a source';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              
              // URL
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'Full Article URL',
                  prefixIcon: Icon(Icons.link),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a URL';
                  }
                  if (!value.startsWith('http')) {
                    return 'Please enter a valid URL starting with http:// or https://';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              
              // Image
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: Text(_imageUrl.isEmpty ? 'Select Image' : 'Change Image'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  if (_imageUrl.isNotEmpty)
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(
                            "https://images.unsplash.com/photo-1598030473096-21290804e1b2?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NDM3Mzk4OTJ8&ixlib=rb-4.0.3&q=80&w=1080",
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24.0),
              
              // Form buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _cancelAddEdit,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: _saveNews,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                    child: Text(_isEditing ? 'Update News' : 'Add News'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}