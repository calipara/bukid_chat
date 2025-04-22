import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/farm_model.dart';
import '../../providers/farm_provider.dart';
import '../../theme/app_theme.dart';
import '../../constants/app_constants.dart';
import '../../utils/formatter_utils.dart';
import '../../utils/date_utils.dart';


import 'farm_map_screen.dart';

class FarmProfileScreen extends StatefulWidget {
  const FarmProfileScreen({Key? key}) : super(key: key);

  @override
  _FarmProfileScreenState createState() => _FarmProfileScreenState();
}

class _FarmProfileScreenState extends State<FarmProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // Form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ownerController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _soilTypeController = TextEditingController();
  
  List<String> _selectedCrops = [];
  List<String> _selectedCropVarieties = [];
  bool _isEditing = false;
  String _editingFarmId = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Initialize crop types if empty
    _selectedCrops = ['Corn'];
    _updateCropVarieties();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _ownerController.dispose();
    _areaController.dispose();
    _locationController.dispose();
    _soilTypeController.dispose();
    super.dispose();
  }

  void _updateCropVarieties() {
    _selectedCropVarieties = [];
    for (var crop in _selectedCrops) {
      if (crop == 'Corn') {
        if (_selectedCropVarieties.isEmpty) {
          _selectedCropVarieties.add(AppConstants.cornVarieties.first);
        }
      } else if (crop == 'Palay (Rice)') {
        if (_selectedCropVarieties.isEmpty) {
          _selectedCropVarieties.add(AppConstants.palayVarieties.first);
        }
      }
    }
  }

  void _showAddFarmDialog() {
    _resetForm();
    showDialog(
      context: context,
      builder: (context) => _buildFarmDialog('Add New Farm'),
    );
  }

  void _showEditFarmDialog(FarmModel farm) {
    _resetForm();
    _nameController.text = farm.name;
    _ownerController.text = farm.owner;
    _areaController.text = farm.areaHectares.toString();
    _locationController.text = farm.location;
    _soilTypeController.text = farm.soilType;
    _selectedCrops = List.from(farm.crops);
    _selectedCropVarieties = List.from(farm.cropVarieties);
    _isEditing = true;
    _editingFarmId = farm.id;
    
    showDialog(
      context: context,
      builder: (context) => _buildFarmDialog('Edit Farm'),
    );
  }

  void _resetForm() {
    _nameController.clear();
    _ownerController.clear();
    _areaController.clear();
    _locationController.clear();
    _soilTypeController.clear();
    _selectedCrops = ['Corn'];
    _updateCropVarieties();
    _isEditing = false;
    _editingFarmId = '';
  }

  Widget _buildFarmDialog(String title) {
    return AlertDialog(
      title: Text(title),
      content: Container(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Pangalan ng Bukid',
                    prefixIcon: Icon(Icons.landscape),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Paki-lagay ang pangalan ng bukid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ownerController,
                  decoration: const InputDecoration(
                    labelText: 'Pangalan ng May-ari',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Paki-lagay ang pangalan ng may-ari';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _areaController,
                  decoration: const InputDecoration(
                    labelText: 'Sukat (ektarya)',
                    prefixIcon: Icon(Icons.area_chart),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Paki-lagay ang sukat';
                    }
                    try {
                      final area = double.parse(value);
                      if (area <= 0) {
                        return 'Ang sukat ay dapat mas malaki sa 0';
                      }
                    } catch (e) {
                      return 'Paki-lagay ang tamang numero';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Lokasyon',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Paki-lagay ang lokasyon';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Soil Type Dropdown
                DropdownButtonFormField<String>(
                  value: _soilTypeController.text.isEmpty ? 'I don\'t know' : _soilTypeController.text,
                  decoration: const InputDecoration(
                    labelText: 'Uri ng Lupa',
                    prefixIcon: Icon(Icons.grass),
                  ),
                  items: [
                    'Clay',
                    'Sandy',
                    'Loamy',
                    'Silty',
                    'Peaty',
                    'Chalky',
                    'I don\'t know',
                  ].map((soil) {
                    return DropdownMenuItem<String>(
                      value: soil,
                      child: Text(soil),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _soilTypeController.text = value ?? 'I don\'t know';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Paki-lagay ang uri ng lupa';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Mga Pananim', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    // Dropdown for crop selection
                    DropdownButtonFormField<String>(
                      value: _selectedCrops.isNotEmpty ? _selectedCrops.first : AppConstants.cropTypes.first,
                      decoration: const InputDecoration(
                        labelText: 'Piliin ang Pananim',
                        prefixIcon: Icon(Icons.agriculture),
                        border: OutlineInputBorder(),
                      ),
                      items: AppConstants.cropTypes.map((crop) {
                        return DropdownMenuItem<String>(
                          value: crop,
                          child: Row(
                            children: [
                              Icon(
                                crop.contains('Corn') ? Icons.grass : Icons.grain,
                                color: crop.contains('Corn') ? Colors.amber[800] : Colors.green[800],
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(crop),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCrops = [value];
                            _updateCropVarieties();
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Uri ng Pananim', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _getAvailableVarieties().map((variety) {
                        final isSelected = _selectedCropVarieties.contains(variety);
                        return FilterChip(
                          label: Text(variety),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedCropVarieties.add(variety);
                              } else {
                                _selectedCropVarieties.remove(variety);
                              }
                            });
                          },
                          backgroundColor: Colors.grey[200],
                          selectedColor: AppTheme.secondaryColor.withOpacity(0.2),
                          checkmarkColor: AppTheme.secondaryColor,
                          avatar: isSelected
                              ? const Icon(Icons.check, size: 18, color: AppTheme.secondaryColor)
                              : null,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Kanselahin'),
        ),
        ElevatedButton(
          onPressed: () => _saveFarm(context),
          child: Text(_isEditing ? 'I-update' : 'I-save'),
        ),
      ],
    );
  }

  List<String> _getAvailableVarieties() {
    List<String> varieties = [];
    for (var crop in _selectedCrops) {
      if (crop == 'Corn') {
        varieties.addAll(AppConstants.cornVarieties);
      } else if (crop == 'Palay (Rice)') {
        varieties.addAll(AppConstants.palayVarieties);
      }
    }
    return varieties;
  }

  void _saveFarm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      
      if (_selectedCrops.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Piliin kahit isang pananim')),
        );
        return;
      }
      
      if (_selectedCropVarieties.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Piliin kahit isang uri ng pananim')),
        );
        return;
      }
      
      // Create farm object
      final farm = FarmModel(
        id: _isEditing ? _editingFarmId : farmProvider.generateId(),
        name: _nameController.text,
        owner: _ownerController.text,
        areaHectares: double.parse(_areaController.text),
        location: _locationController.text,
        crops: _selectedCrops,
        cropVarieties: _selectedCropVarieties,
        soilType: _soilTypeController.text,
        fields: _isEditing 
            ? farmProvider.farms.firstWhere((f) => f.id == _editingFarmId).fields 
            : [],
        coordinates: {
          'lat': 14.5995, // Default to Philippines (replace with actual farm coordinates)
          'lng': 120.9842,
        },
      );
      
      if (_isEditing) {
        farmProvider.updateFarm(farm);
      } else {
        farmProvider.addFarm(farm);
      }
      
      Navigator.pop(context);
    }
  }

  void _showAddFieldDialog(FarmModel farm) {
    final fieldNameController = TextEditingController();
    final fieldAreaController = TextEditingController();
    String cropType = farm.crops.first;
    String cropVariety = farm.cropVarieties.first;
    final plantingDateController = TextEditingController(
      text: DateTimeUtils.formatDate(DateTime.now()),
    );
    final harvestDateController = TextEditingController(
      text: DateTimeUtils.formatDate(
        DateTime.now().add(const Duration(days: 120)),
      ),
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dagdag Bagong Bukid'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fieldNameController,
                decoration: const InputDecoration(
                  labelText: 'Pangalan ng Bukid',
                  prefixIcon: Icon(Icons.crop_square),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: fieldAreaController,
                decoration: const InputDecoration(
                  labelText: 'Sukat (ektarya)',
                  prefixIcon: Icon(Icons.area_chart),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: cropType,
                decoration: const InputDecoration(
                  labelText: 'Uri ng Pananim',
                  prefixIcon: Icon(Icons.grass),
                ),
                items: farm.crops.map((crop) {
                  return DropdownMenuItem<String>(
                    value: crop,
                    child: Text(crop),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    cropType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: cropVariety,
                decoration: const InputDecoration(
                  labelText: 'Klase ng Pananim',
                  prefixIcon: Icon(Icons.eco),
                ),
                items: farm.cropVarieties.map((variety) {
                  return DropdownMenuItem<String>(
                    value: variety,
                    child: Text(variety),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    cropVariety = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: plantingDateController,
                decoration: const InputDecoration(
                  labelText: 'Petsa ng Pagtatanim',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (pickedDate != null) {
                    plantingDateController.text = DateTimeUtils.formatDate(pickedDate);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: harvestDateController,
                decoration: const InputDecoration(
                  labelText: 'Inaasahang Petsa ng Pag-aani',
                  prefixIcon: Icon(Icons.event),
                ),
                readOnly: true,
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 120)),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (pickedDate != null) {
                    harvestDateController.text = DateTimeUtils.formatDate(pickedDate);
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kanselahin'),
          ),
          ElevatedButton(
            onPressed: () {
              // Validate inputs
              if (fieldNameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Paki-lagay ang pangalan ng bukid')),
                );
                return;
              }
              if (fieldAreaController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Paki-lagay ang sukat ng bukid')),
                );
                return;
              }
              
              try {
                final area = double.parse(fieldAreaController.text);
                if (area <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ang sukat ay dapat mas malaki sa 0')),
                  );
                  return;
                }
                
                // Create field
                final fieldId = DateTime.now().millisecondsSinceEpoch.toString() + 
                    Random().nextInt(10000).toString();
                
                final field = FieldModel(
                  id: fieldId,
                  name: fieldNameController.text,
                  areaHectares: area,
                  cropType: cropType,
                  cropVariety: cropVariety,
                  plantingDate: plantingDateController.text,
                  expectedHarvestDate: harvestDateController.text,
                  boundaries: [], // Empty boundaries to be set in map screen
                );
                
                // Add field to farm
                final farmProvider = Provider.of<FarmProvider>(context, listen: false);
                farmProvider.addField(farm.id, field);
                
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Paki-lagay ang tamang numero para sa sukat')),
                );
              }
            },
            child: const Text('I-save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile ng Bukid'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mga Bukid Ko'),
            Tab(text: 'Detalye ng Bukid'),
          ],
        ),
      ),
      body: Consumer<FarmProvider>(
        builder: (context, farmProvider, child) {
          if (farmProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildFarmsList(farmProvider),
              _buildFarmDetails(farmProvider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFarmDialog,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFarmsList(FarmProvider farmProvider) {
    if (farmProvider.farms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              "https://pixabay.com/get/g63407cbe764f8e1e5d886a0554e4164c56b1327e19ba839d5c46cb1a71b0d8d98cf4cd9af30b7a1dba1ba854e9e7f329b6461dfead6a95002ef15a1fcc56e38f_1280.jpg",
              height: 200,
              width: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            const Text(
              'No farms added yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first farm by tapping the + button',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _showAddFarmDialog,
              icon: const Icon(Icons.add),
              label: const Text('Dagdag Bagong Bukid'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: farmProvider.farms.length,
      itemBuilder: (context, index) {
        final farm = farmProvider.farms[index];
        final isSelected = farmProvider.selectedFarm?.id == farm.id;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: isSelected ? 4 : 2,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              farmProvider.setSelectedFarm(farm);
              _tabController.animateTo(1); // Switch to details tab
            },
            child: Column(
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(
                        "https://pixabay.com/get/g3e3a6610ed31b8ba43757c1b6ee6f8f0ce947070afd3b9f0dd610b6df61bebbdd203d7c3946a690aed45ab1ffc41e571263d579f373439559cd9193236f20df1_1280.jpg"
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: Text(
                          farm.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Selected',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              farm.location,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${farm.areaHectares} ha',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Crops',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  farm.crops.join(', '),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Fields',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  farm.fields.length.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Soil Type',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  farm.soilType,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _showEditFarmDialog(farm),
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryColor,
                                side: BorderSide(color: AppTheme.primaryColor),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                farmProvider.setSelectedFarm(farm);
                                _tabController.animateTo(1); // Switch to details tab
                              },
                              icon: const Icon(Icons.visibility),
                              label: const Text('View'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFarmDetails(FarmProvider farmProvider) {
    if (farmProvider.farms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              "https://pixabay.com/get/gf73e15ed9dfb83646b2a1bcd9915e7487f813d79e567b458c28d75422544655c99d4ee8fb0b5c5a065c54e4468c48aac13218abbd740074e10d3bb8493f2b32b_1280.jpg",
              height: 200,
              width: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            const Text(
              'No farms added yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create a farm first to see details',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _showAddFarmDialog,
              icon: const Icon(Icons.add),
              label: const Text('Dagdag Bagong Bukid'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    final farm = farmProvider.selectedFarm ?? farmProvider.farms.first;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Farm header card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(
                        "https://pixabay.com/get/g5fd2a46162d7d47a8995195078534ab0dfdf9ca291c5698fdd2e1f38653aab04493a78faeee18e013650e0f44f61c48b8cd11b6315d412573f30eecb80335cbc_1280.jpg"
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              farm.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _showEditFarmDialog(farm),
                            icon: const Icon(Icons.edit),
                            tooltip: 'Edit Farm',
                            color: AppTheme.primaryColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Owner: ${farm.owner}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            farm.location,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildFarmDetailItem(
                            'Area',
                            FormatterUtils.formatArea(farm.areaHectares),
                            Icons.area_chart,
                          ),
                          _buildFarmDetailItem(
                            'Soil Type',
                            farm.soilType,
                            Icons.grass,
                          ),
                          _buildFarmDetailItem(
                            'Fields',
                            farm.fields.length.toString(),
                            Icons.crop_square,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        'Crops',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: farm.crops.map((crop) {
                          return Chip(
                            label: Text(crop),
                            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                            avatar: Icon(
                              crop.contains('Corn') ? Icons.grass : Icons.grain,
                              size: 16,
                              color: AppTheme.primaryColor,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Varieties',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: farm.cropVarieties.map((variety) {
                          return Chip(
                            label: Text(variety),
                            backgroundColor: AppTheme.secondaryColor.withOpacity(0.1),
                            avatar: const Icon(
                              Icons.eco,
                              size: 16,
                              color: AppTheme.secondaryColor,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Farm map section
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.map,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Farm Map',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FarmMapScreen(farm: farm),
                            ),
                          );
                        },
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Open Map'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(
                          "https://pixabay.com/get/g201c46c875776fa26bfee855427de8eb73093ee3a9fbbc2b9871013ad4e79c618a945b7835bd800a9729dd54523d158c_1280.jpg",
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FarmMapScreen(farm: farm),
                            ),
                          );
                        },
                        icon: const Icon(Icons.zoom_in),
                        label: const Text('View Full Map'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Fields section
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.crop_square,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Fields',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () => _showAddFieldDialog(farm),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Field'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (farm.fields.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.crop_square_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No fields added yet',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => _showAddFieldDialog(farm),
                              icon: const Icon(Icons.add),
                              label: const Text('Add First Field'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: farm.fields.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final field = farm.fields[index];
                        return ListTile(
                          title: Text(
                            field.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('${field.cropType} - ${field.cropVariety}'),
                              const SizedBox(height: 4),
                              Text(
                                'Area: ${FormatterUtils.formatArea(field.areaHectares)}',
                              ),
                            ],
                          ),
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Planted: ${DateTimeUtils.formatShortDate(DateTime.parse(field.plantingDate))}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Harvest: ${DateTimeUtils.formatShortDate(DateTime.parse(field.expectedHarvestDate))}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            // Show field details or set as selected field
                            farmProvider.setSelectedField(field);
                          },
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFarmDetailItem(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}