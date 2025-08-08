import 'package:firebase_database/firebase_database.dart';
import 'package:pharmafinder/models/medicine_model.dart';

class MedicineService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('medicines');

  // ✅ Fetch all medicines (from all admins/stores)
  Future<List<Medicine>> fetchMedicines() async {
    final snapshot = await _dbRef.get();
    final List<Medicine> allMedicines = [];

    if (snapshot.exists && snapshot.value != null) {
      final data = snapshot.value as Map;

      data.forEach((adminId, stores) {
        if (stores is Map) {
          stores.forEach((storeName, medicinesMap) {
            if (medicinesMap is Map) {
              medicinesMap.forEach((id, medData) {
                try {
                  final medicine = Medicine.fromJson(
                    Map<String, dynamic>.from(medData),
                  ).copyWith(id: id);
                  allMedicines.add(medicine);
                } catch (e) {
                  print("Error parsing medicine: $e");
                }
              });
            }
          });
        }
      });
    }

    return allMedicines;
  }

  // ✅ Fetch medicines by category
  Future<List<Medicine>> fetchMedicinesByCategory(String category) async {
    final all = await fetchMedicines();

    if (category.toLowerCase() == 'all') return all;

    return all
        .where((m) => m.category.toLowerCase() == category.toLowerCase())
        .toList();
  }
}
