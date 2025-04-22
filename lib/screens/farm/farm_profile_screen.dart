import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'add_farm_dialog.dart';

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

  Widget _buildFarmsList(List<QueryDocumentSnapshot> farms) {
    return farms.isEmpty
        ? const Center(child: Text('Wala pang bukid.'))
        : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: farms.length,
            itemBuilder: (context, index) {
              final doc = farms[index];
              final data = doc.data() as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  title: Text(data['farmName'] ?? ''),
                  subtitle: Text('${data['crop']} • ${data['area']} ${data['unit']}'),
                  trailing: PopupMenuButton(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showAddFarmDialog(farmData: data, farmId: doc.id);
                      } else if (value == 'delete') {
                        _confirmDelete(doc.id);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                  onTap: () {
                    setState(() => _selectedFarm = data);
                    _tabController.animateTo(1);
                  },
                ),
              );
            },
          );
  }

  Widget _buildFarmDetails(Map<String, dynamic>? data) {
    if (data == null) {
      return const Center(child: Text('Pumili ng bukid para makita ang detalye.'));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data['farmName'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('May-ari: ${data['ownerName']}'),
              Text('Pananim: ${data['crop']}'),
              Text('Sukat: ${data['area']} ${data['unit']}'),
              Text('Patubig: ${data['waterSource']}'),
              Text('Organic: ${data['organic']}'),
              Text('Pagtatanim: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(data['plantingDate']))}'),
              Text('Anihan: ${data['expectedHarvestDate']}'),
              Text('Dami: ${data['expectedHarvestAmount']} ${data['harvestUnit']}'),
              if (data['relationship'] != null)
                Text('Relasyon sa May-ari: ${data['relationship']}'),
            ],
          ),
        ),
      ),
    );
  }
}
