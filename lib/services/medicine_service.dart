import 'package:firebase_database/firebase_database.dart';
import 'package:pharmafinder/models/medicine_model.dart';

class MedicineService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('medicines');

  /// ✅ Fetch all medicines across all stores
  Future<List<Medicine>> fetchMedicines() async {
    try {
      final snapshot = await _dbRef.get();
      final List<Medicine> medicines = [];

      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);

        // Loop through stores
        data.forEach((storeName, medicinesMap) {
          if (medicinesMap is Map) {
            medicinesMap.forEach((id, medData) {
              try {
                final medicine =
                    Medicine.fromJson(
                      Map<String, dynamic>.from(medData),
                    ).copyWith(
                      id: id,
                      storeName: storeName, // storeName from DB
                    );
                medicines.add(medicine);
              } catch (e) {
                print("Error parsing medicine $id in store $storeName: $e");
              }
            });
          }
        });
      }

      return medicines;
    } catch (e) {
      throw Exception("Error fetching medicines: $e");
    }
  }

  /// ✅ Fetch medicines by category
  Future<List<Medicine>> fetchMedicinesByCategory(String category) async {
    final all = await fetchMedicines();

    if (category.toLowerCase() == 'all') return all;

    return all
        .where((m) => m.category.toLowerCase() == category.toLowerCase())
        .toList();
  }
}
