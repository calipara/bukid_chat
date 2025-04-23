import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'add_farm_dialog.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'farm_map_screen.dart';



class FarmProfileScreen extends StatefulWidget {
  const FarmProfileScreen({super.key});

  @override
  State<FarmProfileScreen> createState() => _FarmProfileScreenState();
}

class _FarmProfileScreenState extends State<FarmProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? _selectedFarm;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _showAddFarmDialog({Map<String, dynamic>? farmData, String? farmId}) {
    showDialog(
      context: context,
      builder: (context) => AddFarmDialog(
        farmData: farmData,
        farmId: farmId,
      ),
    );
  }

  void _confirmDelete(String farmId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sigurado ka ba?'),
        content: const Text('Gusto mo bang burahin ang bukid na ito? Hindi ito maibabalik.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hindi')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Oo')),
        ],
      ),
    );
    if (confirmed == true) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('farms')
          .doc(farmId)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile ng Bukid'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mga Bukid Ko'),
            Tab(text: 'Detalye ng Bukid'),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .collection('farms')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final farms = snapshot.data!.docs;

          return TabBarView(
            controller: _tabController,
            children: [
              _buildFarmsList(farms),
              _buildFarmDetails(_selectedFarm),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFarmDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  //card list view
Widget _buildFarmsList(List<QueryDocumentSnapshot> farms) {
  return farms.isEmpty
      ? const Center(child: Text('Wala pang bukid.'))
      : ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: farms.length,
          itemBuilder: (context, index) {
            final doc = farms[index];
            final data = doc.data() as Map<String, dynamic>;
            final crop = (data['crop'] ?? '').toString().toLowerCase();
            final imagePath = crop == 'rice'
                ? 'assets/images/rice_banner.jpg'
                : crop == 'corn'
                    ? 'assets/images/corn_banner.jpg'
                    : 'assets/images/farm_add.png';

            return GestureDetector(
              onTap: () {
                setState(() => _selectedFarm = data);
                _tabController.animateTo(1);
              },
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 📸 Banner Image with gradient
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: Image.asset(
                            imagePath,
                            height: 100,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: 100,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.black54, Colors.transparent],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.white),
                                onPressed: () => _showAddFarmDialog(farmData: data, farmId: doc.id),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.white),
                                onPressed: () => _confirmDelete(doc.id),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // 📄 Text info
                    Padding(
  padding: const EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        data['farmName'] ?? '',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        '${data['crop']} • ${data['area']} ${data['unit']}',
        style: const TextStyle(color: Colors.grey),
      ),
      const SizedBox(height: 12),

      // 👉 Location View Button
      InkWell(
        onTap: () {
          final polygon = (data['locationPolygon'] as List?)
              ?.map((p) => LatLng(p['lat'], p['lng']))
              .toList();
          final center = data['locationCenter'] != null
              ? LatLng(data['locationCenter']['lat'], data['locationCenter']['lng'])
              : null;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FarmMapScreen(
                existingPolygon: polygon,
                existingCenter: center,
                onSave: (_, __) {}, // dummy
              ),
            ),
          );
        },
        child: Row(
          children: const [
            Icon(Icons.location_on, color: Colors.green),
            SizedBox(width: 6),
            Text(
              'Lokasyon',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
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



  Widget _buildFarmDetails(Map<String, dynamic>? data) {
  if (data == null) {
    return const Center(child: Text('Pumili ng bukid para makita ang detalye.'));
  }

  Widget _detailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.black54,
                    )),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              data['farmName'] ?? '',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 20),
            const Divider(),

            // Farm Details with icons
            _detailItem(Icons.person, 'May-ari', data['ownerName'] ?? ''),
            _detailItem(Icons.eco, 'Pananim', data['crop'] ?? ''),
            _detailItem(Icons.square_foot, 'Sukat ng Sakahan', '${data['area']} ${data['unit']}'),
            _detailItem(Icons.water_drop, 'Patubig', data['waterSource'] ?? ''),
            _detailItem(Icons.nature, 'Organic Farming', data['organic'] ?? ''),
            _detailItem(Icons.calendar_today, 'Pagtatanim',
                DateFormat('yyyy-MM-dd').format(DateTime.parse(data['plantingDate']))),
            _detailItem(Icons.event, 'Anihan', data['expectedHarvestDate'] ?? ''),
            _detailItem(Icons.shopping_bag, 'Dami ng Ani',
                '${data['expectedHarvestAmount']} ${data['harvestUnit']}'),
            if (data['relationship'] != null)
              _detailItem(Icons.family_restroom, 'Relasyon sa May-ari', data['relationship']),
          ],
        ),
      ),
    ),
  );
}

}
