import 'package:firebase_database/firebase_database.dart';
import 'package:pharmafinder/models/medicine_model.dart';

class MedicineService {
  final _dbRef = FirebaseDatabase.instance.ref('medicines');

  Future<List<Medicine>> fetchMedicines() async {
    final snapshot = await _dbRef.get();

    if (snapshot.exists && snapshot.value != null) {
      final List<dynamic> rawList = snapshot.value as List;

      return rawList
          .where(
            (item) => item != null,
          ) // Filter out nulls (e.g., from deleted indices)
          .map((item) => Medicine.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } else {
      return [];
    }
  }

  Future<List<Medicine>> fetchMedicinesByCategory(String category) async {
    final all = await fetchMedicines();

    if (category.toLowerCase() == 'all') return all;

    return all
        .where((m) => m.category.toLowerCase() == category.toLowerCase())
        .toList();
  }
}
