import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'profile_edit_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _userData = doc.data();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _confirmLogout() async {
  final shouldLogout = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Logout'),
      content: const Text('Sigurado ka bang gusto mong mag-logout?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Hindi'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Oo, Logout'),
        ),
      ],
    ),
  );

  if (shouldLogout == true) {
    try {
      await FirebaseAuth.instance.signOut(); // ✅ End Firebase session
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false); 
      // ✅ Clear all routes and balik Login screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout Failed: ${e.toString()}')),
      );
    }
  }
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
        backgroundColor: Colors.green,
        elevation: 0,
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
              ).then((_) => _fetchUserProfile()); // refresh after editing
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // 🖼️ Profile Picture
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.green.shade100,
              backgroundImage: _userData?['photoUrl'] != null && _userData!['photoUrl'] != ''
                  ? NetworkImage(_userData!['photoUrl']) as ImageProvider
                  : const AssetImage('assets/images/default_avatar.png'),
            ),
            const SizedBox(height: 16),

            // 📝 Name and Phone
            Text(
              _userData?['name'] ?? '',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              _userData?['phone'] ?? '',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const Divider(height: 40, thickness: 1),

            // 📋 User Information List
            _buildInfoTile(Icons.calendar_today, 'Birthday', _userData?['birthday']),
            _buildInfoTile(Icons.person, 'Kasarian', _userData?['gender']),
            _buildInfoTile(Icons.map, 'Region', _userData?['region']),
            _buildInfoTile(Icons.place, 'Probinsya', _userData?['province']),
            _buildInfoTile(Icons.location_city, 'City / Munisipyo', _userData?['city']),
           
          ],
        ),
      ),
    );
  }

  // 👇 Modernized Info Row
  Widget _buildInfoTile(IconData icon, String title, String? value) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.green),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        value ?? '-',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
