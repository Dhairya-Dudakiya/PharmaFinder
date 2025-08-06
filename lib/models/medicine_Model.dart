import 'package:cloud_firestore/cloud_firestore.dart';

class Medicine {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String dosage;
  final String manufacturer;
  final bool requiresPrescription;
  final String icon;

  Medicine({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.dosage,
    required this.manufacturer,
    required this.requiresPrescription,
    required this.icon,
  });

  // ✅ From JSON (e.g., for decoding from cart or API)
  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : (json['price'] is double)
          ? json['price']
          : double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
      dosage: json['dosage']?.toString() ?? '',
      manufacturer: json['manufacturer']?.toString() ?? '',
      requiresPrescription: json['requiresPrescription'] == true,
      icon: json['icon']?.toString() ?? 'medication',
    );
  }

  // ✅ From Firestore document
  factory Medicine.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Medicine(
      id: doc.id,
      name: data['name']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      category: data['category']?.toString() ?? '',
      price: (data['price'] is int)
          ? (data['price'] as int).toDouble()
          : (data['price'] is double)
          ? data['price']
          : double.tryParse(data['price']?.toString() ?? '') ?? 0.0,
      dosage: data['dosage']?.toString() ?? '',
      manufacturer: data['manufacturer']?.toString() ?? '',
      requiresPrescription: data['requiresPrescription'] == true,
      icon: data['icon']?.toString() ?? 'medication',
    );
  }

  // ✅ To JSON (for storing in Firestore or cart)
  Map<String, dynamic> toJson() {
    return {
      // DO NOT include 'id' unless absolutely needed for offline use
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'dosage': dosage,
      'manufacturer': manufacturer,
      'requiresPrescription': requiresPrescription,
      'icon': icon,
    };
  }

  Medicine copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? price,
    String? dosage,
    String? manufacturer,
    bool? requiresPrescription,
    String? icon,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      dosage: dosage ?? this.dosage,
      manufacturer: manufacturer ?? this.manufacturer,
      requiresPrescription: requiresPrescription ?? this.requiresPrescription,
      icon: icon ?? this.icon,
    );
  }
}
