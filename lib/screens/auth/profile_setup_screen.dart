import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _farmingDurationController = TextEditingController();

  String? _name;
  String? _gender;
  String? _region;
  String? _province;
  String? _city;
  String? _farmingUnit = 'Taon';
  int? _selectedMonth;
  int? _selectedDay;
  int? _selectedYear;

  File? _selectedImage;
  bool _isSaving = false;
  String? _photoUrl;

  final List<String> _regions = ['Region III'];
  final List<String> _provinces = ['Bulacan', 'Bataan', 'Pampanga', 'Nueva Ecija'];
  final Map<String, List<String>> _citiesByProvince = {
    'Bulacan': ['Malolos', 'Meycauayan', 'San Jose del Monte', 'Baliuag', 'Marilao', 'Santa Maria', 'San Rafael', 'Pulilan', 'Plaridel', 'San Ildefonso'],
    'Bataan': ['Balanga City', 'Dinalupihan', 'Hermosa'],
    'Pampanga': ['Angeles City', 'San Fernando', 'Mabalacat'],
    'Nueva Ecija': ['Cabanatuan', 'Gapan', 'San Jose City', 'Science City of Muñoz'],
  };

  final List<String> _monthNames = [
    'Enero', 'Pebrero', 'Marso', 'Abril', 'Mayo', 'Hunyo',
    'Hulyo', 'Agosto', 'Setyembre', 'Oktubre', 'Nobyembre', 'Disyembre'
  ];

  List<int> _days = List.generate(31, (index) => index + 1);
  List<int> _years = List.generate(70, (index) => DateTime.now().year - index - 7);

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection('users').doc(user.uid).get().then((snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data();
          if (data != null && data['name'] != null) {
            setState(() {
              _name = data['name'];
            });
          }
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.front, // ✅ Front camera
      imageQuality: 75,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = FirebaseStorage.instance.ref().child('profile_pictures/${user.uid}.jpg');
    await ref.putFile(_selectedImage!);
    _photoUrl = await ref.getDownloadURL();
  }

  Future<void> _saveProfile() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isSaving = true);

  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('No user signed in.');

    await _uploadImage();

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'photoUrl': _photoUrl ?? '',
      'name': _name,
      'phone': user.phoneNumber ?? '',
      'birthday': '$_selectedYear-${_selectedMonth?.toString().padLeft(2, '0')}-${_selectedDay?.toString().padLeft(2, '0')}',
      'gender': _gender,
      'farmingDuration': '${_farmingDurationController.text} $_farmingUnit',
      'region': _region,
      'province': _province,
      'city': _city,
      'profileCompletedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)); // 🔥 ito ang important!

    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.pushReplacementNamed(context, '/home');
  } catch (e) {
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error saving profile: $e')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kumpletuhin ang Profile'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),


// 🌾 Farmer Profile Logo
Image.asset(
  'assets/images/complete_profile.png',
  height: 150,
),
const SizedBox(height: 20),

              // 🖼️ Profile Picture Upload (Selfie)
GestureDetector(
  onTap: _pickImage, // function to pick image
  child: CircleAvatar(
    radius: 60,
    backgroundColor: Colors.green.shade100,
    backgroundImage: _selectedImage != null
        ? FileImage(_selectedImage!) // 📸 Show selected selfie
        : const AssetImage('') as ImageProvider, // 🧑 Default farmer logo
    child: _selectedImage == null
        ? const Icon(Icons.camera_alt, color: Colors.green, size: 30)
        : null, // Kung may image na, wala nang icon
  ),
),
const SizedBox(height: 20),


                // Greeting
                Text(
                  _name != null ? 'Hi $_name! Halos tapos na!' : 'Halos tapos na!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Birthday Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Birthday', style: theme.textTheme.titleMedium),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Buwan'),
                  value: _selectedMonth != null ? _monthNames[_selectedMonth! - 1] : null,
                  items: _monthNames.map((month) => DropdownMenuItem(
                    value: month,
                    child: Text(month),
                  )).toList(),
                  onChanged: (value) => setState(() => _selectedMonth = _monthNames.indexOf(value!) + 1),
                  validator: (value) => value == null ? 'Piliin ang buwan' : null,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        decoration: const InputDecoration(labelText: 'Araw'),
                        value: _selectedDay,
                        items: _days.map((day) => DropdownMenuItem(
                          value: day,
                          child: Text(day.toString()),
                        )).toList(),
                        onChanged: (value) => setState(() => _selectedDay = value),
                        validator: (value) => value == null ? 'Piliin ang araw' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        decoration: const InputDecoration(labelText: 'Taon'),
                        value: _selectedYear,
                        items: _years.map((year) => DropdownMenuItem(
                          value: year,
                          child: Text(year.toString()),
                        )).toList(),
                        onChanged: (value) => setState(() => _selectedYear = value),
                        validator: (value) => value == null ? 'Piliin ang taon' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Gender
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Kasarian'),
                  value: _gender,
                  items: const [
                    DropdownMenuItem(value: 'Lalaki', child: Text('Lalaki')),
                    DropdownMenuItem(value: 'Babae', child: Text('Babae')),
                  ],
                  onChanged: (value) => setState(() => _gender = value),
                  validator: (value) => value == null ? 'Piliin ang kasarian' : null,
                ),
                const SizedBox(height: 16),

               

                // Region
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Region'),
                  value: _region,
                  items: _regions.map((region) => DropdownMenuItem(
                    value: region,
                    child: Text(region),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      _region = value;
                      _province = null;
                      _city = null;
                    });
                  },
                  validator: (value) => value == null ? 'Piliin ang Region' : null,
                ),
                const SizedBox(height: 16),

                // Province
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Probinsya'),
                  value: _province,
                  items: _provinces.map((province) => DropdownMenuItem(
                    value: province,
                    child: Text(province),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      _province = value;
                      _city = null;
                    });
                  },
                  validator: (value) => value == null ? 'Piliin ang Probinsya' : null,
                ),
                const SizedBox(height: 16),

                // City
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'City/Munisipyo'),
                  value: _city,
                  items: (_province != null ? _citiesByProvince[_province]! : [])
                      .map((city) => DropdownMenuItem<String>(
  value: city,
  child: Text(city),
))

                      .toList(),
                  onChanged: (value) => setState(() => _city = value),
                  validator: (value) => value == null ? 'Piliin ang City/Munisipyo' : null,
                ),
                const SizedBox(height: 24),

                // Save Button
                _isSaving
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Save', style: TextStyle(color: Colors.white)),
                      ),
                const SizedBox(height: 20),

                // Privacy and Project Footer
                Text(
                  "Sa pagpapatuloy, tinatanggap mo ang aming Terms at Privacy Policy.",
                  style: theme.textTheme.bodySmall?.copyWith(
                    decoration: TextDecoration.underline,
                    color: Colors.blueGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Project by MG Calipara - MIT Student, National University",
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
