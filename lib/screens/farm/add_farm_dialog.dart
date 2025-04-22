import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AddFarmDialog extends StatefulWidget {
  final Map<String, dynamic>? farmData;
  final String? farmId;

  const AddFarmDialog({super.key, this.farmData, this.farmId});

  @override
  State<AddFarmDialog> createState() => _AddFarmDialogState();
}

class _AddFarmDialogState extends State<AddFarmDialog> {
  final _formKey = GlobalKey<FormState>();
  final _farmNameController = TextEditingController();
  final _ownerController = TextEditingController();
  final _areaController = TextEditingController();
  final _expectedHarvestAmountController = TextEditingController();

  String? _selectedCrop;
  String _unit = 'Ektarya';
  String _waterSource = 'Irigasyon';
  bool _isOrganic = false;
  int _monthsBeforeHarvest = 3;
  String _harvestUnit = 'Kilo';
  String? _relationship;
  DateTime _selectedPlantingDate = DateTime.now();
  DateTime _expectedHarvestDate = DateTime.now().add(const Duration(days: 90));

  final crops = ['Corn', 'Rice'];
  final units = ['Ektarya', 'Square Meters'];
  final waterSources = ['Irigasyon', 'Ulan'];
  final harvestUnits = ['Kilo', 'Cavan', 'Tonelada'];
  final relationships = ['Magulang', 'Asawa', 'Anak', 'Kapatid', 'Pinsan', 'Iba pa'];

  String? _loggedInUserName;

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance.collection('users').doc(currentUser?.uid).get().then((doc) {
      setState(() {
        _loggedInUserName = doc['name'] ?? '';
        _ownerController.text = _loggedInUserName!;
      });
    });

    if (widget.farmData != null) {
      final data = widget.farmData!;
      _farmNameController.text = data['farmName'] ?? '';
      _ownerController.text = data['ownerName'] ?? '';
      _selectedCrop = data['crop'];
      _areaController.text = data['area']?.toString() ?? '';
      _unit = data['unit'] ?? 'Ektarya';
      _waterSource = data['waterSource'] ?? 'Irigasyon';
      _isOrganic = data['organic'] == 'Yes';
      _monthsBeforeHarvest = data['monthsBeforeHarvest'] ?? 3;
      _harvestUnit = data['harvestUnit'] ?? 'Kilo';
      _relationship = data['relationship'];

      if (data['plantingDate'] != null) {
        _selectedPlantingDate = DateTime.parse(data['plantingDate']);
        _expectedHarvestDate = DateTime.parse(data['expectedHarvestDate']);
      }
      _expectedHarvestAmountController.text = data['expectedHarvestAmount']?.toString() ?? '';
    }
  }

  Future<void> _saveFarm() async {
    final user = FirebaseAuth.instance.currentUser;
    if (!_formKey.currentState!.validate() || user == null) return;

    final owner = _ownerController.text.trim();
    final farmName = _farmNameController.text.trim();
    final area = double.tryParse(_areaController.text.trim()) ?? 0;
    final expectedHarvest = double.tryParse(_expectedHarvestAmountController.text.trim()) ?? 0;
    final isOwnerSame = owner == _loggedInUserName;

    if (!isOwnerSame && _relationship == null) {
      final relation = await showDialog<String>(
        context: context,
        builder: (context) {
          String? selectedRelation;
          final controller = TextEditingController();
          return AlertDialog(
            title: const Text('Relasyon sa May-ari'),
            content: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      items: relationships
                          .map((rel) => DropdownMenuItem(value: rel, child: Text(rel)))
                          .toList(),
                      onChanged: (value) => setState(() => selectedRelation = value),
                      decoration: const InputDecoration(labelText: 'Pumili ng Relasyon'),
                    ),
                    if (selectedRelation == 'Iba pa')
                      TextFormField(
                        controller: controller,
                        decoration: const InputDecoration(labelText: 'Kung "Iba pa", ilagay dito'),
                      ),
                  ],
                );
              },
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  final finalRel = selectedRelation == 'Iba pa' ? controller.text.trim() : selectedRelation;
                  Navigator.pop(context, finalRel);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      if (relation == null || relation.isEmpty) return;
      setState(() => _relationship = relation);
    }

    final farmData = {
      'farmName': farmName,
      'ownerName': owner,
      'crop': _selectedCrop,
      'area': area,
      'unit': _unit,
      'waterSource': _waterSource,
      'organic': _isOrganic ? 'Yes' : 'No',
      'plantingDate': _selectedPlantingDate.toIso8601String(),
      'monthsBeforeHarvest': _monthsBeforeHarvest,
      'expectedHarvestDate': DateFormat('yyyy-MM-dd').format(_expectedHarvestDate),
      'expectedHarvestAmount': expectedHarvest,
      'harvestUnit': _harvestUnit,
      'createdAt': FieldValue.serverTimestamp(),
    };

    if (!isOwnerSame) {
      farmData['relationship'] = _relationship;
    }

    try {
      final ref = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('farms');
      if (widget.farmId != null) {
        await ref.doc(widget.farmId).update(farmData);
      } else {
        await ref.add(farmData);
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Tagumpay! Naitala ang iyong bukid.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.farmId != null ? 'I-edit ang Bukid' : 'Magdagdag ng Bukid'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _farmNameController,
                  decoration: const InputDecoration(labelText: 'Pangalan ng Bukid'),
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ownerController,
                  decoration: const InputDecoration(labelText: 'Pangalan ng May-ari'),
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCrop,
                  items: crops.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => setState(() => _selectedCrop = val),
                  decoration: const InputDecoration(labelText: 'Piliin ang Pananim'),
                  validator: (val) => val == null ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _areaController,
                  decoration: const InputDecoration(labelText: 'Sukat ng Sakahan'),
                  keyboardType: TextInputType.number,
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField(
                  value: _unit,
                  items: units.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => setState(() => _unit = val!),
                  decoration: const InputDecoration(labelText: 'Unit'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField(
                  value: _waterSource,
                  items: waterSources.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => setState(() => _waterSource = val!),
                  decoration: const InputDecoration(labelText: 'Patubig'),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Organic Farming'),
                  value: _isOrganic,
                  onChanged: (val) => setState(() => _isOrganic = val),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text('📅 Petsa ng Pagtatanim: ${DateFormat('yyyy-MM-dd').format(_selectedPlantingDate)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedPlantingDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedPlantingDate = date;
                        _expectedHarvestDate = DateTime(
                          date.year,
                          date.month + _monthsBeforeHarvest,
                          date.day,
                        );
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _monthsBeforeHarvest,
                  decoration: const InputDecoration(labelText: 'Buwan bago Anihan'),
                  items: List.generate(6, (i) => i + 1)
                      .map((e) => DropdownMenuItem(value: e, child: Text('$e buwan')))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _monthsBeforeHarvest = val;
                        _expectedHarvestDate = DateTime(
                          _selectedPlantingDate.year,
                          _selectedPlantingDate.month + val,
                          _selectedPlantingDate.day,
                        );
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text('📅 Inaasahang Petsa ng Anihan: ${DateFormat('yyyy-MM-dd').format(_expectedHarvestDate)}'),
                  trailing: const Icon(Icons.edit_calendar),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _expectedHarvestDate,
                      firstDate: _selectedPlantingDate,
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() => _expectedHarvestDate = date);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _expectedHarvestAmountController,
                  decoration: const InputDecoration(labelText: 'Inaasahang Dami ng Ani'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField(
                  value: _harvestUnit,
                  items: harvestUnits.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => setState(() => _harvestUnit = val!),
                  decoration: const InputDecoration(labelText: 'Unit ng Ani'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: _saveFarm, child: const Text('I-save')),
      ],
    );
  }
}