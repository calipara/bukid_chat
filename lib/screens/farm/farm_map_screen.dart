import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FarmMapScreen extends StatefulWidget {
  final Function(List<LatLng> polygon, LatLng? centerPoint) onSave;
  final List<LatLng>? existingPolygon;
  final LatLng? existingCenter;

  const FarmMapScreen({
    Key? key,
    required this.onSave,
    this.existingPolygon,
    this.existingCenter,
  }) : super(key: key);

  @override
  _FarmMapScreenState createState() => _FarmMapScreenState();
}

class _FarmMapScreenState extends State<FarmMapScreen> {
  GoogleMapController? _mapController;
  final List<LatLng> _polygonPoints = [];
  bool _isCenterMode = false;
  LatLng? _centerPoint;

  @override
  void initState() {
    super.initState();
    if (widget.existingPolygon != null) {
      _polygonPoints.addAll(widget.existingPolygon!);
    }
    if (widget.existingCenter != null) {
      _centerPoint = widget.existingCenter;
    }
  }

  void _onMapTap(LatLng position) {
    if (_isCenterMode) {
      setState(() => _centerPoint = position);
    } else {
      setState(() => _polygonPoints.add(position));
    }
  }

  void _clear() {
    setState(() {
      _polygonPoints.clear();
      _centerPoint = null;
    });
  }

  void _undo() {
    if (_polygonPoints.isNotEmpty) {
      setState(() => _polygonPoints.removeLast());
    }
  }

  void _centerToPolygonOrPoint() {
    if (_polygonPoints.isNotEmpty) {
      _mapController?.animateCamera(CameraUpdate.newLatLng(_polygonPoints[0]));
    } else if (_centerPoint != null) {
      _mapController?.animateCamera(CameraUpdate.newLatLng(_centerPoint!));
    }
  }

  Set<Polygon> _buildPolygon() {
    if (_polygonPoints.length < 3) return {};
    return {
      Polygon(
        polygonId: const PolygonId('farm'),
        points: _polygonPoints,
        fillColor: Colors.green.withOpacity(0.3),
        strokeColor: Colors.green,
        strokeWidth: 2,
      ),
    };
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    if (_isCenterMode && _centerPoint != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('centerPoint'),
          position: _centerPoint!,
          draggable: true,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          onDragEnd: (newPos) => setState(() => _centerPoint = newPos),
        ),
      );
    }

    for (int i = 0; i < _polygonPoints.length; i++) {
      markers.add(
        Marker(
          markerId: MarkerId('marker_$i'),
          position: _polygonPoints[i],
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final defaultLatLng = widget.existingPolygon?.first ?? widget.existingCenter ?? const LatLng(13.41, 122.56);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ilagay ang Lokasyon ng Bukid'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: defaultLatLng,
              zoom: 16,
            ),
            onMapCreated: (controller) => _mapController = controller,
            polygons: _buildPolygon(),
            markers: _buildMarkers(),
            onTap: _onMapTap,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(_isCenterMode ? Icons.location_on : Icons.format_shapes),
                        color: Colors.green,
                        tooltip: _isCenterMode ? 'Center Mode' : 'Draw Polygon',
                        onPressed: () => setState(() => _isCenterMode = !_isCenterMode),
                      ),
                      IconButton(
                        icon: const Icon(Icons.undo),
                        color: Colors.orange,
                        tooltip: 'Undo',
                        onPressed: _undo,
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear),
                        color: Colors.red,
                        tooltip: 'Clear All',
                        onPressed: _clear,
                      ),
                      IconButton(
                        icon: const Icon(Icons.center_focus_strong),
                        color: Colors.blue,
                        tooltip: 'Focus',
                        onPressed: _centerToPolygonOrPoint,
                      ),
                      IconButton(
                        icon: const Icon(Icons.check_circle),
                        color: Colors.green[800],
                        tooltip: 'Save',
                        onPressed: () {
                          widget.onSave(_polygonPoints, _centerPoint);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
