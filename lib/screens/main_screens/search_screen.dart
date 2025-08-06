import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pharmafinder/models/medicine_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchQuery = '';
  List<Medicine> allMedicines = [];
  List<Medicine> filteredMedicines = [];

  @override
  void initState() {
    super.initState();
    fetchMedicines();
  }

  Future<void> fetchMedicines() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('medicines')
          .get();

      final medicines = snapshot.docs
          .map((doc) => Medicine.fromFirestore(doc))
          .toList();

      setState(() {
        allMedicines = medicines;
        filteredMedicines = medicines;
      });
    } catch (e) {
      print('Error fetching medicines: $e');
    }
  }

  void _filterMedicines(String query) {
    final lowerQuery = query.toLowerCase();

    final filtered = allMedicines.where((med) {
      return med.name.toLowerCase().contains(lowerQuery) ||
          med.category.toLowerCase().contains(lowerQuery) ||
          med.manufacturer.toLowerCase().contains(lowerQuery) ||
          med.dosage.toLowerCase().contains(lowerQuery);
    }).toList();

    setState(() {
      searchQuery = query;
      filteredMedicines = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Medicines'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: _filterMedicines,
              decoration: const InputDecoration(
                hintText: 'Search medicines...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredMedicines.isEmpty
                ? const Center(child: Text('No medicines found.'))
                : ListView.builder(
                    itemCount: filteredMedicines.length,
                    itemBuilder: (context, index) {
                      final med = filteredMedicines[index];
                      return ListTile(
                        leading: Icon(Icons.medication_outlined),
                        title: Text(med.name),
                        subtitle: Text('${med.category} - ₹${med.price}'),
                        trailing: med.requiresPrescription
                            ? const Icon(Icons.receipt_long, color: Colors.red)
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
