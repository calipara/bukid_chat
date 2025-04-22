import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/farm_model.dart';
import '../../providers/farm_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatter_utils.dart';
import '../../constants/api_constants.dart';

class FarmMapScreen extends StatefulWidget {
  final FarmModel farm;

  const FarmMapScreen({Key? key, required this.farm}) : super(key: key);

  @override
  _FarmMapScreenState createState() => _FarmMapScreenState();
}

class _FarmMapScreenState extends State<FarmMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  Set<Polygon> _polygons = {};
  Set<Marker> _markers = {};
  List<LatLng> _drawingPoints = [];
  bool _isDrawing = false;
  FieldModel? _selectedField;
  double _mapZoom = 15.0;

  @override
  void initState() {
    super.initState();
    _initializeMap();
    
    // Initialize default center coordinates if farm doesn't have coordinates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.farm.coordinates['lat'] == null || widget.farm.coordinates['lng'] == null) {
        _centerMapOnDefaultLocation();
      }
    });
  }

  void _initializeMap() {
    // Add markers and polygons for existing fields
    _polygons = {};
    _markers = {};

    for (var field in widget.farm.fields) {
      if (field.boundaries.isNotEmpty) {
        // Convert boundaries to LatLng
        final points = field.boundaries
            .map((point) => LatLng(point['lat']!, point['lng']!))
            .toList();

        // Add polygon for the field
        _polygons.add(
          Polygon(
            polygonId: PolygonId(field.id),
            points: points,
            fillColor: _getFieldColor(field).withOpacity(0.3),
            strokeColor: _getFieldColor(field),
            strokeWidth: 2,
            consumeTapEvents: true,
            onTap: () {
              setState(() {
                _selectedField = field;
              });
            },
          ),
        );

        // Add marker for the field center
        final center = _calculateCenter(points);
        _markers.add(
          Marker(
            markerId: MarkerId('marker_${field.id}'),
            position: center,
            infoWindow: InfoWindow(title: field.name),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              field.cropType.contains('Corn')
                  ? BitmapDescriptor.hueYellow
                  : BitmapDescriptor.hueGreen,
            ),
            onTap: () {
              setState(() {
                _selectedField = field;
              });
            },
          ),
        );
      }
    }
  }

  Color _getFieldColor(FieldModel field) {
    if (field.cropType.contains('Corn')) {
      return Colors.amber;
    } else if (field.cropType.contains('Palay')) {
      return Colors.green;
    } else {
      return Colors.blue;
    }
  }

  LatLng _calculateCenter(List<LatLng> points) {
    double latitude = 0;
    double longitude = 0;

    for (var point in points) {
      latitude += point.latitude;
      longitude += point.longitude;
    }

    return LatLng(
      latitude / points.length,
      longitude / points.length,
    );
  }

  void _toggleDrawing() {
    setState(() {
      if (_isDrawing) {
        // Save the field boundaries if there are enough points
        if (_drawingPoints.length >= 3) {
          _saveFieldBoundary();
        }
        _isDrawing = false;
        _drawingPoints = [];
      } else {
        _isDrawing = true;
        _drawingPoints = [];
        _selectedField = null;
      }
    });
  }

  void _addPoint(LatLng point) {
    if (_isDrawing) {
      setState(() {
        _drawingPoints.add(point);

        // Update the drawing polygon
        if (_drawingPoints.length > 1) {
          _polygons = _polygons.where((p) => p.polygonId.value != 'drawing').toSet();
          _polygons.add(
            Polygon(
              polygonId: const PolygonId('drawing'),
              points: _drawingPoints,
              fillColor: Colors.blue.withOpacity(0.3),
              strokeColor: Colors.blue,
              strokeWidth: 2,
            ),
          );
        }
      });
    }
  }

  void _undoLastPoint() {
    if (_isDrawing && _drawingPoints.isNotEmpty) {
      setState(() {
        _drawingPoints.removeLast();

        // Update the drawing polygon
        _polygons = _polygons.where((p) => p.polygonId.value != 'drawing').toSet();
        if (_drawingPoints.length > 1) {
          _polygons.add(
            Polygon(
              polygonId: const PolygonId('drawing'),
              points: _drawingPoints,
              fillColor: Colors.blue.withOpacity(0.3),
              strokeColor: Colors.blue,
              strokeWidth: 2,
            ),
          );
        }
      });
    }
  }

  void _resetDrawing() {
    if (_isDrawing) {
      setState(() {
        _drawingPoints = [];
        _polygons = _polygons.where((p) => p.polygonId.value != 'drawing').toSet();
      });
    }
  }

  double _calculateAreaInHectares(List<LatLng> points) {
    // Basic area calculation using Shoelace formula
    if (points.length < 3) return 0;
    
    double area = 0;
    for (int i = 0; i < points.length; i++) {
      int j = (i + 1) % points.length;
      area += points[i].latitude * points[j].longitude;
      area -= points[j].latitude * points[i].longitude;
    }
    area = area.abs() / 2;
    
    // Convert to hectares (very approximate)
    // 1 degree at equator ~= 111 km
    // This is a rough approximation and not accurate for all locations
    const degreeToMeters = 111319.9;
    double areaSquareMeters = area * degreeToMeters * degreeToMeters;
    double areaHectares = areaSquareMeters / 10000;
    
    return areaHectares;
  }

  void _saveFieldBoundary() {
    showDialog(
      context: context,
      builder: (context) {
        var areaHectares = _calculateAreaInHectares(_drawingPoints);
        areaHectares = double.parse(areaHectares.toStringAsFixed(2)); // Round to 2 decimal places
        
        // Prepare for field selection
        String? selectedFieldId;
        if (widget.farm.fields.isNotEmpty) {
          selectedFieldId = widget.farm.fields.first.id;
        }
        
        // For new field option
        final TextEditingController nameController = TextEditingController();
        
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('I-save ang Boundary ng Bukid'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Laki ng Area: ${FormatterUtils.formatArea(areaHectares)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const Text('Pumili ng opsyon:'),
                    const SizedBox(height: 8),
                    RadioListTile<String?>(
                      title: const Text('Itakda sa kasalukuyang bukid'),
                      value: 'existing',
                      groupValue: selectedFieldId == null ? 'new' : 'existing',
                      onChanged: (value) {
                        setState(() {
                          if (widget.farm.fields.isNotEmpty) {
                            selectedFieldId = widget.farm.fields.first.id;
                          }
                        });
                      },
                    ),
                    if (widget.farm.fields.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: DropdownButtonFormField<String>(
                          value: selectedFieldId,
                          decoration: const InputDecoration(
                            labelText: 'Piliin ang Bukid',
                          ),
                          items: widget.farm.fields.map((field) {
                            return DropdownMenuItem<String>(
                              value: field.id,
                              child: Text(field.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedFieldId = value;
                            });
                          },
                        ),
                      ),
                    RadioListTile<String?>(
                      title: const Text('Gumawa ng bagong bukid'),
                      value: 'new',
                      groupValue: selectedFieldId == null ? 'new' : 'existing',
                      onChanged: (value) {
                        setState(() {
                          selectedFieldId = null;
                        });
                      },
                    ),
                    if (selectedFieldId == null)
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Pangalan ng Bagong Bukid',
                          ),
                        ),
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
                    if (selectedFieldId != null) {
                      // Update existing field
                      _updateFieldBoundary(selectedFieldId!, _drawingPoints);
                    } else {
                      // Create new field
                      if (nameController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Paki-lagay ang pangalan ng bukid')),
                        );
                        return;
                      }
                      _createNewField(nameController.text, areaHectares, _drawingPoints);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('I-save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _updateFieldBoundary(String fieldId, List<LatLng> points) {
    final farmProvider = Provider.of<FarmProvider>(context, listen: false);
    final field = widget.farm.fields.firstWhere((f) => f.id == fieldId);
    
    // Convert LatLng to map coordinates
    List<Map<String, double>> boundaries = points.map((point) => {
      'lat': point.latitude,
      'lng': point.longitude,
    }).toList();
    
    // Create updated field
    final updatedField = FieldModel(
      id: field.id,
      name: field.name,
      areaHectares: field.areaHectares,
      cropType: field.cropType,
      cropVariety: field.cropVariety,
      plantingDate: field.plantingDate,
      expectedHarvestDate: field.expectedHarvestDate,
      boundaries: boundaries,
    );
    
    // Update field in provider
    farmProvider.updateField(widget.farm.id, updatedField);
    
    // Reset drawing state
    setState(() {
      _isDrawing = false;
      _drawingPoints = [];
      _initializeMap();
      _selectedField = updatedField;
    });
  }

  void _createNewField(String name, double area, List<LatLng> points) {
    final farmProvider = Provider.of<FarmProvider>(context, listen: false);
    
    // Convert LatLng to map coordinates
    List<Map<String, double>> boundaries = points.map((point) => {
      'lat': point.latitude,
      'lng': point.longitude,
    }).toList();
    
    // Generate field ID
    final fieldId = DateTime.now().millisecondsSinceEpoch.toString() + 
        Random().nextInt(10000).toString();
    
    // Create new field
    final newField = FieldModel(
      id: fieldId,
      name: name,
      areaHectares: area,
      cropType: widget.farm.crops.first,
      cropVariety: widget.farm.cropVarieties.first,
      plantingDate: DateTime.now().toIso8601String().split('T')[0],
      expectedHarvestDate: DateTime.now().add(const Duration(days: 120))
          .toIso8601String().split('T')[0],
      boundaries: boundaries,
    );
    
    // Add field to farm
    farmProvider.addField(widget.farm.id, newField);
    
    // Reset drawing state
    setState(() {
      _isDrawing = false;
      _drawingPoints = [];
      _initializeMap();
      _selectedField = newField;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa ng ${widget.farm.name}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
            tooltip: 'Tulong',
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildGoogleMap(),
          if (_isDrawing) _buildDrawingInstructions(),
          if (_selectedField != null) _buildFieldInfoPanel(),
          _buildZoomControls(),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'center_map',
            onPressed: _centerMap,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.my_location,
              color: AppTheme.primaryColor,
            ),
            mini: true,
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: 'toggle_drawing',
            onPressed: _toggleDrawing,
            backgroundColor: _isDrawing ? Colors.red : AppTheme.primaryColor,
            label: Text(_isDrawing ? 'Kanselahin' : 'Guhit ng Bukid'),
            icon: Icon(_isDrawing ? Icons.close : Icons.draw),
          ),
          if (_isDrawing) ...[  
            const SizedBox(height: 16),
            FloatingActionButton(
              heroTag: 'undo_point',
              onPressed: _undoLastPoint,
              backgroundColor: Colors.orange,
              child: const Icon(Icons.undo),
              mini: true,
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              heroTag: 'reset_drawing',
              onPressed: _resetDrawing,
              backgroundColor: Colors.red,
              child: const Icon(Icons.delete_outline),
              mini: true,
            ),
            const SizedBox(height: 16),
            if (_drawingPoints.length >= 3)
              FloatingActionButton(
                heroTag: 'save_drawing',
                onPressed: _saveFieldBoundary,
                backgroundColor: Colors.green,
                child: const Icon(Icons.check),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildGoogleMap() {
    // Default to Philippines location if farm coordinates are not valid
    double lat = ApiConstants.defaultLatitude;
    double lng = ApiConstants.defaultLongitude;
    
    // Use farm coordinates if available
    if (widget.farm.coordinates.containsKey('lat') && 
        widget.farm.coordinates.containsKey('lng') &&
        widget.farm.coordinates['lat'] != null &&
        widget.farm.coordinates['lng'] != null) {
      lat = widget.farm.coordinates['lat'] as double;
      lng = widget.farm.coordinates['lng'] as double;
    }
    
    return GoogleMap(
      mapType: MapType.hybrid,
      initialCameraPosition: CameraPosition(
        target: LatLng(lat, lng),
        zoom: _mapZoom,
      ),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      polygons: _polygons,
      markers: _markers,
      onTap: (LatLng point) {
        if (_isDrawing) {
          _addPoint(point);
        } else {
          setState(() {
            _selectedField = null;
          });
        }
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      compassEnabled: true,
      zoomControlsEnabled: false,
    );
  }
  
  Future<void> _centerMapOnDefaultLocation() async {
    final controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(ApiConstants.defaultLatitude, ApiConstants.defaultLongitude),
        _mapZoom,
      ),
    );
  }

  Widget _buildDrawingInstructions() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.draw,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Drawing Mode',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  '${_drawingPoints.length} puntos',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'I-tap ang mapa para magdagdag ng mga puntos at gumawa ng boundary ng bukid. Kailangan ng hindi bababa sa 3 puntos para ma-save.',
            ),
            if (_drawingPoints.length >= 3) ...[  
              const SizedBox(height: 8),
              Text(
                'Laki ng Area: ${FormatterUtils.formatArea(_calculateAreaInHectares(_drawingPoints))}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFieldInfoPanel() {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getFieldColor(_selectedField!).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.crop_square,
                    color: _getFieldColor(_selectedField!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedField!.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_selectedField!.cropType} - ${_selectedField!.cropVariety}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedField = null;
                    });
                  },
                  icon: const Icon(Icons.close),
                  tooltip: 'Isara',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildFieldDetailItem(
                  'Sukat',
                  FormatterUtils.formatArea(_selectedField!.areaHectares),
                  Icons.area_chart,
                ),
                _buildFieldDetailItem(
                  'Petsa ng Tanim',
                  _selectedField!.plantingDate.replaceAll('-', '/'),
                  Icons.calendar_today,
                ),
                _buildFieldDetailItem(
                  'Petsa ng Ani',
                  _selectedField!.expectedHarvestDate.replaceAll('-', '/'),
                  Icons.event_available,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isDrawing = true;
                        _drawingPoints = _selectedField!.boundaries
                            .map((point) => LatLng(point['lat']!, point['lng']!))
                            .toList();
                        _selectedField = null;
                        
                        // Update the drawing polygon
                        _polygons = _polygons.where((p) => p.polygonId.value != 'drawing').toSet();
                        if (_drawingPoints.length > 1) {
                          _polygons.add(
                            Polygon(
                              polygonId: const PolygonId('drawing'),
                              points: _drawingPoints,
                              fillColor: Colors.blue.withOpacity(0.3),
                              strokeColor: Colors.blue,
                              strokeWidth: 2,
                            ),
                          );
                        }
                      });
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('I-edit ang Boundary'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _centerOnField(_selectedField!);
                    },
                    icon: const Icon(Icons.center_focus_strong),
                    label: const Text('I-center'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldDetailItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
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
    );
  }

  Widget _buildZoomControls() {
    return Positioned(
      right: 16,
      top: 100,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                setState(() {
                  _mapZoom = min(_mapZoom + 1, 20);
                });
                final controller = await _controller.future;
                controller.animateCamera(
                  CameraUpdate.zoomTo(_mapZoom),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () async {
                setState(() {
                  _mapZoom = max(_mapZoom - 1, 3);
                });
                final controller = await _controller.future;
                controller.animateCamera(
                  CameraUpdate.zoomTo(_mapZoom),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _centerMap() async {
    final controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(
          widget.farm.coordinates['lat'] as double,
          widget.farm.coordinates['lng'] as double,
        ),
        _mapZoom,
      ),
    );
  }

  Future<void> _centerOnField(FieldModel field) async {
    if (field.boundaries.isEmpty) return;
    
    final points = field.boundaries
        .map((point) => LatLng(point['lat']!, point['lng']!))
        .toList();
    
    final center = _calculateCenter(points);
    final controller = await _controller.future;
    
    controller.animateCamera(
      CameraUpdate.newLatLngZoom(center, _mapZoom),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tulong sa Pagmamapa'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Paano i-mapa ang iyong bukid:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('1. I-tap ang "Draw Field" para magsimula ng boundary'),
              Text('2. I-tap ang mapa para maglagay ng mga puntos sa paligid ng iyong bukid'),
              Text('3. Gumawa ng hindi bababa sa 3 puntos para makabuo ng boundary'),
              Text('4. I-tap ang check mark kapag tapos na'),
              Text('5. Pwede mong i-undo o i-reset habang nagdodrowing'),
              SizedBox(height: 16),
              Text(
                'Mga Kontrol sa Mapa:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('• I-tap ang isang field para makita ang mga detalye'),
              Text('• Gamitin ang + at - na mga button para mag-zoom in/out'),
              Text('• I-tap ang location button para i-center ang mapa'),
              Text('• Gumamit ng dalawang daliri para i-rotate at i-tilt ang mapa'),
              SizedBox(height: 16),
              Text(
                'Mga Kulay sa Mapa:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('• Dilaw na fields: Mais'),
              Text('• Berdeng fields: Palay'),
              Text('• Asul na outline: Kasalukuyang ginuguhit na boundary'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Naintindihan ko'),
          ),
        ],
      ),
    );
  }
}