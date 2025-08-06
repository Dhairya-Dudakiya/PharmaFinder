import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pharmafinder/models/cart_item_model.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final double totalAmount;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.totalAmount,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressController = TextEditingController();
  bool _isPlacingOrder = false;

  Future<void> _placeOrder() async {
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a delivery address.')),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not logged in');

      final orderRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('orders')
          .doc();

      await orderRef.set({
        'userId': user.uid,
        'totalAmount': widget.totalAmount,
        'address': _addressController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      for (final item in widget.cartItems) {
        await orderRef.collection('items').add({
          'medicineId': item.medicine.id,
          'name': item.medicine.name,
          'price': item.medicine.price,
          'quantity': item.quantity,
          'total': item.medicine.price * item.quantity,
        });
      }

      // Clear cart if needed (optional: based on your implementation)
      final cartRef = FirebaseFirestore.instance
          .collection('carts')
          .doc(user.uid)
          .collection('items');

      final cartItems = await cartRef.get();
      for (final doc in cartItems.docs) {
        await doc.reference.delete();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
        Navigator.pop(context); // Go back to previous screen
      }
    } catch (e) {
      debugPrint('Order error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to place order: $e')));
    } finally {
      setState(() => _isPlacingOrder = false);
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  ...widget.cartItems.map(
                    (item) => ListTile(
                      title: Text(item.medicine.name),
                      subtitle: Text('Qty: ${item.quantity}'),
                      trailing: Text(
                        '₹${(item.medicine.price * item.quantity).toStringAsFixed(2)}',
                      ),
                    ),
                  ),
                  const Divider(),
                  TextField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Delivery Address',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Total: ₹${widget.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _isPlacingOrder ? null : _placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size.fromHeight(50),
              ),
              child: _isPlacingOrder
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Place Order'),
            ),
          ],
        ),
      ),
    );
  }
}
