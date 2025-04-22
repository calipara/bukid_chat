import 'dart:math';
import 'package:flutter/foundation.dart';

import '../models/farm_model.dart';
import '../services/storage_service.dart';

class FarmProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<FarmModel> _farms = [];
  FarmModel? _selectedFarm;
  FieldModel? _selectedField;
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  List<FarmModel> get farms => _farms;
  FarmModel? get selectedFarm => _selectedFarm;
  FieldModel? get selectedField => _selectedField;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasFarms => _farms.isNotEmpty;

  // Constructor loads farms from storage
  FarmProvider() {
    loadFarms();
  }

  // Load farms from storage
  Future<void> loadFarms() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _farms = await _storageService.getFarms();
      if (_farms.isNotEmpty && _selectedFarm == null) {
        _selectedFarm = _farms.first;
      }
    } catch (e) {
      _errorMessage = 'Failed to load farms: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new farm
  Future<void> addFarm(FarmModel farm) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _farms.add(farm);
      await _storageService.saveFarms(_farms);
      await _storageService.setFarmProfileCreated(true);
      _selectedFarm = farm;
    } catch (e) {
      _errorMessage = 'Failed to add farm: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update an existing farm
  Future<void> updateFarm(FarmModel updatedFarm) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final index = _farms.indexWhere((farm) => farm.id == updatedFarm.id);
      if (index != -1) {
        _farms[index] = updatedFarm;
        await _storageService.saveFarms(_farms);
        if (_selectedFarm?.id == updatedFarm.id) {
          _selectedFarm = updatedFarm;
        }
      } else {
        _errorMessage = 'Farm not found';
      }
    } catch (e) {
      _errorMessage = 'Failed to update farm: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a farm
  Future<void> deleteFarm(String farmId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _farms.removeWhere((farm) => farm.id == farmId);
      await _storageService.saveFarms(_farms);
      if (_selectedFarm?.id == farmId) {
        _selectedFarm = _farms.isNotEmpty ? _farms.first : null;
      }
      if (_farms.isEmpty) {
        await _storageService.setFarmProfileCreated(false);
      }
    } catch (e) {
      _errorMessage = 'Failed to delete farm: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a field to a farm
  Future<void> addField(String farmId, FieldModel field) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final farmIndex = _farms.indexWhere((farm) => farm.id == farmId);
      if (farmIndex != -1) {
        final updatedFields = List<FieldModel>.from(_farms[farmIndex].fields);
        updatedFields.add(field);

        final updatedFarm = FarmModel(
          id: _farms[farmIndex].id,
          name: _farms[farmIndex].name,
          owner: _farms[farmIndex].owner,
          areaHectares: _farms[farmIndex].areaHectares,
          location: _farms[farmIndex].location,
          crops: _farms[farmIndex].crops,
          cropVarieties: _farms[farmIndex].cropVarieties,
          soilType: _farms[farmIndex].soilType,
          fields: updatedFields,
          coordinates: _farms[farmIndex].coordinates,
        );

        _farms[farmIndex] = updatedFarm;
        await _storageService.saveFarms(_farms);

        if (_selectedFarm?.id == farmId) {
          _selectedFarm = updatedFarm;
        }
      } else {
        _errorMessage = 'Farm not found';
      }
    } catch (e) {
      _errorMessage = 'Failed to add field: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update a field
  Future<void> updateField(String farmId, FieldModel updatedField) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final farmIndex = _farms.indexWhere((farm) => farm.id == farmId);
      if (farmIndex != -1) {
        final fieldIndex = _farms[farmIndex].fields.indexWhere(
          (field) => field.id == updatedField.id,
        );

        if (fieldIndex != -1) {
          final updatedFields = List<FieldModel>.from(_farms[farmIndex].fields);
          updatedFields[fieldIndex] = updatedField;

          final updatedFarm = FarmModel(
            id: _farms[farmIndex].id,
            name: _farms[farmIndex].name,
            owner: _farms[farmIndex].owner,
            areaHectares: _farms[farmIndex].areaHectares,
            location: _farms[farmIndex].location,
            crops: _farms[farmIndex].crops,
            cropVarieties: _farms[farmIndex].cropVarieties,
            soilType: _farms[farmIndex].soilType,
            fields: updatedFields,
            coordinates: _farms[farmIndex].coordinates,
          );

          _farms[farmIndex] = updatedFarm;
          await _storageService.saveFarms(_farms);

          if (_selectedFarm?.id == farmId) {
            _selectedFarm = updatedFarm;
          }

          if (_selectedField?.id == updatedField.id) {
            _selectedField = updatedField;
          }
        } else {
          _errorMessage = 'Field not found';
        }
      } else {
        _errorMessage = 'Farm not found';
      }
    } catch (e) {
      _errorMessage = 'Failed to update field: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a field
  Future<void> deleteField(String farmId, String fieldId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final farmIndex = _farms.indexWhere((farm) => farm.id == farmId);
      if (farmIndex != -1) {
        final updatedFields = List<FieldModel>.from(_farms[farmIndex].fields)
          ..removeWhere((field) => field.id == fieldId);

        final updatedFarm = FarmModel(
          id: _farms[farmIndex].id,
          name: _farms[farmIndex].name,
          owner: _farms[farmIndex].owner,
          areaHectares: _farms[farmIndex].areaHectares,
          location: _farms[farmIndex].location,
          crops: _farms[farmIndex].crops,
          cropVarieties: _farms[farmIndex].cropVarieties,
          soilType: _farms[farmIndex].soilType,
          fields: updatedFields,
          coordinates: _farms[farmIndex].coordinates,
        );

        _farms[farmIndex] = updatedFarm;
        await _storageService.saveFarms(_farms);

        if (_selectedFarm?.id == farmId) {
          _selectedFarm = updatedFarm;
        }

        if (_selectedField?.id == fieldId) {
          _selectedField = null;
        }
      } else {
        _errorMessage = 'Farm not found';
      }
    } catch (e) {
      _errorMessage = 'Failed to delete field: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set selected farm
  void setSelectedFarm(FarmModel farm) {
    _selectedFarm = farm;
    _selectedField = null;
    notifyListeners();
  }

  // Set selected field
  void setSelectedField(FieldModel field) {
    _selectedField = field;
    notifyListeners();
  }

  // Clear selected field
  void clearSelectedField() {
    _selectedField = null;
    notifyListeners();
  }

  // Generate a unique ID
  String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(10000).toString();
  }
}