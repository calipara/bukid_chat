import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../image_upload.dart';

class PlantingTip {
  final String id;
  final String title;
  final String content;
  final String cropType; // 'Corn', 'Palay', or 'Both'
  final String category;
  final String imageKeyword;
  final DateTime createdDate;

  PlantingTip({
    required this.id,
    required this.title,
    required this.content,
    required this.cropType,
    required this.category,
    required this.imageKeyword,
    required this.createdDate,
  });
}

class PlantingTipsScreen extends StatefulWidget {
  const PlantingTipsScreen({Key? key}) : super(key: key);

  @override
  _PlantingTipsScreenState createState() => _PlantingTipsScreenState();
}

class _PlantingTipsScreenState extends State<PlantingTipsScreen> {
  List<PlantingTip> _tips = [];
  String _filterCropType = 'All';
  String _filterCategory = 'All';
  bool _isAdding = false;
  bool _isEditing = false;
  PlantingTip? _selectedTip;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _imageKeywordController = TextEditingController();
  String _selectedCropType = 'Corn';
  String _selectedCategory = 'Land Preparation';

  @override
  void initState() {
    super.initState();
    // Load sample tips
    _loadSampleTips();
  }

  void _loadSampleTips() {
    _tips = [
      PlantingTip(
        id: '1',
        title: 'Optimal Time for Rice Planting',
        content: 'For higher yields, plant rice during the early wet season (May-June) or early dry season (November-December). This timing minimizes exposure to extreme weather and optimizes growth conditions.',
        cropType: 'Palay',
        category: 'Planting',
        imageKeyword: 'Rice Planting Filipino Farmer',
        createdDate: DateTime.now().subtract(const Duration(days: 20)),
      ),
      PlantingTip(
        id: '2',
        title: 'Corn Spacing Guidelines',
        content: 'For yellow corn, maintain 75cm between rows and 25cm between plants. This spacing allows proper root development and maximizes sunlight exposure for each plant.',
        cropType: 'Corn',
        category: 'Planting',
        imageKeyword: 'Corn Field Rows',
        createdDate: DateTime.now().subtract(const Duration(days: 15)),
      ),
      PlantingTip(
        id: '3',
        title: 'Pest Management for Rice Fields',
        content: 'Regularly inspect rice plants for signs of stem borers and rice bugs. Early detection allows for targeted control measures. Consider introducing ducks to rice paddies as they naturally control pests without chemicals.',
        cropType: 'Palay',
        category: 'Pest Management',
        imageKeyword: 'Rice Field Pest Management',
        createdDate: DateTime.now().subtract(const Duration(days: 10)),
      ),
      PlantingTip(
        id: '4',
        title: 'Soil Preparation for Corn',
        content: 'Plow the land 2-3 times and harrow 2-3 times to achieve fine tilth. Properly prepared soil ensures good seed-to-soil contact, promoting uniform germination and strong early growth.',
        cropType: 'Corn',
        category: 'Land Preparation',
        imageKeyword: 'Soil Preparation Corn Field',
        createdDate: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _imageKeywordController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _titleController.text = '';
    _contentController.text = '';
    _imageKeywordController.text = '';
    _selectedCropType = 'Corn';
    _selectedCategory = 'Land Preparation';
    _selectedTip = null;
  }

  void _prepareForEdit(PlantingTip tip) {
    _titleController.text = tip.title;
    _contentController.text = tip.content;
    _imageKeywordController.text = tip.imageKeyword;
    _selectedCropType = tip.cropType;
    _selectedCategory = tip.category;
    _selectedTip = tip;
  }

  void _showAddEditForm({PlantingTip? tipToEdit}) {
    setState(() {
      if (tipToEdit != null) {
        _isEditing = true;
        _isAdding = false;
        _prepareForEdit(tipToEdit);
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

  void _saveTip() {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (_isEditing && _selectedTip != null) {
        // Update existing tip
        final index = _tips.indexWhere((t) => t.id == _selectedTip!.id);
        if (index != -1) {
          setState(() {
            _tips[index] = PlantingTip(
              id: _selectedTip!.id,
              title: _titleController.text,
              content: _contentController.text,
              cropType: _selectedCropType,
              category: _selectedCategory,
              imageKeyword: _imageKeywordController.text,
              createdDate: _selectedTip!.createdDate,
            );
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tip updated successfully')),
          );
        }
      } else {
        // Add new tip
        setState(() {
          _tips.add(PlantingTip(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: _titleController.text,
            content: _contentController.text,
            cropType: _selectedCropType,
            category: _selectedCategory,
            imageKeyword: _imageKeywordController.text,
            createdDate: DateTime.now(),
          ));
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tip added successfully')),
        );
      }

      // Close form
      setState(() {
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

  void _deleteTip(PlantingTip tip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "${tip.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _tips.removeWhere((t) => t.id == tip.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tip deleted successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  List<PlantingTip> get _filteredTips {
    return _tips.where((tip) {
      bool matchesCropType = _filterCropType == 'All' || tip.cropType == _filterCropType;
      bool matchesCategory = _filterCategory == 'All' || tip.category == _filterCategory;
      return matchesCropType && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planting Tips'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filters and add button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildFilterDropdown(
                    'Crop',
                    _filterCropType,
                    ['All', 'Corn', 'Palay', 'Both'],
                    (value) {
                      setState(() {
                        _filterCropType = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: _buildFilterDropdown(
                    'Category',
                    _filterCategory,
                    ['All', 'Land Preparation', 'Planting', 'Maintenance', 'Pest Management', 'Harvesting'],
                    (value) {
                      setState(() {
                        _filterCategory = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16.0),
                if (!_isAdding && !_isEditing)
                  ElevatedButton.icon(
                    onPressed: () => _showAddEditForm(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Tip'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  ),
              ],
            ),
          ),
          
          // Add/Edit form
          if (_isAdding || _isEditing) _buildAddEditForm(),
          
          // Tips list
          Expanded(
            child: _filteredTips.isEmpty
                ? Center(
                    child: Text(
                      'No planting tips available for current filters.',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _filteredTips.length,
                    itemBuilder: (context, index) {
                      final tip = _filteredTips[index];
                      return _buildTipCard(tip);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0),
        ),
        const SizedBox(height: 4.0),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTipCard(PlantingTip tip) {
    Color categoryColor;
    IconData categoryIcon;
    
    // Set color and icon based on category
    switch (tip.category) {
      case 'Land Preparation':
        categoryColor = Colors.brown;
        categoryIcon = Icons.terrain;
        break;
      case 'Planting':
        categoryColor = Colors.green;
        categoryIcon = Icons.agriculture;
        break;
      case 'Maintenance':
        categoryColor = Colors.blue;
        categoryIcon = Icons.water_drop;
        break;
      case 'Pest Management':
        categoryColor = Colors.red;
        categoryIcon = Icons.bug_report;
        break;
      case 'Harvesting':
        categoryColor = Colors.orange;
        categoryIcon = Icons.agriculture;
        break;
      default:
        categoryColor = Colors.purple;
        categoryIcon = Icons.eco;
    }
    
    // Set crop type icon and color
    Color cropColor = tip.cropType == 'Corn' ? Colors.amber[800]! : Colors.green[800]!;
    IconData cropIcon = tip.cropType == 'Corn' ? Icons.grass : Icons.grain;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image header with category badge
          Stack(
            children: [
              Container(
                height: 140,
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
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        categoryIcon,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        tip.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: cropColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        cropIcon,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        tip.cropType,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.title,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  tip.content,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey[800],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Image Keyword: ${tip.imageKeyword}',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () => _showAddEditForm(tipToEdit: tip),
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit'),
                        ),
                        const SizedBox(width: 8.0),
                        TextButton.icon(
                          onPressed: () => _deleteTip(tip),
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
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
                _isEditing ? 'Edit Planting Tip' : 'Add New Planting Tip',
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
              
              // Content
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  hintText: 'Provide detailed instructions...',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter content';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              
              // Crop Type
              DropdownButtonFormField<String>(
                value: _selectedCropType,
                decoration: const InputDecoration(
                  labelText: 'Crop Type',
                  prefixIcon: Icon(Icons.agriculture),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Corn', child: Text('Corn')),
                  DropdownMenuItem(value: 'Palay', child: Text('Palay (Rice)')),
                  DropdownMenuItem(value: 'Both', child: Text('Both Crops')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCropType = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a crop type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              
              // Category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Land Preparation', child: Text('Land Preparation')),
                  DropdownMenuItem(value: 'Planting', child: Text('Planting')),
                  DropdownMenuItem(value: 'Maintenance', child: Text('Maintenance')),
                  DropdownMenuItem(value: 'Pest Management', child: Text('Pest Management')),
                  DropdownMenuItem(value: 'Harvesting', child: Text('Harvesting')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              
              // Image Keyword
              TextFormField(
                controller: _imageKeywordController,
                decoration: const InputDecoration(
                  labelText: 'Image Keyword',
                  hintText: 'e.g., Rice Planting Field Filipino',
                  prefixIcon: Icon(Icons.image_search),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an image keyword';
                  }
                  return null;
                },
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
                    onPressed: _saveTip,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                    child: Text(_isEditing ? 'Update Tip' : 'Add Tip'),
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