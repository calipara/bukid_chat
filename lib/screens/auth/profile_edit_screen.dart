import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({Key? key}) : super(key: key);

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _farmingDurationController = TextEditingController();
  String? _gender;
  String? _region;
  String? _province;
  String? _city;
  String? _birthday;
  String? _photoUrl;
  File? _newImage;
  bool _isLoading = true;

  final List<String> _genders = ['Lalaki', 'Babae'];
  final List<String> _regions = ['Region III'];
  final List<String> _provinces = ['Bulacan', 'Bataan', 'Pampanga', 'Nueva Ecija'];
  final Map<String, List<String>> _citiesByProvince = {
    'Bulacan': ['Malolos', 'Meycauayan', 'San Jose del Monte', 'Baliuag'],
    'Bataan': ['Balanga City', 'Dinalupihan', 'Hermosa'],
    'Pampanga': ['Angeles City', 'San Fernando', 'Mabalacat'],
    'Nueva Ecija': ['Cabanatuan', 'Gapan', 'San Jose City'],
  };

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _nameController.text = data['name'] ?? '';
        _birthday = data['birthday'];
        _gender = data['gender'];
        _region = data['region'];
        _province = data['province'];
        _city = data['city'];
        _farmingDurationController.text = data['farmingDuration'] ?? '';
        _photoUrl = data['photoUrl'];
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _pickNewImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (pickedFile != null) {
      setState(() {
        _newImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String photoUrl = _photoUrl ?? '';

      if (_newImage != null) {
        final ref = FirebaseStorage.instance.ref().child('profile_pictures/${user.uid}.jpg');
        await ref.putFile(_newImage!);
        photoUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'name': _nameController.text.trim(),
        'birthday': _birthday,
        'gender': _gender,
        'region': _region,
        'province': _province,
        'city': _city,
        'farmingDuration': _farmingDurationController.text.trim(),
        'photoUrl': photoUrl,
      });

      if (!mounted) return;
      Navigator.pop(context); // Back to ProfileScreen
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickNewImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.green.shade100,
                  backgroundImage: _newImage != null
                      ? FileImage(_newImage!)
                      : (_photoUrl != null && _photoUrl != '')
                          ? NetworkImage(_photoUrl!) as ImageProvider
                          : const AssetImage('assets/images/default_avatar.png'),
                  child: _newImage == null && (_photoUrl == null || _photoUrl == '')
                      ? const Icon(Icons.camera_alt, color: Colors.green, size: 30)
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Pangalan'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Birthday
              TextFormField(
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Birthday',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                controller: TextEditingController(text: _birthday),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _birthday = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Gender
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Kasarian'),
                value: _gender,
                items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (value) => setState(() => _gender = value),
                validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Region
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Region'),
                value: _region,
                items: _regions.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (value) => setState(() {
                  _region = value;
                  _province = null;
                  _city = null;
                }),
                validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Province
              DropdownButtonFormField<String>(
  decoration: const InputDecoration(labelText: 'Probinsya'),
  value: _province,
  items: _provinces.map((province) => DropdownMenuItem<String>(
    value: province,
    child: Text(province),
  )).toList(),
  onChanged: (value) {
    setState(() {
      _province = value;
      _city = null; // reset city pag napalitan province
    });
  },
  validator: (value) => value == null ? 'Required' : null,
),

              const SizedBox(height: 16),

              // City
           DropdownButtonFormField<String>(
  decoration: const InputDecoration(labelText: 'City/Munisipyo'),
  value: _citiesByProvince[_province]?.contains(_city) == true ? _city : null,
  items: (_province != null ? _citiesByProvince[_province]! : [])
      .map((city) => DropdownMenuItem<String>(
            value: city,
            child: Text(city),
          ))
      .toList(),
  onChanged: (value) {
    setState(() => _city = value);
  },
  validator: (value) => value == null ? 'Required' : null,
),



              const SizedBox(height: 16),

             

              // Save Button
              ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save),
                label: const Text('Isave'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
