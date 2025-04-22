import 'dart:convert';

class FarmModel {
  final String id;
  final String name;
  final String owner;
  final double areaHectares;
  final String location;
  final List<String> crops;
  final List<String> cropVarieties;
  final String soilType;
  final List<FieldModel> fields;
  final Map<String, dynamic> coordinates; // Center coordinates of the farm

  FarmModel({
    required this.id,
    required this.name,
    required this.owner,
    required this.areaHectares,
    required this.location,
    required this.crops,
    required this.cropVarieties,
    required this.soilType,
    required this.fields,
    required this.coordinates,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'owner': owner,
      'areaHectares': areaHectares,
      'location': location,
      'crops': crops,
      'cropVarieties': cropVarieties,
      'soilType': soilType,
      'fields': fields.map((field) => field.toJson()).toList(),
      'coordinates': coordinates,
    };
  }

  factory FarmModel.fromJson(Map<String, dynamic> json) {
    return FarmModel(
      id: json['id'],
      name: json['name'],
      owner: json['owner'],
      areaHectares: json['areaHectares'],
      location: json['location'],
      crops: List<String>.from(json['crops']),
      cropVarieties: List<String>.from(json['cropVarieties']),
      soilType: json['soilType'],
      fields: (json['fields'] as List)
          .map((field) => FieldModel.fromJson(field))
          .toList(),
      coordinates: json['coordinates'],
    );
  }

  static List<FarmModel> fromJsonList(String jsonString) {
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => FarmModel.fromJson(json)).toList();
  }

  static String toJsonList(List<FarmModel> farms) {
    final List<Map<String, dynamic>> jsonList = 
        farms.map((farm) => farm.toJson()).toList();
    return json.encode(jsonList);
  }
}

class FieldModel {
  final String id;
  final String name;
  final double areaHectares;
  final String cropType;
  final String cropVariety;
  final String plantingDate;
  final String expectedHarvestDate;
  final List<Map<String, double>> boundaries; // List of lat/lng coordinates forming the field boundary

  FieldModel({
    required this.id,
    required this.name,
    required this.areaHectares,
    required this.cropType,
    required this.cropVariety,
    required this.plantingDate,
    required this.expectedHarvestDate,
    required this.boundaries,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'areaHectares': areaHectares,
      'cropType': cropType,
      'cropVariety': cropVariety,
      'plantingDate': plantingDate,
      'expectedHarvestDate': expectedHarvestDate,
      'boundaries': boundaries,
    };
  }

  factory FieldModel.fromJson(Map<String, dynamic> json) {
    return FieldModel(
      id: json['id'],
      name: json['name'],
      areaHectares: json['areaHectares'],
      cropType: json['cropType'],
      cropVariety: json['cropVariety'],
      plantingDate: json['plantingDate'],
      expectedHarvestDate: json['expectedHarvestDate'],
      boundaries: List<Map<String, double>>.from(
        (json['boundaries'] as List).map(
          (coord) => Map<String, double>.from(coord),
        ),
      ),
    );
  }
}