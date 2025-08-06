import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pharmafinder/models/medicine_model.dart';
import 'package:pharmafinder/utils/icon_helper.dart';
import 'package:pharmafinder/screens/main_screens/cart_screen.dart';

class MedicineDetailScreen extends StatefulWidget {
  final Medicine medicine;

  const MedicineDetailScreen({super.key, required this.medicine});

  @override
  State<MedicineDetailScreen> createState() => _MedicineDetailScreenState();
}

class _MedicineDetailScreenState extends State<MedicineDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final medicine = widget.medicine;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          medicine.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.teal.withOpacity(0.1),
                child: Icon(
                  getMedicineIcon(medicine.icon),
                  size: 50,
                  color: Colors.teal,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoCard("Dosage", medicine.dosage),
            _buildInfoCard("Manufacturer", medicine.manufacturer),
            _buildInfoCard("Category", medicine.category),
            _buildInfoCard("Price", "₹${medicine.price.toStringAsFixed(2)}"),
            _buildInfoCard(
              "Prescription",
              medicine.requiresPrescription ? 'Required' : 'Not Required',
            ),
            const SizedBox(height: 20),
            const Text(
              "Description",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              medicine.description,
              style: const TextStyle(
                fontSize: 15,
                fontFamily: 'Poppins',
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 30),

            // Quantity selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    if (_quantity > 1) {
                      setState(() => _quantity--);
                    }
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Colors.teal,
                ),
                Text(
                  '$_quantity',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() => _quantity++);
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  color: Colors.teal,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Add to Cart Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please log in to add items'),
                      ),
                    );
                    return;
                  }

                  final cartRef = FirebaseFirestore.instance
                      .collection('carts')
                      .doc(user.uid)
                      .collection('items')
                      .doc(medicine.id);

                  try {
                    await cartRef.set({
                      'id': medicine.id,
                      'name': medicine.name,
                      'price': medicine.price,
                      'quantity': _quantity,
                      'category': medicine.category,
                      'dosage': medicine.dosage,
                      'manufacturer': medicine.manufacturer,
                      'description': medicine.description,
                      'icon': medicine.icon,
                      'requiresPrescription': medicine.requiresPrescription,
                      'addedAt': FieldValue.serverTimestamp(),
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Added $_quantity to cart')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text(
                  "Add to Cart",
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(
              "$label: ",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.teal,
                fontFamily: 'Poppins',
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontSize: 16, fontFamily: 'Poppins'),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
