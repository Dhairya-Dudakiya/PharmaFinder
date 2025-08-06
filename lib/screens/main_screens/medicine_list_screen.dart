import 'package:flutter/material.dart';
import 'package:pharmafinder/models/medicine_model.dart';
import 'package:pharmafinder/services/medicine_service.dart';
import 'package:pharmafinder/widgets/MedicineCard.dart';
import 'package:pharmafinder/screens/main_screens/medicine_detail_screen.dart';

class MedicineListScreen extends StatefulWidget {
  final String category;

  const MedicineListScreen({Key? key, required this.category})
    : super(key: key);

  @override
  State<MedicineListScreen> createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  final MedicineService _service = MedicineService();
  late Future<List<Medicine>> _medicines;

  @override
  void initState() {
    super.initState();
    _medicines = _service.fetchMedicinesByCategory(widget.category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category)),
      body: FutureBuilder<List<Medicine>>(
        future: _medicines,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snap.hasError) {
            return Center(child: Text("Error: ${snap.error}"));
          } else if (snap.data == null || snap.data!.isEmpty) {
            return const Center(child: Text("No medicines found"));
          }
          return ListView.builder(
            itemCount: snap.data!.length,
            itemBuilder: (_, i) => MedicineCard(
              medicine: snap.data![i],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MedicineDetailScreen(medicine: snap.data![i]),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
